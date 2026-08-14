#!/usr/bin/env bash
#
# Builds a system-installable .deb package for the Linux app.
#
# Produces: dist/studyn_<version>_amd64.deb
# Installs to: /usr/lib/studyn, /usr/share/applications, /usr/share/icons/hicolor
#
set -euo pipefail

cd "$(dirname "$0")/.."

APP_BINARY="studyn"
APP_ID="com.neerjournal.studyn"
APP_NAME="Studyn"
APP_COMMENT="Studyn - a simple study companion for NEET aspirants"
VERSION="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"
ARCH="amd64"

STAGE="build/linux-deb"
ROOT_DIR="$STAGE/usr"
BIN_DIR="$ROOT_DIR/lib/$APP_BINARY"
DEB_FILE="dist/studyn_${VERSION}_${ARCH}.deb"

rm -rf "$STAGE"
mkdir -p "$BIN_DIR" "$ROOT_DIR/share/applications" "$ROOT_DIR/share/icons/hicolor/512x512/apps" "dist"

flutter build linux --release

cp -a build/linux/x64/release/bundle/. "$BIN_DIR/"

cp assets/images/app_logo.png "$ROOT_DIR/share/icons/hicolor/512x512/apps/$APP_BINARY.png"

cat > "$ROOT_DIR/share/applications/$APP_BINARY.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=$APP_COMMENT
Exec=$APP_BINARY
Icon=$APP_BINARY
Terminal=false
Categories=Education;Utility;
StartupWMClass=$APP_ID
EOF

mkdir -p "$STAGE/DEBIAN"
cat > "$STAGE/DEBIAN/control" <<EOF
Package: $APP_BINARY
Version: $VERSION
Section: education
Priority: optional
Architecture: $ARCH
Maintainer: NEET Journal <hello@neerjournal.com>
Depends: libgtk-3-0, libx11-6, libnss3, libnspr4, libatk-bridge2.0-0, libxcomposite1, libxcursor1, libxdamage1, libxext6, libxfixes3, libxi6, libxinerama1, libxrandr2, libxtst6, libsqlite3-0
Description: $APP_NAME - a simple study companion for NEET aspirants
 Study planner with focus timers, breaks and rest reminders.
EOF

dpkg-deb --build --root-owner-group "$STAGE" "$DEB_FILE"

echo ""
echo "Installer built: $DEB_FILE"
echo "Install with: sudo apt install ./$DEB_FILE"
