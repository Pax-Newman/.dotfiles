"""Keep bug checks out of normal test runs.

Bug checks under bugs/ are collected only when a path inside bugs/ is passed
explicitly, e.g. `pytest bugs/open/003-name/check.py`.
"""
from pathlib import Path

_BUGS_DIR = Path(__file__).parent.resolve()


def pytest_ignore_collect(collection_path, config):
    targeted = any(
        _BUGS_DIR in (Path(str(a).split("::")[0]).resolve(), *Path(str(a).split("::")[0]).resolve().parents)
        for a in config.args
    )
    if targeted:
        return None
    return _BUGS_DIR in (collection_path.resolve(), *collection_path.resolve().parents)
