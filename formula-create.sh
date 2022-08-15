#!/bin/sh

for item in *-linux-x86_64.tar.xz
do
    unset PKGNAME
    unset VERSION
    unset BIN_URL
    unset BIN_SHA

    VERSION=$(printf '%s\n' "$item" | sed 's|-linux-x86_64.tar.xz||' | awk -F- '{print $NF}')
    PKGNAME=$(printf '%s\n' "$item" | sed "s|-$VERSION-linux-x86_64.tar.xz||")

    BIN_URL="https://github.com/leleliu008/ppkg-core-linux-x86_64/releases/download/2022.05.28/$item"
    BIN_SHA=$(sha256sum $item | cut -d ' ' -f1)

    echo "$PKGNAME"
    echo "$VERSION"
    echo "$BIN_URL"
    echo "$BIN_SHA"
    echo ----------

    cat > "$PKGNAME.yml" <<EOF
summary: 
webpage: 
version: $VERSION
bin-url: $BIN_URL
bin-sha: $BIN_SHA
EOF

done
