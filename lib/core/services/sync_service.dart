import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/database_snapshot.dart';

/// What the cloud sync is doing right now (surfaced in Settings).
enum SyncStatus { idle, pulling, pushing, error }

/// Whole-database cloud sync (mirror model).
///
/// - On login / app start, the cloud snapshot is pulled into the local Drift
///   DB (cloud wins) so every device starts from the same state.
/// - Whenever local data changes, a debounced push uploads the full snapshot.
/// - First ever login with an empty cloud doc uploads the seeded local DB.
///
/// Because sync is at the whole-DB level, treat it as "one active writer at a
/// time" — the device you study with last is the one that wins.
class SyncService {
  SyncService(this._db) : _codec = DatabaseSnapshotCodec(_db);

  final AppDatabase _db;
  final DatabaseSnapshotCodec _codec;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<SyncStatus> _status =
      StreamController<SyncStatus>.broadcast();

  StreamSubscription<Object?>? _tableSub;
  Timer? _debounce;
  bool _suppressPush = false;
  bool _running = false;
  bool _disposed = false;

  SyncStatus current = SyncStatus.idle;

  Stream<SyncStatus> get status => _status.stream;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.doc('users/$uid/state');

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
      return _status.stream;
    }
    _running = true;
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
    _set(SyncStatus.pulling);
    try {
      final snap = await _doc(uid).get();
      if (!snap.exists) {
        _set(SyncStatus.idle);
        unawaited(_push(uid));
        return SyncStatus.idle;
      }
      final data = Map<String, Object?>.from(snap.data()!);
      _suppressPush = true;
      try {
        await _codec.restore(data);
      } finally {
        _suppressPush = false;
      }
      _set(SyncStatus.idle);
      return SyncStatus.idle;
    } catch (e) {
      _set(SyncStatus.error);
      return SyncStatus.error;
    }
  }

  /// Uploads the current local DB as the cloud snapshot.
  Future<SyncStatus> push(String uid) => _push(uid);

  Future<SyncStatus> _push(String uid) async {
    if (_suppressPush || _disposed) return SyncStatus.idle;
    _set(SyncStatus.pushing);
    try {
      final data = await _codec.captureJson();
      await _doc(uid).set({...data, 'updatedAt': FieldValue.serverTimestamp()});
      _set(SyncStatus.idle);
      return SyncStatus.idle;
    } catch (e) {
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
    _disposed = true;
    _running = false;
    _debounce?.cancel();
    await _tableSub?.cancel();
    await _status.close();
  }
}
