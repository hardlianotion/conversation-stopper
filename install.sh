#!/bin/sh
# Install conv-stop into $PREFIX/bin (default ~/.local/bin) and register its Claude Code hook.
#
#   ./install.sh               install, or upgrade in place
#   ./install.sh --uninstall   remove the hook and the installed file
#
# Run from a clone, it installs the conv-stop beside it. Run on its own, e.g.
#   curl -fsSL https://raw.githubusercontent.com/hardlianotion/conversation-stopper/main/install.sh | sh
# it downloads conv-stop from GitHub. The installed copy is standalone: the clone can be deleted.
set -eu

PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"
TARGET="$BIN/conv-stop"
SOURCE_URL="https://raw.githubusercontent.com/hardlianotion/conversation-stopper/main/conv-stop"

if [ "${1:-}" = "--uninstall" ]; then
    if [ -x "$TARGET" ]; then
        "$TARGET" uninstall
    fi
    rm -f "$TARGET"
    echo "removed $TARGET (your conversations in ~/.conv-stop are kept)"
    exit 0
fi

command -v python3 >/dev/null 2>&1 || { echo "conv-stop needs python3 on your PATH" >&2; exit 1; }

mkdir -p "$BIN"
tmp="$(mktemp "$BIN/.conv-stop.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

here="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"
if [ -n "$here" ] && [ -f "$here/conv-stop" ]; then
    cp "$here/conv-stop" "$tmp"
else
    curl -fsSL "$SOURCE_URL" -o "$tmp"
fi
chmod 755 "$tmp"
# replaces a file or an old symlink into a clone
mv -f "$tmp" "$TARGET"
trap - EXIT
echo "installed $TARGET"

"$TARGET" install

case ":$PATH:" in
    *":$BIN:"*) ;;
    *) echo "note: $BIN is not on your PATH; add it to your shell profile to run conv-stop by name" ;;
esac
