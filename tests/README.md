# Tests

- `go test ./...`: validation and Nginx rendering unit tests.
- `integration.sh`: starts the real bundled Nginx, calls the management API through a Unix Socket, and verifies HTTP and HTTPS reverse proxying.
