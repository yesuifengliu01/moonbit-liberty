"""Install the pinned official Linux SDK into a new private directory."""
import argparse
import hashlib
import json
import os
import pathlib
import stat
import subprocess
import tarfile
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument('--destination', required=True, type=pathlib.Path)
parser.add_argument('--archive-cache', type=pathlib.Path)
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[1]
spec = json.loads((root / 'tools/ci-toolchain.json').read_text(encoding='utf8'))
destination = args.destination.resolve()
if destination.exists() and any(destination.iterdir()):
    raise SystemExit('Refusing to replace a nonempty SDK directory')
destination.mkdir(parents=True, exist_ok=True)
downloads = (args.archive_cache or destination.parent / 'liberty-sdk-downloads').resolve()
downloads.mkdir(parents=True, exist_ok=True)
for name, target in [('sdk', destination), ('core', destination / 'lib')]:
    archive = downloads / (name + '.tar.gz')
    if not archive.exists():
        request = urllib.request.Request(spec[name + '_url'], headers={'User-Agent': 'liberty-ci'})
        with urllib.request.urlopen(request, timeout=120) as response, archive.open('xb') as output:
            while block := response.read(1024 * 1024):
                output.write(block)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    if digest != spec[name + '_sha256']:
        raise SystemExit(name + ' archive SHA256 mismatch')
    target.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive) as package:
        package.extractall(target, filter='data')
for binary in (destination / 'bin').rglob('*'):
    if binary.is_file():
        binary.chmod(binary.stat().st_mode | stat.S_IXUSR)
environment = os.environ.copy()
environment['MOON_HOME'] = str(destination)
environment['XDG_CACHE_HOME'] = str(destination.parent / 'xdg-cache')
environment['PATH'] = str(destination / 'bin') + os.pathsep + environment['PATH']
moon = str(destination / 'bin/moon')
subprocess.run([moon, '-C', str(destination / 'lib/core'), 'bundle', '--warn-list', '-a', '--all'], env=environment, check=True)
subprocess.run([moon, '-C', str(destination / 'lib/core'), 'bundle', '--warn-list', '-a', '--target', 'wasm-gc', '--quiet'], env=environment, check=True)
subprocess.run([moon, 'version', '--all'], env=environment, check=True)
(destination / '.liberty-ci-sdk.json').write_text(json.dumps(spec, indent=2), encoding='utf8')
print('Installed official MoonBit ' + spec['sdk_version'] + ' into ' + str(destination))
