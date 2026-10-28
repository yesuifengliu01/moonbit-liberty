"""Send an existing UTF-8 request as bytes to the setup-check CLI."""
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parents[1]
command = [
    'node', str(root / 'tools/sta.cjs'), '--check-setup', '--request-stdin',
    str(root / 'examples/sky130-demo.lib'), '-',
]
request = (root / 'examples/setup-check-utf8bom.json').read_bytes()
raise SystemExit(subprocess.run(command, input=request).returncode)
