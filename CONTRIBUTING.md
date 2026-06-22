# Contributing

## Reproducible builds

The build is pinned to exact toolchain versions in `/scripts/build.lock`.

Run builds with:

```bash
./scripts/build.sh
```

If runner versions intentionally change, update `/scripts/build.lock` in the same PR.
