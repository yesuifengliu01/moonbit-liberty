"""File-level SDC diagnostics; positions below were hand-counted before the API."""
import json
import math
import pathlib
import shutil
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
CLI = ['node', str(ROOT / 'tools/check-sdc.cjs')]
LIBRARY = ROOT / 'examples/sky130-demo.lib'
NETLIST = ROOT / 'examples/sdc-diagnostic-netlist.json'
SOURCE = ROOT / 'examples/sdc-diagnostic-error.sdc'
rows = []

def invoke(name, files, expected_exit):
    process = subprocess.run(CLI + [str(p) for p in files], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert process.returncode == expected_exit, (name, process.returncode, process.stderr.decode('utf8', errors='replace'))
    payload = json.loads(process.stdout) if process.stdout else None
    rows.append({'case': name, 'exit': process.returncode, 'stdout_bytes': len(process.stdout)})
    return process, payload

def diagnostic(payload, error, position):
    assert payload == {'ok': False, 'schema': 'moonbit.sta.sdc.v1', 'error': error, 'position': position}, payload

build = ROOT / '_build'
build.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ci-sdc-', dir=build) as temporary:
    work = pathlib.Path(temporary)
    tool = work / 'tools/check-sdc.cjs'
    tool.parent.mkdir()
    shutil.copyfile(ROOT / 'tools/check-sdc.cjs', tool)
    help_process = subprocess.run(['node', str(tool), '--help'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
    assert help_process.returncode == 0 and not help_process.stderr
    assert all(value in help_process.stdout for value in [b'UTF-16', b'1-based', b'0-based', b'CRLF', b'no build'])
    rows.append({'case': 'source-only-help', 'exit': 0, 'stdout_bytes': len(help_process.stdout)})

    # The independent prefix calculation is 6+2+48+48+9+2=115 UTF-16 units.
    # It includes CRLF, an emoji comment and a bound supplementary-Unicode port.
    process, bad = invoke('crlf-unicode-file', [LIBRARY, NETLIST, SOURCE], 2)
    assert not process.stderr
    diagnostic(bad, 'Unsupported("SDC flag -min for set_load")', {'line': 6, 'column': 3, 'offset': 115})

    # Correct only the unsupported flag in the input, retaining the actual bytes.
    source = SOURCE.read_bytes()
    good_source = work / 'valid.sdc'
    good_source.write_bytes(source.replace(b'set_load -min', b'set_load'))
    process, good = invoke('valid-unicode-file', [LIBRARY, NETLIST, good_source], 0)
    assert not process.stderr and good['ok'] is True and good['schema'] == 'moonbit.sta.sdc.v1'
    constraints = good['constraints']
    assert constraints['clock']['name'] == 'c'
    assert math.isclose(constraints['clock']['period_seconds'], 2e-9, rel_tol=1e-12)
    assert constraints['input_delays'][0]['port'] == '数😀'
    assert math.isclose(constraints['input_delays'][0]['rise'], 0.2e-9, rel_tol=1e-12)
    assert math.isclose(constraints['output_loads'][0]['rise'], 0.1e-12, rel_tol=1e-12)

    bom_lib, bom_net = work / 'bom.lib', work / 'bom-netlist.json'
    bom_lib.write_bytes(b'\xef\xbb\xbf' + LIBRARY.read_bytes())
    bom_net.write_bytes(b'\xef\xbb\xbf' + NETLIST.read_bytes())
    process, bom = invoke('library-netlist-bom-preserves-sdc', [bom_lib, bom_net, SOURCE], 2)
    assert not process.stderr and bom == bad

    lexical = work / 'lexical.sdc'
    lexical.write_text('# 😀\n\tset_load 0.1 [get_ports y];', encoding='utf8')
    process, payload = invoke('lf-lexical-last-line', [LIBRARY, NETLIST, lexical], 2)
    assert not process.stderr
    diagnostic(payload, 'Unsupported("SDC scripting/quoting is outside the restricted profile")', {'line': 2, 'column': 2, 'offset': 6})

    no_clock = work / 'no-clock.sdc'
    no_clock.write_text('# 😀\n\t# empty profile\n', encoding='utf8')
    process, payload = invoke('global-no-clock', [LIBRARY, NETLIST, no_clock], 2)
    assert not process.stderr
    diagnostic(payload, 'InvalidInput("missing clock")', None)

    invalid_json = work / 'bad-netlist.json'
    invalid_json.write_bytes(b'{')
    process, payload = invoke('netlist-error-has-no-sdc-position', [LIBRARY, invalid_json, SOURCE], 2)
    assert not process.stderr
    diagnostic(payload, 'InvalidInput("invalid netlist JSON")', None)

    invalid_lib = work / 'bad.lib'
    invalid_lib.write_text('library (', encoding='utf8')
    process, payload = invoke('library-error-has-no-sdc-position', [invalid_lib, NETLIST, SOURCE], 2)
    assert not process.stderr and payload['ok'] is False and payload['position'] is None
    assert payload['schema'] == 'moonbit.sta.sdc.v1' and payload['error'].startswith('LibraryFailure(')

    invalid_utf8 = work / 'invalid-utf8.sdc'
    invalid_utf8.write_bytes(b'\xff')
    process, payload = invoke('sdc-invalid-utf8', [LIBRARY, NETLIST, invalid_utf8], 2)
    assert payload is None and b'Invalid UTF-8 in SDC input' in process.stderr
    process, payload = invoke('sdc-missing-file', [LIBRARY, NETLIST, work / 'missing.sdc'], 2)
    assert payload is None and b'ENOENT' in process.stderr

    # Preserve the original analysis boundary and its default error schema.
    request = work / 'legacy-request.json'
    request.write_text(json.dumps({'netlist': json.loads(NETLIST.read_text(encoding='utf8')), 'sdc': source.decode('utf8')}, ensure_ascii=False), encoding='utf8')
    process = subprocess.run(['node', str(ROOT / 'tools/sta.cjs'), str(LIBRARY), str(request)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert process.returncode == 2 and not process.stderr
    assert json.loads(process.stdout) == {'ok': False, 'schema': 'moonbit.sta.v1', 'error': 'Unsupported("SDC flag -min for set_load")'}
    rows.append({'case': 'legacy-analysis-unchanged', 'exit': process.returncode, 'stdout_bytes': len(process.stdout)})

    process = subprocess.Popen(CLI + [str(LIBRARY), str(NETLIST), str(good_source)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.stdout.close()
    process.stdout = None
    _, stderr = process.communicate(timeout=30)
    assert process.returncode == 2 and stderr.startswith(b'stdout: Error:')
    rows.append({'case': 'closed-diagnostic-reader', 'exit': process.returncode, 'stdout_bytes': 0})

receipt = {'all_passed': True, 'real_cli_invocations': len(rows), 'cases': rows, 'expectation_basis': 'Pre-implementation hand counts: CRLF UTF-16 prefix6+2+48+48+9, indent2 => line6 column3 offset115; LF comment5 plus tab1 => line2 column2 offset6; period2ns/input0.2ns/load0.1pF from explicit independent constraints.'}
(build / 'ci-sdc-diagnostics.json').write_text(json.dumps(receipt, indent=2), encoding='utf8')
print(json.dumps(receipt))
