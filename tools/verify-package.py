"""Verify the actual Mooncakes archive produced by `moon package --list`."""

import argparse
import os
import pathlib
import re
import stat
import zipfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
REQUIRED = (
    "moon.mod",
    "moon.pkg",
    "engine.mbt",
    "README.md",
    "LICENSE",
    "NOTICE",
    "examples/sky130-demo.lib",
    "examples/sequential.json",
    "tools/sta.cjs",
)
FORBIDDEN_DIRECTORIES = {
    "_build", ".git", ".mooncakes", ".repos", "node_modules", "__pycache__"
}
FORBIDDEN_FILES = {"credentials.json", ".env", "id_rsa", "id_ed25519"}


def fail(message: str) -> None:
    raise SystemExit("Mooncakes archive: " + message)


def default_archive() -> pathlib.Path:
    module = (ROOT / "moon.mod").read_text(encoding="utf-8")

    def field(key: str) -> str:
        match = re.search(rf'(?m)^{key}\s*=\s*"([^"]+)"\s*$', module)
        if match is None:
            fail(f"moon.mod has no {key} field")
        return match.group(1)

    name = field("name").replace("/", "-")
    return ROOT / "_build" / "publish" / f"{name}-{field('version')}.zip"


def moonbit_source(name: str) -> bool:
    return name.endswith((".mbt", ".mbti", ".mbt.md")) or name == "moon.pkg" or name.endswith("/moon.pkg")


def local_moonbit_sources() -> set[str]:
    sources = set()
    for directory, children, files in os.walk(ROOT):
        children[:] = [
            child for child in children
            if child.lower() not in FORBIDDEN_DIRECTORIES
        ]
        for file in files:
            path = pathlib.Path(directory) / file
            name = path.relative_to(ROOT).as_posix()
            if moonbit_source(name):
                sources.add(name)
    return sources


def verify(archive: pathlib.Path) -> int:
    if not archive.is_file():
        fail(f"missing {archive}")
    try:
        with zipfile.ZipFile(archive) as package:
            infos = package.infolist()
            names = [info.filename for info in infos]
            if len(names) != len(set(names)):
                fail("duplicate entry names")
            for info in infos:
                name = info.filename
                parts = name.rstrip("/").split("/")
                if (
                    name.startswith("/")
                    or "\\" in name
                    or ":" in name
                    or any(part in ("", ".", "..") for part in parts)
                ):
                    fail(f"unsafe entry name {name!r}")
                if any(part.lower() in FORBIDDEN_DIRECTORIES for part in parts):
                    fail(f"build/cache entry {name!r}")
                if parts[-1].lower() in FORBIDDEN_FILES:
                    fail(f"credential entry {name!r}")
                if stat.S_ISLNK(info.external_attr >> 16):
                    fail(f"symlink entry {name!r}")
            for name in REQUIRED:
                if name not in names:
                    fail(f"missing required file {name}")
                actual = package.read(name)
                if not actual:
                    fail(f"empty required file {name}")
                if actual != (ROOT / name).read_bytes():
                    fail(f"stale or altered required file {name}")
            expected_sources = local_moonbit_sources()
            archived_sources = {name for name in names if moonbit_source(name)}
            missing = sorted(expected_sources - archived_sources)
            if missing:
                fail(f"missing MoonBit source {missing[0]}")
            extra = sorted(archived_sources - expected_sources)
            if extra:
                fail(f"unexpected MoonBit source {extra[0]}")
            for name in sorted(expected_sources):
                if package.read(name) != (ROOT / name).read_bytes():
                    fail(f"stale or altered MoonBit source {name}")
            corrupt = package.testzip()
            if corrupt is not None:
                fail(f"corrupt entry {corrupt}")
    except zipfile.BadZipFile as error:
        fail(f"invalid ZIP: {error}")
    return len(infos)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", nargs="?", type=pathlib.Path, default=default_archive())
    args = parser.parse_args()
    count = verify(args.archive)
    print(f"Verified Mooncakes archive: {args.archive} ({count} entries)")
