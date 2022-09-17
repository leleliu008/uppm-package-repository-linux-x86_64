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

for item in package/*.tar.xz
do
    run tar vxf $item --strip-components=1 -C core
done

run core/bin/tree --dirsfirst -L 2

export XMAKE_ROOT=y

export GIT_EXEC_PATH="$PWD/core/libexec/git-core"

export PATH="$PWD/core/bin:$PATH"

printf '%s\n' "$PATH" | tr ':' '\n'

for item in core/bin/* core/sbin/*
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
        core/bin/readtags)
            run $item --help
            ;;
        core/bin/optscript)
            run $item --help
            ;;
        core/bin/gpgparsemail)
            run $item --help
            ;;
        core/bin/strace-log-merge)
            run $item --help
            ;;
        core/bin/darkhttpd)
            run $item --help
            ;;
        core/bin/plink)
            run $item --version
            ;;
        core/bin/pscp)
            run $item --version
            ;;
        core/bin/psftp)
            run $item --version
            ;;
        core/bin/mosh)
            ;;
        core/bin/tmux)
            ;;
        core/bin/unrar)
            ;;
        core/bin/qjs)
            ;;
        core/bin/qjsc)
            ;;
        core/bin/qjscalc)
            ;;
        core/bin/curlie)
            ;;
        core/bin/ctop)
            run $item --help
            run $item -v
            ;;
        core/bin/hugo)
            run $item --help
            run $item version
            ;;
        core/bin/youtubedr)
            run $item --help
            run $item version
            ;;
        core/bin/mpg123-strip)
            run $item --help
            ;;
        core/bin/mpg123-id3dump)
            run $item --help
            ;;
        core/bin/rtmpdump)
            run $item --help
            ;;
        core/sbin/rtmpgw)
            run $item --help
            ;;
        core/sbin/rtmpsrv)
            ;;
        core/sbin/rtmpsuck)
            ;;
        core/sbin/addgnupghome)
            ;;
        core/sbin/applygnupgdefaults)
            ;;
        core/sbin/nologin)
            ;;
        core/bin/zlib-flate)
            run $item --version
            ;;
        core/bin/fix-qdf)
            run $item --version
            ;;
        *)
            run $item --help
            run $item --version
    esac
done
