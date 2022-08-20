#!/bin/sh

set -e

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

mkdir core

for item in *.tar.xz
do
    run tar vxf $item --strip-components=1 -C core
done

run core/bin/tree --dirsfirst -L 2

export XMAKE_ROOT=y

export GIT_EXEC_PATH="$PWD/core/libexec/git-core"

export PATH="$PWD/core/bin:$PATH"

printf '%s\n' "$PATH" | tr ':' '\n'

for item in core/bin/*
do
    case $item in
        core/bin/c_rehash)
            # c_rehash is perl script
            ;;
        core/bin/openssl)
            run $item help
            run $item version
            ;;
        core/bin/bzdiff|core/bin/bzgrep|core/bin/bzip2recover|core/bin/bzmore)
            ;;
        core/bin/bzip2)
            run $item --help
            ;;
        core/bin/unzip)
            run $item --help
            ;;
        core/bin/unzipsfx|core/bin/funzip|core/bin/zipinfo|core/bin/zipgrep)
            ;;
        core/bin/git-*)
            ;;
        core/bin/git)
            run $item --help
            run $item --version
            ;;
        core/bin/false)
            ;;
        core/bin/sqlite3)
            run $item --version
            ;;
        core/bin/ninja)
            run $item --version
            ;;
        core/bin/ytasm)
            ;;
        core/bin/ndisasm)
            ;;
        core/bin/rsync-ssl)
            run $item --help
            ;;
        *)
            run $item --help
            run $item --version
    esac
done
