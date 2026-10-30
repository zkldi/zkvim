#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
export HOME="$tmp/home"
export XDG_CONFIG_HOME="$tmp/config"
mkdir -p "$HOME"
sh "$root/bin/install"
test "$(readlink "$XDG_CONFIG_HOME/zkvim")" = "$root"
test ! -e "$HOME/.local/bin"
sh "$root/bin/install"
rm "$XDG_CONFIG_HOME/zkvim"
mkdir "$XDG_CONFIG_HOME/zkvim"
printf 'keep\n' > "$XDG_CONFIG_HOME/zkvim/sentinel"
if sh "$root/bin/install"; then
  printf 'FAIL: installer replaced an existing directory\n' >&2
  exit 1
fi
test "$(cat "$XDG_CONFIG_HOME/zkvim/sentinel")" = keep
rmdir "$XDG_CONFIG_HOME/zkvim" 2>/dev/null && exit 1
printf 'PASS installer is idempotent, refuses conflicts, and does not install a launcher\n'
