import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/app_user.dart';
import '../core/services/auth_service.dart';
import '../core/services/sync_service.dart';
import '../firebase_options.dart';
import 'providers.dart';

/// Initializes Firebase once. Returns `null` when Firebase is unavailable
/// (e.g. firebase_options.dart not configured, or Linux/Windows where
/// FlutterFire has no implementation) so the app can still run locally.
final firebaseAppProvider = FutureProvider<FirebaseApp?>((ref) async {
  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    return null;
  }
});

/// Backed by the native Firebase plugins on mobile/web/macOS and by the
/// Firebase Auth REST API on Linux/Windows. See [AuthService.create].
final authServiceProvider = Provider<AuthService>((ref) {
  final service = AuthService.create();
  ref.onDispose(service.dispose);
  return service;
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  print('[studyn-sync] provider: creating SyncService');
  final service = SyncService(
    ref.watch(databaseProvider),
    projectId: DefaultFirebaseOptions.currentPlatform.projectId,
    idToken: () => ref.read(authServiceProvider).getIdToken(),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Starts cloud sync for the signed-in user and streams its status.
final activeSyncProvider = StreamProvider.family<SyncStatus, String>((
  ref,
  uid,
) {
  print('[studyn-sync] provider: activeSyncProvider(uid=$uid)');
  return ref.watch(syncServiceProvider).run(uid);
});

/// Whether the user has taken the onboarding study oath (per user, synced).
final oathTakenProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchSetting('oathTaken')
      .map((v) => v == '1');
});
