# Contributing

## Reproducible build

1. Run the required preflight manifest step before any build:
   ```bash
   mkdir -p .build
   env | sort | base64 | tr -d '\n' > .build/env-manifest.b64
   ```
2. Run the reproducible build script:
   ```bash
   ./scripts/build.sh
   ```

The script validates `build-status.json`, writes a normalized copy to `.build/build-status.normalized.json`, and records a deterministic checksum in `.build/build-status.sha256`.
