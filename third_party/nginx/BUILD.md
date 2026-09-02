# Nginx core build

Fn-Nginx uses Nginx Open Source 1.30.4 compiled from the official nginx.org
source archive. Linux x86_64 and AArch64 builds use the same source checksum,
compiler family, static-linking policy and Nginx module set.

## Source

```text
https://nginx.org/download/nginx-1.30.4.tar.gz
SHA-256: 4261dc90e9e47c1c4041276e9aaa3d48ebe2e664f728e14fa95ae6c67d57a08b
```

## Build environment

```text
Alpine Linux 3.21
GCC 14.2.0
musl libc 1.2.5
OpenSSL 3.3.7
PCRE 8.45
zlib 1.3.2
```

The final executables are stripped static ELF binaries. Static linking avoids
runtime dependencies on the OpenSSL, PCRE, zlib and glibc versions installed by
fnOS.

## Configure arguments

```text
--prefix=.
--sbin-path=nginx
--conf-path=nginx.conf
--pid-path=nginx.pid
--lock-path=nginx.lock
--error-log-path=stderr
--http-log-path=access.log
--http-client-body-temp-path=client_body_temp
--http-proxy-temp-path=proxy_temp
--http-fastcgi-temp-path=fastcgi_temp
--http-uwsgi-temp-path=uwsgi_temp
--http-scgi-temp-path=scgi_temp
--user=nobody
--group=nogroup
--with-cc-opt=-Os -fomit-frame-pointer -pipe
--with-ld-opt=-static -Wl,--as-needed
--with-threads
--with-file-aio
--with-http_ssl_module
--with-http_v2_module
--with-http_realip_module
--with-http_stub_status_module
--with-http_auth_request_module
--with-http_secure_link_module
--with-stream
--with-stream_ssl_module
--with-stream_realip_module
--with-stream_ssl_preread_module
```

`nogroup` is used as the compiled fallback group so configuration tests also
work when the static binary is invoked as root on Debian-based systems. During
normal fnOS operation the Nginx master process runs as the dedicated package
user, so no root privilege is required.

The current UI exposes HTTP/HTTPS reverse proxy features. Stream modules are
compiled into the core for a later TCP/UDP management release, but no Stream
rule editor is enabled in version 0.1.0.

## Published binaries

```text
nginx-1.30.4-x86_64-linux-static
SHA-256: c5224e835cf2fbbf1699803b95f4c1d61ee0b53c12f2490935bff8b298f401ce

nginx-1.30.4-aarch64-linux-static
SHA-256: 78736e949b5efbda202c320de48016a0736a869d7364eb45044a030392fd0475
```

GitHub release tag: `nginx-core-1.30.4-r2`.
