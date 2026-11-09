"""Exercise the real Mooncakes archive and reject missing or unsafe contents."""

import pathlib
import subprocess
import sys
import tempfile
import zipfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILD = ROOT / "_build"
VERIFY = ROOT / "tools" / "verify-package.py"
archives = list((BUILD / "publish").glob("*.zip"))
assert len(archives) == 1, f"expected one generated package, found {len(archives)}"
archive = archives[0]


def run(path: pathlib.Path, expected: str | None = None) -> None:
    result = subprocess.run(
        [sys.executable, str(VERIFY), str(path)],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=30,
    )
    if expected is None:
        assert result.returncode == 0, result.stderr
    else:
        assert result.returncode != 0 and expected in result.stderr, (
            path,
            result.returncode,
            result.stderr,
        )


run(archive)
with zipfile.ZipFile(archive) as source:
    entries = [(info.filename, source.read(info.filename)) for info in source.infolist()]

fixtures = {
    "missing-readme": ("missing required file README.md", lambda name, data: None if name == "README.md" else data, None),
    "stale-readme": ("stale or altered required file README.md", lambda name, data: b"stale" if name == "README.md" else data, None),
    "credential": ("credential entry", lambda name, data: data, ("credentials.json", b"dummy")),
    "build-artifact": ("build/cache entry", lambda name, data: data, ("_build/output.js", b"dummy")),
    "unsafe-path": ("unsafe entry name", lambda name, data: data, ("../outside", b"dummy")),
    "missing-graph": ("missing MoonBit source graph.mbt", lambda name, data: None if name == "graph.mbt" else data, None),
    "stale-sdc": ("stale or altered MoonBit source sdc.mbt", lambda name, data: b"stale" if name == "sdc.mbt" else data, None),
    "extra-old-source": ("unexpected MoonBit source legacy.mbt", lambda name, data: data, ("legacy.mbt", b"old")),
}
temporary = pathlib.Path(tempfile.mkdtemp(prefix="package-gate-", dir=BUILD))
assert temporary.resolve().is_relative_to(BUILD.resolve())
try:
    for name, (message, transform, addition) in fixtures.items():
        mutant = temporary / f"{name}.zip"
        with zipfile.ZipFile(mutant, "w", compression=zipfile.ZIP_DEFLATED) as output:
            for entry, data in entries:
                changed = transform(entry, data)
                if changed is not None:
                    output.writestr(entry, changed)
            if addition is not None:
                output.writestr(*addition)
        run(mutant, message)
finally:
    for path in temporary.iterdir():
        path.unlink()
    temporary.rmdir()

print(f"Package gate passed: real archive and {len(fixtures)} rejected mutants")
