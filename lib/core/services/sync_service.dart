import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/database_snapshot.dart';
import 'firestore_rest_client.dart';

/// What the cloud sync is doing right now (surfaced in Settings).
enum SyncStatus { idle, pulling, pushing, error }

/// Whole-database cloud sync (mirror model).
///
/// - On login / app start, the cloud snapshot is pulled into the local Drift
///   DB (cloud wins) so every device starts from the same state.
/// - Whenever local data changes, a debounced push uploads the full snapshot.
/// - First ever login with an empty cloud doc uploads the seeded local DB.
///
/// Two transports talk to the same `users/<uid>/state` document:
/// - the cloud_firestore plugin where it exists (Android/iOS/macOS/web), and
/// - a [FirestoreRestClient] on platforms FlutterFire doesn't support
///   (Linux/Windows), authenticated with the user's Firebase ID token.
///
/// Because sync is at the whole-DB level, treat it as "one active writer at a
/// time" — the device you study with last is the one that wins.
class SyncService {
  SyncService(
    this._db, {
    required this.projectId,
    required Future<String?> Function() idToken,
  }) : _codec = DatabaseSnapshotCodec(_db),
       _idToken = idToken {
    print('[studyn-sync] init');
    _useRest = _pickRest();
  }

  final AppDatabase _db;
  final String projectId;
  final Future<String?> Function() _idToken;
  final DatabaseSnapshotCodec _codec;
  FirebaseFirestore? _firestore;
  FirestoreRestClient? _rest;
  late final bool _useRest;

  /// Whether cloud_firestore is usable on this platform. [FirebaseFirestore
  /// .instance] requires an initialized Firebase App, which FlutterFire can't
  /// provide on Linux/Windows, so those platforms fall back to the REST client.
  bool _pickRest() {
    try {
      FirebaseFirestore.instance;
      return false;
    } catch (e) {
      print('[studyn-sync] cloud_firestore unavailable, using REST: $e');
      return true;
    }
  }

  FirebaseFirestore get _fs {
    return _firestore ??= FirebaseFirestore.instance;
  }

  FirestoreRestClient get _restClient =>
      _rest ??= FirestoreRestClient(projectId);

  /// The Firebase ID token for the signed-in user (throws when signed out).
  Future<String> _token() async {
    final token = await _idToken();
    if (token == null) {
      throw StateError('Not signed in: no ID token available for sync');
    }
    return token;
  }

  final StreamController<SyncStatus> _status =
      StreamController<SyncStatus>.broadcast();

  StreamSubscription<Object?>? _tableSub;
  Timer? _debounce;
  bool _suppressPush = false;
  bool _running = false;
  bool _disposed = false;

  SyncStatus current = SyncStatus.idle;

  Stream<SyncStatus> get status => _status.stream;

  void _set(SyncStatus s) {
    current = s;
    if (!_disposed && !_status.isClosed) {
      _status.add(s);
    }
  }

  /// Starts sync for [uid]: pull the cloud snapshot immediately, then keep
  /// local changes flowing up. Emits status changes.
  Stream<SyncStatus> run(String uid) {
    if (_running) {
      print('[studyn-sync] run: already running for uid=$uid');
      return _status.stream;
    }
    _running = true;
    print(
      '[studyn-sync] run: starting for uid=$uid '
      'transport=${_useRest ? 'rest' : 'plugin'}',
    );
    unawaited(_pull(uid));
    _tableSub?.cancel();
    _tableSub = _db
        .tableUpdates(TableUpdateQuery.any())
        .listen((_) => _schedulePush(uid));
    return _status.stream;
  }

  /// Restores the cloud snapshot into the local DB if one exists; otherwise
  /// seeds the cloud with the current local data.
  Future<SyncStatus> pull(String uid) => _pull(uid);

  Future<SyncStatus> _pull(String uid) async {
    print('[studyn-sync] pull: uid=$uid');
    _set(SyncStatus.pulling);
    try {
      final Map<String, Object?>? data = _useRest
          ? await _pullRest(uid)
          : await _pullPlugin(uid);
      if (data == null) {
        _set(SyncStatus.idle);
        print('[studyn-sync] pull: no cloud doc, seeding from local');
        unawaited(_push(uid));
        return SyncStatus.idle;
      }
      _suppressPush = true;
      try {
        await _codec.restore(data);
      } finally {
        _suppressPush = false;
      }
      _set(SyncStatus.idle);
      print('[studyn-sync] pull: restore complete');
      return SyncStatus.idle;
    } catch (e, s) {
      print('[studyn-sync] pull: FAILED $e');
      print(s);
      _set(SyncStatus.error);
      return SyncStatus.error;
    }
  }

  Future<Map<String, Object?>?> _pullPlugin(String uid) async {
    final snap = await _fs.doc('users/$uid/state/snapshot').get();
    print('[studyn-sync] pull: snapshot exists=${snap.exists}');
    if (!snap.exists) return null;
    return Map<String, Object?>.from(snap.data()!);
  }

  Future<Map<String, Object?>?> _pullRest(String uid) async {
    final data = await _restClient.getDocument(uid, await _token());
    print(
      '[studyn-sync] pull: snapshot ${data == null ? 'absent' : 'present'}',
    );
    return data;
  }

  /// Uploads the current local DB as the cloud snapshot.
  Future<SyncStatus> push(String uid) => _push(uid);

  Future<SyncStatus> _push(String uid) async {
    if (_suppressPush || _disposed) return SyncStatus.idle;
    _set(SyncStatus.pushing);
    try {
      final data = await _codec.captureJson();
      if (_useRest) {
        await _restClient.setDocument(uid, await _token(), {
          ...data,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } else {
        final ref = _fs.doc('users/$uid/state/snapshot');
        print('[studyn-sync] push: writing ${data.length} keys to ${ref.path}');
        await ref.set({...data, 'updatedAt': FieldValue.serverTimestamp()});
      }
      _set(SyncStatus.idle);
      print('[studyn-sync] push: OK');
      return SyncStatus.idle;
    } catch (e, s) {
      print('[studyn-sync] push: FAILED $e');
      print(s);
      _set(SyncStatus.error);
      return SyncStatus.error;
    }
  }

  void _schedulePush(String uid) {
    if (_suppressPush || !_running || _disposed) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      unawaited(_push(uid));
    });
  }

  Future<void> dispose() async {
    print('[studyn-sync] dispose');
    _disposed = true;
    _running = false;
    _debounce?.cancel();
    await _tableSub?.cancel();
    await _status.close();
    _rest?.close();
  }
}
