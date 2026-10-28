"""Real process consumers for the public CLI; expected counts/slack are hand-derived."""
import json
import math
import pathlib
import shutil
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
CLI = ['node', str(ROOT / 'tools/sta.cjs')]
LIBRARY = str(ROOT / 'examples/sky130-demo.lib')
rows = []

def invoke(name, arguments, expected_exit, data=None):
    process = subprocess.run(CLI + arguments, input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert process.returncode == expected_exit, (name, process.returncode, process.stderr.decode('utf8', errors='replace'))
    payload = json.loads(process.stdout) if process.stdout else None
    rows.append({'case': name, 'exit': process.returncode, 'stdout_bytes': len(process.stdout)})
    return process, payload

def summary(payload, status, endpoints, constrained, unknown, violating_edges, violating_pins, worst):
    assert payload['ok'] is True and payload['schema'] == 'moonbit.sta.v1'
    value = payload['setup_summary']
    assert value['status'] == status
    assert (value['endpoint_count'], value['constrained_endpoint_edges'], value['unconstrained_endpoint_edges'], value['violating_endpoint_edges'], value['violating_endpoints']) == (endpoints, constrained, unknown, violating_edges, violating_pins)
    assert math.isclose(value['worst_slack_seconds'], worst, rel_tol=1e-12, abs_tol=1e-22)
    assert math.isclose(value['worst_negative_slack_seconds'], min(0.0, worst), rel_tol=1e-12, abs_tol=1e-22)

build = ROOT / '_build'
build.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ci-help-', dir=build) as temporary:
    tool = pathlib.Path(temporary) / 'tools/sta.cjs'
    tool.parent.mkdir()
    shutil.copyfile(ROOT / 'tools/sta.cjs', tool)
    process = subprocess.run(['node', str(tool), '--help'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
    assert process.returncode == 0 and not process.stderr
    assert all(word in process.stdout for word in [b'--check-setup', b'--request-stdin', b'UTF-8', b'Errors exit 2'])
    rows.append({'case': 'source-only-help', 'exit': 0, 'stdout_bytes': len(process.stdout)})

process, ordinary = invoke('ordinary-negative-slack', [LIBRARY, str(ROOT / 'examples/setup-summary.json')], 0)
assert not process.stderr
summary(ordinary, 'Violated', 3, 6, 0, 3, 2, -0.2e-9)
process, met = invoke('checked-met', ['--check-setup', LIBRARY, str(ROOT / 'examples/setup-check-met.json')], 0)
assert not process.stderr
summary(met, 'Met', 3, 6, 0, 0, 0, 0.8e-9)
process, violated = invoke('checked-violation', ['--check-setup', LIBRARY, str(ROOT / 'examples/setup-summary.json')], 3)
assert not process.stderr and violated == ordinary
process, partial = invoke('checked-partial', ['--check-setup', LIBRARY, str(ROOT / 'examples/setup-summary-partial.json')], 4)
assert not process.stderr
summary(partial, 'PartialCoverage', 1, 1, 1, 0, 0, 0.2e-9)
assert partial['period_budget']['status'] == 'Partial'
assert 'minimum_period_seconds' not in partial['period_budget'] and 'maximum_frequency_hz' not in partial['period_budget']
raw = (ROOT / 'examples/setup-check-utf8bom.json').read_bytes()
assert raw.startswith(b'\xef\xbb\xbf')
process, piped = invoke('bom-request-stdin', ['--check-setup', '--request-stdin', LIBRARY, '-'], 0, raw)
assert not process.stderr and piped == met
process, error = invoke('malformed-json', ['--request-stdin', LIBRARY, '-'], 2, b'{"netlist":')
assert not process.stderr and error['ok'] is False and 'invalid request JSON' in error['error']
process, error = invoke('malformed-utf8', ['--request-stdin', LIBRARY, '-'], 2, b'\xff')
assert error is None and b'Invalid UTF-8 in request input' in process.stderr

process = subprocess.Popen(CLI + ['--check-setup', LIBRARY, str(ROOT / 'examples/setup-check-met.json')], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
process.stdout.close()
process.stdout = None
_, diagnostic = process.communicate(timeout=30)
assert process.returncode == 2 and diagnostic.startswith(b'stdout: Error:')
rows.append({'case': 'closed-report-reader', 'exit': process.returncode, 'stdout_bytes': 0})
receipt = {'all_passed': True, 'real_cli_invocations': len(rows), 'cases': rows, 'expectation_basis': 'published direct-wire constraints in examples: three aliases at periods1/2ns and one rise-only output; known status/IO contracts'}
(build / 'ci-consumers.json').write_text(json.dumps(receipt, indent=2), encoding='utf8')
print(json.dumps(receipt))
