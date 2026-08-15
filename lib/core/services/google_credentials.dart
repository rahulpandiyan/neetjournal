/// Google OAuth credentials shared by native and desktop sign-in.
///
/// The client ID is public — it also ships in google-services.json. The client
/// secret is intentionally NOT stored here: it is injected at build time with
/// `--dart-define=GOOGLE_CLIENT_SECRET=...` or read at runtime from
/// `~/.studyn/google_secret`, so it never ends up in the repository.
library;

const String googleDesktopClientId =
    '951622306229-j0k12n48lt4prl8pp44gfmun105nmiij.apps.googleusercontent.com';

const String googleDesktopClientSecret = String.fromEnvironment(
  'GOOGLE_CLIENT_SECRET',
  defaultValue: '',
);
