import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_service.dart';
import '../core/services/sync_service.dart';
import '../firebase_options.dart';
import 'providers.dart';

/// Initializes Firebase once. Returns `null` when Firebase is unavailable
/// (e.g. firebase_options.dart not configured yet) so the app can still run
/// locally without auth/cloud sync.
final firebaseAppProvider = FutureProvider<FirebaseApp?>((ref) async {
  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    return null;
  }
});

/// Only meaningful once [firebaseAppProvider] has resolved to non-null.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(FirebaseAuth.instance),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref.watch(databaseProvider));
  ref.onDispose(service.dispose);
  return service;
});

/// Starts cloud sync for the signed-in user and streams its status.
final activeSyncProvider = StreamProvider.family<SyncStatus, String>((
  ref,
  uid,
) {
  return ref.watch(syncServiceProvider).run(uid);
});

/// Whether the user has taken the onboarding study oath (per user, synced).
final oathTakenProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchSetting('oathTaken')
      .map((v) => v == '1');
});
