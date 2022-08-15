#!/bin/sh

set -e

######################################## util #########################################

COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;94m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

run() {
    printf '%b\n' "${COLOR_PURPLE}==>${COLOR_OFF} ${COLOR_GREEN}$*${COLOR_OFF}"
    eval "$*"
}

die() {
    printf '%b\n' "${COLOR_RED}💔  $*${COLOR_OFF}" >&2
    exit 1
}

die_if_command_not_found() {
    for item in $@
    do
        command -v $item > /dev/null || die "$item command not found."
    done
}

######################################## main #########################################

die_if_command_not_found tar gzip git gh tar xz

run cd "$(dirname "$0")"

run pwd

unset TEMP_DIR

unset RELEASE_VERSION
unset RELEASE_DIRNAME
unset RELEASE_TARFILE

RELEASE_VERSION="$(date +%Y.%m.%d)"
RELEASE_DIRNAME="ppkg-core-$RELEASE_VERSION-linux-x86_64"
RELEASE_TARFILE="$RELEASE_DIRNAME.tar.xz"

TEMP_DIR=$(mktemp -d)

run rm -rf     "$RELEASE_DIRNAME"
run install -d "$RELEASE_DIRNAME"

for item in *.tar.xz
do
    case $item in
        openssl-*.tar.xz)
            ;;
        util-linux-*.tar.xz)
            tar vxf "$item" --strip-components=1 -C "$TEMP_DIR"
            ;;
        gnu-coreutils-*.tar.xz)
            tar vxf "$item" --strip-components=1 -C "$TEMP_DIR"
            ;;
        gnu-binutils-*.tar.xz)
            ;;
        libarchive-*.tar.xz)
            ;;
        cmake-*.tar.xz)
            ;;
        *)  tar vxf "$item" --strip-components=1 -C "$RELEASE_DIRNAME"
    esac
done

for item in hexdump date sort ln tr realpath base64 md5sum sha256sum
do
    run cp $TEMP_DIR/bin/$item "$RELEASE_DIRNAME/bin/"
done

run rm "$RELEASE_DIRNAME/installed-metadata"
run rm "$RELEASE_DIRNAME/installed-files"

run tar vcJf "$RELEASE_TARFILE" "$RELEASE_DIRNAME"

RELEASE_NOTES_FILE="$RELEASE_DIRNAME/release-notes.md"

run cp README.md "$RELEASE_NOTES_FILE"

cat >> "$RELEASE_NOTES_FILE" <<EOF

|sha256sum|filename|
|---------|--------|
EOF

for item in *.tar.xz
do
    sha256sum "$item" | sed -e 's/  /|/' -e 's/^/|/' -e 's/$/|/' >> "$RELEASE_NOTES_FILE"
done

run mv "$RELEASE_TARFILE" "$RELEASE_DIRNAME"

run gh release create "$RELEASE_VERSION" "$RELEASE_DIRNAME/$RELEASE_TARFILE" "$RELEASE_DIRNAME/bin/curl" "$RELEASE_DIRNAME/bin/tar" "$RELEASE_DIRNAME/bin/xz" *.tar.xz --notes-file "$RELEASE_NOTES_FILE"
