# NEET Journal

Flutter + Dart study companion. Material 3, Riverpod, Drift (SQLite).

## Commands

- Format: `dart format lib test`
- Analyze: `flutter analyze`
- Test: `LD_LIBRARY_PATH="$HOME/lib" flutter test`

Note: host tests need a system `libsqlite3.so`. If missing, symlink the
installed library (e.g. `ln -sf /lib/x86_64-linux-gnu/libsqlite3.so.0 ~/lib/libsqlite3.so`).
The app itself bundles sqlite via `drift_flutter`.

## Conventions

- State: Riverpod providers in `lib/state/providers.dart`; repositories in
  `lib/data/repositories/`.
- After changing tables in `lib/core/db/tables.dart` or `database.dart`, run
  `dart run build_runner build --delete-conflicting-outputs`.
- Schema bumps go in `AppDatabase.schemaVersion` with a matching `onUpgrade`
  migration.
