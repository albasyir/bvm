#!/usr/bin/env bash
set -euo pipefail

if [[ ${OS:-} = Windows_NT ]]; then
    echo 'error: Please install using Windows Subsystem for Linux'
    exit 1
fi

# Reset
Color_Off=''

# Regular Colors
Red=''
Green=''
Dim='' # White

# Bold
Bold_White=''
Bold_Green=''

if [[ -t 1 ]]; then
    # Reset
    Color_Off='\033[0m' # Text Reset

    # Regular Colors
    Red='\033[0;31m'   # Red
    Green='\033[0;32m' # Green
    Dim='\033[0;2m'    # White

    # Bold
    Bold_Green='\033[1;32m' # Bold Green
    Bold_White='\033[1m'    # Bold White
fi


error() {
    echo -e "${Red}error${Color_Off}:" "$@" >&2
    exit 1
}

info() {
    echo -e "${Dim}$@ ${Color_Off}"
}

info_bold() {
    echo -e "${Bold_White}$@ ${Color_Off}"
}

success() {
    echo -e "${Green}$@ ${Color_Off}"
}

command -v unzip >/dev/null ||
    error 'unzip is required to install bvm'

if [[ $# -gt 2 ]]; then
    error 'Too many arguments, only 2 are allowed. The first can be a specific tag to install. (e.g. "v0.1" (the legends version)) The second can be a build variant to install. (e.g. "debug-info")'
fi

case $(uname -ms) in
'Darwin x86_64')
    target=darwin-x64
    ;;
'Darwin arm64')
    target=darwin-aarch64
    ;;
'Linux aarch64' | 'Linux arm64')
    target=linux-aarch64
    ;;
'Linux x86_64' | *)
    target=linux-x64
    ;;
esac

if [[ $target = darwin-x64 ]]; then
    # Is this process running in Rosetta?
    # redirect stderr to devnull to avoid error message when not running in Rosetta
    if [[ $(sysctl -n sysctl.proc_translated 2>/dev/null) = 1 ]]; then
        target=darwin-aarch64
        info "Your shell is running in Rosetta 2. Downloading bvm for $target instead"
    fi
fi

GITHUB=${GITHUB-"https://github.com"}
github_repo="$GITHUB/albasyir/bvm"

if [[ $target = darwin-x64 ]]; then
    # If AVX2 isn't supported, use the -baseline build
    if [[ $(sysctl -a | grep machdep.cpu | grep AVX2) == '' ]]; then
        target=darwin-x64-baseline
    fi
fi

if [[ $target = linux-x64 ]]; then
    # If AVX2 isn't supported, use the -baseline build
    if [[ $(cat /proc/cpuinfo | grep avx2) = '' ]]; then
        target=linux-x64-baseline
    fi
fi

exe_name=bvm

if [[ $# = 2 && $2 = debug-info ]]; then
    target=$target-profile
    exe_name=bvm-profile
    info "You requested a debug build of bvm. More information will be shown if a crash occurs."
fi

if [[ $# = 0 ]]; then
    bvm_uri=$github_repo/releases/latest/download/bvm-$target.zip
else
    bvm_uri=$github_repo/releases/download/$1/bvm-$target.zip
fi

install_env=BVM_INSTALL
bin_env=\$$install_env/bin

install_dir=${!install_env:-$HOME/.bvm}
bin_dir=$install_dir/bin
exe=$bin_dir/bvm

if [[ ! -d $bin_dir ]]; then
    mkdir -p "$bin_dir" ||
        error "Failed to create install directory \"$bin_dir\""
fi

curl --fail --location --progress-bar --output "$exe.zip" "$bvm_uri" ||
    error "Failed to download from \"$bvm_uri\""

unzip -oqd "$bin_dir" "$exe.zip" ||
    error 'Failed to extract'

mv "$bin_dir/bvm-$target/$exe_name" "$exe" ||
    error 'Failed to move extracted to destination'

chmod +x "$exe" ||
    error 'Failed to set permissions on executable file'

rm -r "$bin_dir/bvm-$target" "$exe.zip"

tildify() {
    if [[ $1 = $HOME/* ]]; then
        local replacement=\~/

        echo "${1/$HOME\//$replacement}"
    else
        echo "$1"
    fi
}

success "bvm was installed successfully to $Bold_Green$(tildify "$exe")"

if command -v bvm >/dev/null; then
    echo "Run 'bvm' to get started"
    exit
fi

refresh_command=''

tilde_bin_dir=$(tildify "$bin_dir")
quoted_install_dir=\"${install_dir//\"/\\\"}\"

if [[ $quoted_install_dir = \"$HOME/* ]]; then
    quoted_install_dir=${quoted_install_dir/$HOME\//\$HOME/}
fi

