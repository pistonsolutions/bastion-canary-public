# Contributing

Thanks for contributing to this repository.

## Build validation

This project uses `build-status.json` as build metadata. Before submitting
changes, validate it from the repository root:

```bash
./scripts/setup.sh
```

The setup script runs `scripts/validate-build.sh`, which checks that:

- `build-status.json` is valid JSON
- the JSON document is an object
- the required `status` field is present

You can also validate a specific file path:

```bash
./scripts/validate-build.sh /path/to/build-status.json
```

## Tests

Run the basic validation test:

```bash
./tests/validate-build-test.sh
```
