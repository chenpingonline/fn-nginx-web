# Third-party software notices

FnProxy packages an independently running NGINX Open Source 1.30.4 executable.
The x86_64 build is dynamically linked against libraries supplied by the target
system. The ARM64 build is a static executable and therefore contains the
additional components listed below.

## NGINX Open Source 1.30.4

Copyright (C) 2002-2021 Igor Sysoev
Copyright (C) 2011-2026 Nginx, Inc.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Components statically linked into the ARM64 NGINX build

- njs 0.9.9 — BSD 2-Clause style license.
- nginx-auth-jwt 0.14.2 — MIT License.
- nginx-keyval 0.5.0 — MIT License.
- ngx_devel_kit 0.3.4 — BSD 3-Clause license.
- echo-nginx-module 0.65 — BSD 2-Clause style license.
- headers-more-nginx-module 0.40 — BSD license.
- set-misc-nginx-module 0.34 — BSD-style license.
- musl libc 1.2.5-r11 — MIT-style license.
- OpenSSL 3.3.7-r0 — Apache License 2.0.
- jansson 2.14-r4 — MIT License.
- PCRE 8.45-r3 — BSD-style license.
- zlib 1.3.2-r0 — zlib License.
- GCC runtime support libraries 14.2.0-r4 — GCC Runtime Library Exception.

Exact source locations, versions and hashes are retained in
`third_party/nginx/arm64/SOURCES.txt` and copied into ARM64 FPK artifacts.
