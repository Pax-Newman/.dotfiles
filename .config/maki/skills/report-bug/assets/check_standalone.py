#!/usr/bin/env python3
"""Bug NNN — <title>

Run:  python bugs/open/NNN-name/check.py
Exit 1 while the bug is present, 0 once fixed.
Read secrets (tokens, URLs) from environment variables; never hard-code them.
"""
import sys

CHECKS = []


def check(fn):
    CHECKS.append(fn)
    return fn


@check
def expected_behaviour():
    actual = ...  # call the API / run the code
    expected = ...
    assert actual == expected, f"expected {expected!r}, got {actual!r}"


def main() -> int:
    failed = 0
    for fn in CHECKS:
        try:
            fn()
            print(f"PASS {fn.__name__}")
        except AssertionError as e:
            failed += 1
            print(f"FAIL {fn.__name__}: {e}")
    print(f"{len(CHECKS) - failed}/{len(CHECKS)} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
