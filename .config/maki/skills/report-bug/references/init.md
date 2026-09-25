# Initialize `bugs/` in a repo

Do this once, the first time the skill is used in a repo.

1. Run `python3 <skill>/scripts/bug.py init`. It creates `bugs/open/` and `bugs/closed/`, detects the test tools, and installs the pytest guard (`bugs/conftest.py`). Override detection with `--tool pytest --tool jest ...` if it guesses wrong.
2. For every `TODO` line it prints (Jest, Vitest, other tools), install that guard by hand per [Test guards in `reproduction.md`](reproduction.md#test-guards).
3. Verify the guard:
   1. Run the project's normal test command. No bug checks should be collected or run.
   2. Run one check directly. It should be collected and run. If no bug exists yet, verify this with the first check you write.
4. Tell the user which guard you installed and what the targeted run command is.
