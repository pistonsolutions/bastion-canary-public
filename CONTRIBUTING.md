# Contributing

## Build

Use the reproducible build script:

```bash
./scripts/build.sh
```

The script writes the artifact to `.build/output/build-status.json` and uses a cache in `.build/cache/<cache-key>/build-status.json`.

If build inputs do not change, repeated builds are served from cache (`build cache: hit`) for faster local iterations.
