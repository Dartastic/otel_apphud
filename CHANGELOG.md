# Changelog

## [0.1.0-beta.1] - 2026-06-04

### Added

- Initial release.
- `tracedApphud<T>(...)` — wraps a otel_apphud call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutApphudInstrumentation()` / `Async()`.
