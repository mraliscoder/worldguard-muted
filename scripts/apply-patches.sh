#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WG="$ROOT/WorldGuard"
PATCHES="$ROOT/patches"

cd "$WG"

if git am --show-current-patch >/dev/null 2>&1; then
    echo "An unfinished git am operation exists."
    echo "Run:"
    echo "  git am --abort"
    echo "or:"
    echo "  git am --continue"
    exit 1
fi

git reset --hard
git clean -fd

PATCH_FILES=("$PATCHES"/*.patch)

if [ ! -e "${PATCH_FILES[0]}" ]; then
    echo "No patches found."
    exit 0
fi

git am "${PATCH_FILES[@]}"

echo
echo "Applied patches successfully."
echo
git log --oneline -10