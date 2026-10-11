#!/bin/sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec sh "$script_dir/scripts/install-obsidian-ai-memory.sh" "$@"
