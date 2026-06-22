# Contributing

## Reproducible build

Run the reproducible build script from the repository root:

```bash
./scripts/build.sh
```

The build script runs diagnostics preflight first and writes `.build/diag.b64`, produces deterministic output at `.build/output/build-status.json`, and caches build artifacts under `.build/cache/<sha256-key>/`.

## Validate build reproducibility

Run:

```bash
./tests/test_build.sh
```
