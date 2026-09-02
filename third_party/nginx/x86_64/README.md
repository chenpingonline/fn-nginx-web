# x86_64 Nginx binary

The executable is intentionally not committed. `scripts/fetch-nginx.sh x86`
downloads the pinned Debian 12 Nginx 1.30.4 archive, extracts only the Nginx
executable, strips debug symbols, and verifies both SHA-256 values. The optional
ACME dynamic module in the upstream archive is not packaged or loaded.
