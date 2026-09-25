# Reproductions and checks

A reproduction has up to three parts. These rules are fixed.

## 1. Written steps (always)

Under "How to Reproduce" in `note.md`: preconditions, steps, expected vs actual.

## 2. `reproduction.http` (optional)

Use it for bugs visible through an HTTP API. It is for humans to poke at, not a pass/fail signal. Template: `assets/reproduction.http`. Never hard-code secrets; obtain tokens via script blocks or variables.

## 3. `check.<ext>` (expected)

One file, which may contain several checks. Every check must **fail while the bug exists and pass once fixed**.

- Prefer the project's test framework (e.g. pytest, jest, go test) when the bug can be demonstrated **without mocking the faulty part**. Template: `assets/check_pytest.py`.
- Exercise the bug at the boundary where it is observed (HTTP API, CLI output, UI, message queue, file output, public library interface). Calling internal functions directly can skip layers that transform the result, such as serialization, validation, middleware, or framework wiring. A fix could then pass the check while the observed behaviour is still broken. Internal-level checks are fine as additions, but include at least one at the observed boundary when feasible.
- Otherwise, write a standalone script that exits `1` while the bug is present and `0` when fixed. Template: `assets/check_standalone.py`.
- Put the exact run command in a header comment and in the note's "Automated check" section.
- If no honest automated check is feasible (needs production data, manual UI, etc.), say why in the note instead of writing a weak one.
- **Run the check** and paste its failing output into the note. A check that has not been seen failing is not a reproduction.
- The check must run only when targeted. The test guard in `bugs/` keeps it out of normal suite runs; confirm one is installed for the framework you used (see below).

## Test guards

Install a guard when `bugs/` is first created, and again whenever a check uses a test tool that has no guard yet. Choose the least invasive option for each test tool the repo uses. Then **verify**:

1. Run the project's normal test command. No bug checks should be collected or run.
2. Run one check directly. It should be collected and run.

If the normal suite already cannot reach `bugs/` (e.g. pytest `testpaths = tests`, jest `roots: ["<rootDir>/src"]`), still install the guard (config can change later), but note that verification step 1 is trivially satisfied.

### pytest

Copy `assets/bugs-conftest.py` to `bugs/conftest.py`. It ignores everything under `bugs/` unless a path inside `bugs/` was passed on the command line.

```bash
pytest -q --collect-only | grep bugs/        # expect nothing
pytest bugs/open/001-name/check.py -v        # expect it to run
```

### Jest

In the Jest config: `testPathIgnorePatterns: ["/node_modules/", "<rootDir>/bugs/"]`.
The targeted run must override it: `npx jest --rootDir . --testPathIgnorePatterns '/node_modules/' bugs/open/001-name/check.test.ts`.

### Vitest

In `vitest.config.*`: `test: { exclude: [...configDefaults.exclude, "bugs/**"] }`.
Targeted run: `npx vitest run --dir bugs/open/001-name` with a small `bugs/vitest.config.ts` that has no exclude, invoked via `--config bugs/vitest.config.ts`.

### Go

Put `//go:build bugcheck` at the top of each `check_test.go`. `go test ./...` skips it.
Targeted run: `go test -tags bugcheck ./bugs/open/001-name/...`.

### Rust (cargo)

Checks in `bugs/` are outside `tests/` and `src/`, so cargo ignores them by default. Use a standalone script, or mark in-crate tests `#[ignore = "bug NNN"]` and run with `cargo test -- --ignored <name>`.

### Standalone scripts (any language)

Scripts that are not named like test files (e.g. `check.py` with `if __name__ == "__main__"`, `check.sh`) are never collected. Verify that the test runner's filename pattern does not match `check.*`; pytest's default `test_*.py` / `*_test.py` does not.

### Other tools

Find the tool's exclude/ignore setting for paths and add `bugs/`, preferring a config file inside `bugs/` over editing project-wide config. Document the targeted run command in each check's header.
