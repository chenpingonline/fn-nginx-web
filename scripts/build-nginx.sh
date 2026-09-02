#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCH="${1:-x86}"
VERSION="${NGINX_VERSION:-1.30.4}"
SOURCE_SHA="4261dc90e9e47c1c4041276e9aaa3d48ebe2e664f728e14fa95ae6c67d57a08b"

case "$ARCH" in
  x86|x86_64|amd64)
    PLATFORM="linux/amd64"
    OUTPUT_ARCH="x86_64"
    ;;
  arm|arm64|aarch64)
    PLATFORM="linux/arm64"
    OUTPUT_ARCH="aarch64"
    ;;
  *)
    echo "不支持的架构：$ARCH（应为 x86 或 arm64）" >&2
    exit 1
    ;;
esac

command -v docker >/dev/null 2>&1 || {
  echo "缺少 Docker。源码静态编译需要 Docker Buildx。" >&2
  exit 1
}
docker buildx version >/dev/null 2>&1 || {
  echo "缺少 Docker Buildx。" >&2
  exit 1
}

WORK="$(mktemp -d "${TMPDIR:-/tmp}/fn-nginx-core.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
OUT_DIR="$ROOT/dist/nginx-core"
mkdir -p "$OUT_DIR"

cat > "$WORK/Dockerfile" <<'DOCKERFILE'
# syntax=docker/dockerfile:1
FROM alpine:3.21 AS build
ARG NGINX_VERSION
ARG SOURCE_SHA
ARG OUTPUT_ARCH
ENV SOURCE_DATE_EPOCH=1786814640
RUN apk add --no-cache \
      build-base linux-headers curl ca-certificates file binutils \
      openssl-dev openssl-libs-static pcre-dev zlib-dev zlib-static
WORKDIR /build
RUN curl -fL --retry 5 --retry-delay 2 \
      -o nginx.tar.gz "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && echo "${SOURCE_SHA}  nginx.tar.gz" | sha256sum -c - \
    && tar -xzf nginx.tar.gz
WORKDIR /build/nginx-${NGINX_VERSION}
RUN ./configure \
      --prefix=. \
      --sbin-path=nginx \
      --conf-path=nginx.conf \
      --pid-path=nginx.pid \
      --lock-path=nginx.lock \
      --error-log-path=stderr \
      --http-log-path=access.log \
      --http-client-body-temp-path=client_body_temp \
      --http-proxy-temp-path=proxy_temp \
      --http-fastcgi-temp-path=fastcgi_temp \
      --http-uwsgi-temp-path=uwsgi_temp \
      --http-scgi-temp-path=scgi_temp \
      --user=nobody \
      --group=nobody \
      --with-cc-opt='-Os -fomit-frame-pointer -pipe' \
      --with-ld-opt='-static -Wl,--as-needed' \
      --with-threads \
      --with-file-aio \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_realip_module \
      --with-http_stub_status_module \
      --with-http_auth_request_module \
      --with-http_secure_link_module \
      --with-stream \
      --with-stream_ssl_module \
      --with-stream_realip_module \
      --with-stream_ssl_preread_module \
    && make -j2 \
    && strip objs/nginx
RUN mkdir -p /out \
    && install -m 0755 objs/nginx "/out/nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static" \
    && "/out/nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static" -V \
         > "/out/nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static.build-info.txt" 2>&1 \
    && file "/out/nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static" \
         > "/out/nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static.file.txt" \
    && cd /out \
    && sha256sum "nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static" \
         > "nginx-${NGINX_VERSION}-${OUTPUT_ARCH}-linux-static.sha256"
FROM scratch
COPY --from=build /out/ /
DOCKERFILE

echo "正在编译 Nginx $VERSION：$PLATFORM"
echo "首次跨架构构建若提示 exec format error，请先安装 QEMU binfmt："
echo "  docker run --privileged --rm tonistiigi/binfmt --install all"

docker buildx build \
  --platform "$PLATFORM" \
  --build-arg "NGINX_VERSION=$VERSION" \
  --build-arg "SOURCE_SHA=$SOURCE_SHA" \
  --build-arg "OUTPUT_ARCH=$OUTPUT_ARCH" \
  --provenance=false \
  --no-cache \
  --output "type=local,dest=$WORK/output" \
  -f "$WORK/Dockerfile" "$WORK"

cp -a "$WORK/output/." "$OUT_DIR/"
BINARY="$OUT_DIR/nginx-${VERSION}-${OUTPUT_ARCH}-linux-static"
file "$BINARY"
cat "$BINARY.build-info.txt"
(cd "$OUT_DIR" && sha256sum -c "$(basename "$BINARY.sha256")")
echo "编译完成：$BINARY"
