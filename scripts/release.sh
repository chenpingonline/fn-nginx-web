#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; VERSION="${VERSION:-0.1.0}"
"$ROOT/scripts/build.sh" x86
"$ROOT/scripts/build.sh" arm64
"$ROOT/tests/integration.sh"
"$ROOT/tests/fpk-lifecycle.sh" "$ROOT/dist/fnproxy-${VERSION}-x86.fpk"
(cd "$ROOT/dist" && sha256sum "fnproxy-${VERSION}-x86.fpk" "fnproxy-${VERSION}-arm64.fpk" > SHA256SUMS.txt)
echo "Release artifacts created in $ROOT/dist"
