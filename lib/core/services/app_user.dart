/// Minimal platform-agnostic representation of a signed-in user.
///
/// Both the native [FirebaseAuth] path (mobile/web/macOS) and the REST path
/// (Linux/Windows desktop) produce this, so the rest of the app never has to
/// know which backend is backing sign-in.
class AppUser {
  const AppUser({required this.uid, this.email});

  final String uid;
  final String? email;
}
