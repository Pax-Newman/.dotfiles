"""Bug NNN — <title>

Run:  pytest bugs/open/NNN-name/check.py -v
Each test FAILS while the bug is present and PASSES once fixed.
Reuse the project's fixtures; do not mock the component that contains the bug.
"""


def test_expected_behaviour():
    result = ...  # exercise the real code path
    assert result == ..., "describe the correct behaviour"


def test_edge_case_variant():
    ...
