# Third-party software notices

Fn-Nginx packages independently running NGINX Open Source 1.30.4 executables
for Linux x86_64 and AArch64. Both executables are built from the same official
source archive, use the same module set, and are statically linked. No
third-party Nginx module is included.

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

## Components statically linked into both NGINX builds

- musl libc 1.2.5-r11 — MIT-style license.
- OpenSSL 3.3.7-r0 — Apache License 2.0.
- PCRE 8.45-r3 — BSD-style license.
- zlib 1.3.2-r0 — zlib License.
- GCC runtime support libraries 14.2.0-r4 — GCC Runtime Library Exception.

The build environment also uses Alpine Linux build tooling and CA certificates;
these are build-time dependencies and are not shipped as separate runtime
packages in the FPK.

Exact source checksum, configure arguments, per-architecture binary checksums
and build provenance are retained in `third_party/nginx/BUILD.md`,
`third_party/nginx/x86_64/` and `third_party/nginx/arm64/`.
