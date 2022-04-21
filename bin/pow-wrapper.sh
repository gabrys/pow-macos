#!/usr/bin/env bash

set -eo pipefail
shopt -s nullglob

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)
    os="linux"
      ;;
  Darwin-x86_64)
    os="macos-intel"
      ;;
  Darwin-arm64)
    os="macos-arm64"
      ;;
  *)
    os=""
      ;;
esac

if [ "$os" = "" ]; then
  die "Unsupported OS/CPU. Only x86_64 Linux, Intel Macs, and M1 Macs are supported by this wrapper"
fi

readlink_f() {
  (
    local script_dir="$(dirname "$1")"
    local target_file="$(readlink "$1")"
    local recursion="$2"
    ((recursion++))

    cd "$script_dir"
    cd "$(dirname "$target_file")"

    local abs_target="$(pwd -P)/$(basename "$target_file")"
    if [ "$recursion" -lt 10 ] && [ -L "$abs_target" ]; then
      readlink_f "$abs_target" "$recursion"
    else
      echo "$abs_target"
    fi
  )
}

pow_dir="$(dirname "$(readlink_f "$0")")"
exec "$pow_dir/../$os/pow-runner" "$pow_dir/../src/pow.py" "$@"
