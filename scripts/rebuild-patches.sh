#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WG="$ROOT/WorldGuard"
PATCHES="$ROOT/patches"

BASE="4181ebfe364e6e99c87c1166cad7c5715e54553a"

cd "$WG"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "WorldGuard is not a Git repository."
    exit 1
fi

if ! git cat-file -e "$BASE^{commit}" 2>/dev/null; then
    echo "Base commit does not exist locally:"
    echo "  $BASE"
    echo
    echo "Fetching WorldGuard..."
    git fetch origin version/7.0.x
fi

if ! git cat-file -e "$BASE^{commit}" 2>/dev/null; then
    echo "Base commit still cannot be found:"
    echo "  $BASE"
    exit 1
fi

echo "Upstream base:"
git log -1 --oneline "$BASE"

echo
echo "Custom commits:"
git log --oneline "$BASE"..HEAD

mkdir -p "$PATCHES"

rm -f "$PATCHES"/*.patch

if [ "$BASE" = "$(git rev-parse HEAD)" ]; then
    echo
    echo "No custom commits found. patches/ is empty."
    exit 0
fi

echo
echo "Generating patches..."

git format-patch \
    "$BASE"..HEAD \
    --output-directory "$PATCHES"

echo
echo "Generated patches:"

FOUND=0

for PATCH in "$PATCHES"/*.patch; do
    if [ -f "$PATCH" ]; then
        basename "$PATCH"
        FOUND=1
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "No patches generated."
fi

cd "$ROOT"

echo
echo "Resetting WorldGuard submodule back to base..."
git -C "$WG" reset --hard "$BASE"

echo
echo "Done."