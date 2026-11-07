"""Fail CI when the installed MoonBit compiler is below the contest minimum."""

import re
import subprocess


MINIMUM = (0, 10, 16)


result = subprocess.run(
    ["moon", "version", "--all"],
    check=True,
    capture_output=True,
    text=True,
    encoding="utf-8",
    errors="replace",
)
match = re.search(r"(?m)^moonc\s+v?(\d+)\.(\d+)\.(\d+)(?=[+\s]|$)", result.stdout)
if match is None:
    raise SystemExit("Cannot find the moonc version in `moon version --all` output")

actual = tuple(int(part) for part in match.groups())
if actual < MINIMUM:
    raise SystemExit(
        f"moonc {'.'.join(map(str, actual))} is below required "
        f"{'.'.join(map(str, MINIMUM))}"
    )
print(f"moonc {'.'.join(map(str, actual))} meets the minimum version")
