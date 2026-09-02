#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCH="${1:?用法: fetch-nginx.sh <x86|arm64> [目标路径]}"
DEST="${2:-}"
VERSION="1.30.4"
RELEASE_TAG="nginx-core-1.30.4-r1"
RELEASE_BASE="https://github.com/chenpingonline/fn-nginx-web/releases/download/${RELEASE_TAG}"

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

verify_sha256() {
  local file="$1" expected="$2" actual
  actual="$(sha256_file "$file")"
  [[ "$actual" == "$expected" ]] || {
    echo "SHA-256 校验失败：$file" >&2
    echo "期望：$expected" >&2
    echo "实际：$actual" >&2
    exit 1
  }
}

download() {
  local url="$1" output="$2"
  command -v curl >/dev/null 2>&1 || {
    echo "缺少 curl" >&2
    exit 1
  }
  rm -f "$output.tmp"
  curl -fL --retry 5 --retry-delay 2 --connect-timeout 20 "$url" -o "$output.tmp"
  mv "$output.tmp" "$output"
}

case "$ARCH" in
  x86|x86_64|amd64)
    ARCH="x86"
    FILENAME="nginx-${VERSION}-x86_64-linux-static"
    BIN_SHA="8801e2de7cd4aee8153ca6bd68d5c13a0dcf62827e5e8de6bf1fc1e7c1482486"
    ;;
  arm|arm64|aarch64)
    ARCH="arm64"
    FILENAME="nginx-${VERSION}-aarch64-linux-static"
    BIN_SHA="2eb14d5f26aad8066b0a3ce206915a7b591a735ef12fe9d23baf62fac0d6720c"
    ;;
  *)
    echo "不支持的架构：$ARCH（应为 x86 或 arm64）" >&2
    exit 1
    ;;
esac

CACHE="$ROOT/.cache/nginx/$ARCH"
BIN="$CACHE/nginx"
URL="$RELEASE_BASE/$FILENAME"
mkdir -p "$CACHE"

if [[ -n "${NGINX_BINARY:-}" ]]; then
  cp "$NGINX_BINARY" "$BIN"
elif [[ ! -f "$BIN" ]] || ! verify_sha256 "$BIN" "$BIN_SHA" >/dev/null 2>&1; then
  download "$URL" "$BIN"
fi

verify_sha256 "$BIN" "$BIN_SHA"
chmod 755 "$BIN"

if [[ -n "$DEST" ]]; then
  mkdir -p "$(dirname "$DEST")"
  cp "$BIN" "$DEST"
  chmod 755 "$DEST"
  echo "$DEST"
else
  echo "$BIN"
fi
