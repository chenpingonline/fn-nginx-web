#!/usr/bin/env bash
set -euo pipefail
VERSION="${NGINX_VERSION:-1.30.4}"; ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; WORK="${WORK_DIR:-/tmp/fnproxy-nginx-build}"; OUT="$ROOT/dist/nginx-${VERSION}-x86_64-linux"
sudo apt-get update
sudo apt-get install -y --no-install-recommends build-essential ca-certificates curl libpcre2-dev libssl-dev zlib1g-dev
rm -rf "$WORK"; mkdir -p "$WORK" "$ROOT/dist"; cd "$WORK"
curl -fsSLO "https://nginx.org/download/nginx-${VERSION}.tar.gz"; tar -xzf "nginx-${VERSION}.tar.gz"; cd "nginx-${VERSION}"
./configure --prefix=.. --conf-path=nginx.conf --pid-path=run/nginx.pid --lock-path=run/nginx.lock --http-log-path=logs/access.log --error-log-path=logs/error.log --http-client-body-temp-path=temp/body --http-proxy-temp-path=temp/proxy --http-fastcgi-temp-path=temp/fastcgi --http-scgi-temp-path=temp/scgi --http-uwsgi-temp-path=temp/uwsgi --with-pcre-jit --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_auth_request_module
make -j"$(nproc)"; strip objs/nginx; install -m 755 objs/nginx "$OUT"; install -m 644 conf/mime.types "$ROOT/third_party/nginx/mime.types"; "$OUT" -V; sha256sum "$OUT"
