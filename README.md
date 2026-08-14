# studyn

Studyn — a study companion for NEET aspirants. Flutter + Dart, Material 3,
Riverpod, Drift (SQLite).

## Development

```sh
dart format lib test        # format
flutter analyze             # lint / typecheck
flutter test                # run tests (see note below)
```

Note: host tests need a system `libsqlite3.so`. If missing, symlink the
installed library:

```sh
ln -sf /lib/x86_64-linux-gnu/libsqlite3.so.0 ~/lib/libsqlite3.so
LD_LIBRARY_PATH="$HOME/lib" flutter test
```

After changing tables in `lib/core/db/tables.dart` or `database.dart`:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Run on desktop (Linux)

```sh
flutter run -d linux
```

## Build installers

### Linux (.deb)

Builds `dist/studyn_<version>_amd64.deb` (installs to `/usr/lib/studyn`, adds
an app-menu entry and icon):

```sh
./tool/package_linux.sh
sudo apt install ./dist/studyn_<version>_amd64.deb
```

### Windows (MSIX installer)

On a Windows machine with the repo checked out:

```sh
flutter pub get
flutter build windows --release
dart run msix:create
```

Produces an installable `.msix` (Start-menu entry, system install, uninstall
support). Certificate installs automatically so the package installs cleanly.

### Android (APK)

```sh
flutter build apk --release
```

## App icon

All platform icons (Windows `.ico`, Android launcher + adaptive icons, MSIX
logo) are generated from `assets/images/app_logo.png`. After changing that
image, regenerate:

```sh
dart run flutter_launcher_icons
convert assets/images/app_logo.png \
  -define icon:auto-resize=256,128,64,48,32,16 \
  windows/runner/resources/app_icon.ico
```

The Linux window icon is loaded at runtime from the bundled logo
(`linux/runner/my_application.cc`), so it needs no regeneration.
