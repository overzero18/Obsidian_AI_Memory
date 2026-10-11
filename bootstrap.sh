#!/bin/sh
# Download the latest verified release, then start its normal installer.
# Usage: curl -fsSLO https://raw.githubusercontent.com/overzero18/obsidian-ai-memory-windows/main/bootstrap.sh
#        sh bootstrap.sh [installer options]
set -eu

repository="overzero18/obsidian-ai-memory-windows"
api_url="https://api.github.com/repos/$repository/releases/latest"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/obsidian-ai-memory-bootstrap.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

download() {
    url=$1
    destination=$2
    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --silent --show-error "$url" --output "$destination"
    elif command -v wget >/dev/null 2>&1; then
        wget --quiet --output-document="$destination" "$url"
    else
        echo "Need curl or wget to download the release." >&2
        exit 1
    fi
}

sha256_file() {
    file=$1
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        echo "Need sha256sum (Linux) or shasum (macOS) to verify the download." >&2
        exit 1
    fi
}

command -v unzip >/dev/null 2>&1 || {
    echo "Need unzip to unpack the release." >&2
    exit 1
}

archive="$temp_dir/obsidian-ai-memory.zip"
checksum="$temp_dir/obsidian-ai-memory.zip.sha256"
metadata="$temp_dir/release.json"

echo "Downloading the latest Obsidian AI Memory release..."
download "$api_url" "$metadata"
tag=$(sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$metadata" | awk 'NR == 1 { print; exit }')
if [ -z "$tag" ]; then
    echo "Could not determine the latest release tag." >&2
    exit 1
fi
release_base="https://github.com/$repository/releases/download/$tag"
download "$release_base/obsidian-ai-memory.zip" "$archive"
download "$release_base/obsidian-ai-memory.zip.sha256" "$checksum"

expected=$(awk 'NR == 1 { print $1; exit }' "$checksum")
actual=$(sha256_file "$archive")
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
    echo "Download verification failed. Nothing was installed." >&2
    exit 1
fi

unpack_dir="$temp_dir/release"
mkdir -p "$unpack_dir"
unzip -q "$archive" -d "$unpack_dir"
installer=$(find "$unpack_dir" -type f -name INSTALL.sh -print | awk 'NR == 1 { print; exit }')
if [ -z "$installer" ] || [ ! -f "$installer" ]; then
    echo "The verified archive does not contain INSTALL.sh." >&2
    exit 1
fi

portable=0
for argument in "$@"; do
    [ "$argument" = "--portable" ] && portable=1
done

if [ "$portable" -eq 1 ]; then
    portable_dir="${OBSIDIAN_AI_MEMORY_PORTABLE_DIR:-$PWD/obsidian-ai-memory-portable}"
    if [ -e "$portable_dir" ]; then
        echo "Portable folder already exists: $portable_dir" >&2
        echo "Choose another folder with OBSIDIAN_AI_MEMORY_PORTABLE_DIR or install from the ZIP." >&2
        exit 1
    fi
    mkdir -p "$(dirname "$portable_dir")"
    cp -R "$(dirname "$installer")" "$portable_dir"
    installer="$portable_dir/INSTALL.sh"
    echo "Keeping the portable package in: $portable_dir"
fi

echo "Verified release. Starting the installer..."
exec sh "$installer" "$@"
