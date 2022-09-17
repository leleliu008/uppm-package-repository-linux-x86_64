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

sed_in_place() {
    if command -v gsed > /dev/null ; then
        unset SED_IN_PLACE_ACTION
        SED_IN_PLACE_ACTION="$1"
        shift
        # contains ' but not contains \'
        if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
            run gsed -i "\"$SED_IN_PLACE_ACTION\"" $@
        else
            run gsed -i "'$SED_IN_PLACE_ACTION'" $@
        fi
    elif command -v sed  > /dev/null ; then
        if sed -i 's/a/b/g' $(mktemp) 2> /dev/null ; then
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i "'$SED_IN_PLACE_ACTION'" $@
            fi
        else
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i '""' "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i '""' "'$SED_IN_PLACE_ACTION'" $@
            fi
        fi
    else
        error "please install sed utility."
        return 1
    fi
}

######################################## main #########################################

die_if_command_not_found tar gzip xz gh sed grep hexdump date sha256sum

run cd "$(dirname "$0")"

run pwd


if [ -d ppkg-formula-repository/.git ] ; then
    cd  ppkg-formula-repository
    gh repo sync
    cd -
else
    gh repo clone leleliu008/ppkg-formula-repository
fi

if [ -d uppm-formula-repository-linux-x86_64/.git ] ; then
    cd  uppm-formula-repository-linux-x86_64
    gh repo sync
    cd -
else
    gh repo clone leleliu008/uppm-formula-repository-linux-x86_64
fi

unset RELEASE_VERSION

RELEASE_VERSION="$(date +%Y.%m.%d)"
RELEASE_NOTES_FILE='release-notes.md'

run cp README.md "$RELEASE_NOTES_FILE"

cat >> "$RELEASE_NOTES_FILE" <<EOF

|sha256sum|filename|
|---------|--------|
EOF

for filename in $(cd package && ls *.tar.xz)
do
    unset PACKAGE_NAME
    unset PACKAGE_VERSION
    unset PACKAGE_BIN_URL
    unset PACKAGE_BIN_SHA
    unset PACKAGE_WEBPAGE

    PACKAGE_NAME=$(printf '%s\n' "${filename%-linux-x86_64.tar.xz}" | sed 's|\(.*\)-\(.*\)|\1|')

    PACKAGE_VERSION=$(printf '%s\n' "${filename%-linux-x86_64.tar.xz}" | sed 's|\(.*\)-\(.*\)|\2|')

    PACKAGE_BIN_SHA=$(sha256sum "package/$filename" | cut -d ' ' -f1)

    PACKAGE_BIN_URL="https://github.com/leleliu008/uppm-package-repository-linux-x86_64/releases/download/${RELEASE_VERSION}/${filename}"

    UPPM_PACKAGE_FORMULA_FILEPATH="uppm-formula-repository-linux-x86_64/formula/$PACKAGE_NAME.yml"

    if [ -f "$UPPM_PACKAGE_FORMULA_FILEPATH" ] ; then
        sed_in_place "/version: /c version: $PACKAGE_VERSION" "$UPPM_PACKAGE_FORMULA_FILEPATH"
        sed_in_place "/bin-url: /c bin-url: $PACKAGE_BIN_URL" "$UPPM_PACKAGE_FORMULA_FILEPATH"
        sed_in_place "/bin-sha: /c bin-sha: $PACKAGE_BIN_SHA" "$UPPM_PACKAGE_FORMULA_FILEPATH"
    else
        PPKG_PACKAGE_FORMULA_FILEPATH="ppkg-formula-repository/formula/$PACKAGE_NAME.yml"

        PACKAGE_SUMMARY=$(sed -n '/^summary: /p' "$PPKG_PACKAGE_FORMULA_FILEPATH" | cut -c10-)
        PACKAGE_WEBPAGE=$(sed -n '/^webpage: /p' "$PPKG_PACKAGE_FORMULA_FILEPATH" | cut -c10-)

        [ -z "$PACKAGE_WEBPAGE" ] &&
        PACKAGE_WEBPAGE=$(sed -n '/^git-url: /p' "$PPKG_PACKAGE_FORMULA_FILEPATH" | cut -c10-)

        cat > "$UPPM_PACKAGE_FORMULA_FILEPATH" <<EOF
summary: $PACKAGE_SUMMARY
webpage: $PACKAGE_WEBPAGE
version: $PACKAGE_VERSION
bin-url: $PACKAGE_BIN_URL
bin-sha: $PACKAGE_BIN_SHA
EOF
    fi

    printf '|%s|%s|\n' "$PACKAGE_BIN_SHA" "$filename" >> "$RELEASE_NOTES_FILE"
done

unset TEMP_DIR

TEMP_DIR=$(mktemp -d)

run tar vxf package/gtar-*-linux-x86_64.tar.xz -C "$TEMP_DIR" --strip-components=1
run tar vxf package/gzip-*-linux-x86_64.tar.xz -C "$TEMP_DIR" --strip-components=1
run tar vxf package/xz-*-linux-x86_64.tar.xz -C   "$TEMP_DIR" --strip-components=1

#run gh release create "$RELEASE_VERSION" "$TEMP_DIR/bin/tar" "$TEMP_DIR/bin/gzip" "$TEMP_DIR/bin/xz" package/*.tar.xz --notes-file "$RELEASE_NOTES_FILE"
