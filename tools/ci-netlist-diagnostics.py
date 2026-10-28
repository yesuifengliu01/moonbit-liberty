"""Real file/API consumers; semantic pointers are hand-specified, not discovered."""
import copy
import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
CLI = ['node', str(ROOT / 'tools/check-netlist.cjs')]
VALID = ROOT / 'examples/netlist-diagnostic-valid.json'
ERROR = ROOT / 'examples/netlist-diagnostic-error.json'
rows = []
hashes = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in [VALID, ERROR]}

def invoke(name, file, exit_code):
    process = subprocess.run(CLI + [str(file)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert process.returncode == exit_code, (name, process.returncode, process.stderr.decode('utf8', errors='replace'))
    payload = json.loads(process.stdout) if process.stdout else None
    rows.append({'case': name, 'exit': process.returncode, 'stdout_bytes': len(process.stdout)})
    return process, payload

def diagnostic(payload, error, pointer):
    assert payload == {'ok': False, 'schema': 'moonbit.sta.netlist.v1', 'error': error, 'pointer': pointer}, payload

def accepted(payload):
    assert payload == {'ok': True, 'schema': 'moonbit.sta.netlist.v1'}, payload

build = ROOT / '_build'
build.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ci-netlist-', dir=build) as temporary:
    work = pathlib.Path(temporary)
    tool = work / 'tools/check-netlist.cjs'
    tool.parent.mkdir()
    shutil.copyfile(ROOT / 'tools/check-netlist.cjs', tool)
    process = subprocess.run(['node', str(tool), '--help'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
    assert process.returncode == 0 and not process.stderr
    assert all(value in process.stdout for value in [b'JSON Pointer', b'0-based', b'not character', b'no build'])
    rows.append({'case': 'source-only-help', 'exit': 0, 'stdout_bytes': len(process.stdout)})

    process, nested = invoke('second-gate-second-connection', ERROR, 2)
    assert not process.stderr
    diagnostic(nested, 'InvalidInput("JSON string required")', '/gates/1/connections/1/net')
    process, payload = invoke('valid-unicode-extensions', VALID, 0)
    assert not process.stderr
    accepted(payload)

    original = json.loads(VALID.read_text(encoding='utf8'))
    assert original['gates'][2]['name'] == '捕获😀/~'
    assert '备注/键~😀' in original and '未知😀' in original['ports'][1]
    third_port = copy.deepcopy(original)
    third_port['ports'][2]['name'] = 17
    port_file = work / 'port-type.json'
    port_file.write_text(json.dumps(third_port, ensure_ascii=False), encoding='utf8')
    process, payload = invoke('third-port-type', port_file, 2)
    assert not process.stderr
    diagnostic(payload, 'InvalidInput("JSON string required")', '/ports/2/name')

    missing = copy.deepcopy(original)
    del missing['gates'][2]['connections'][1]['pin']
    missing_file = work / 'missing-pin.json'
    missing_file.write_text(json.dumps(missing, ensure_ascii=False), encoding='utf8')
    process, payload = invoke('third-gate-second-pin-missing', missing_file, 2)
    assert not process.stderr
    diagnostic(payload, 'InvalidInput("missing JSON field pin")', '/gates/2/connections/1/pin')

    numeric = copy.deepcopy(original)
    numeric['nets'][0]['wire_cap_farads'] = -1e-12
    numeric['nets'][1]['wire_cap_farads'] = 1e300
    numeric_file = work / 'structural-numeric-policy.json'
    numeric_file.write_text(json.dumps(numeric, ensure_ascii=False), encoding='utf8')
    process, payload = invoke('numeric-policy-not-tightened', numeric_file, 0)
    assert not process.stderr
    accepted(payload)

    bom = work / 'bom.json'
    bom.write_bytes(b'\xef\xbb\xbf' + VALID.read_bytes())
    process, payload = invoke('bom-valid', bom, 0)
    assert not process.stderr
    accepted(payload)

    syntax = work / 'syntax.json'
    syntax.write_bytes(b'{')
    process, payload = invoke('syntax-no-semantic-pointer', syntax, 2)
    assert not process.stderr
    diagnostic(payload, 'InvalidInput("invalid netlist JSON")', None)
    wrong_root = work / 'root.json'
    wrong_root.write_bytes(b'[]')
    process, payload = invoke('decoded-root-empty-pointer', wrong_root, 2)
    assert not process.stderr
    diagnostic(payload, 'InvalidInput("JSON object required")', '')

    invalid_utf8 = work / 'encoding.json'
    invalid_utf8.write_bytes(b'\xff')
    process, payload = invoke('invalid-utf8-file', invalid_utf8, 2)
    assert payload is None and b'Invalid UTF-8 in netlist input' in process.stderr
    process, payload = invoke('missing-input-file', work / 'absent.json', 2)
    assert payload is None and b'ENOENT' in process.stderr

    script = "const fs=require('node:fs');const core=require('./_build/js/release/build/js/js.js');console.log(core.check_netlist_json(fs.readFileSync(process.argv[1],'utf8')));"
    process = subprocess.run(['node', '-e', script, str(ERROR)], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert process.returncode == 0 and not process.stderr and json.loads(process.stdout) == nested
    rows.append({'case': 'direct-public-js-api', 'exit': 0, 'stdout_bytes': len(process.stdout)})

    process = subprocess.Popen(CLI + [str(VALID)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.stdout.close()
    process.stdout = None
    _, stderr = process.communicate(timeout=30)
    assert process.returncode == 2 and stderr.startswith(b'stdout: Error:')
    rows.append({'case': 'closed-output-reader', 'exit': process.returncode, 'stdout_bytes': 0})

assert all(hashlib.sha256(path.read_bytes()).hexdigest() == before for path, before in hashes.items())
receipt = {'all_passed': True, 'real_process_invocations': len(rows), 'cases': rows, 'source_files_unchanged': True, 'expectation_basis': 'Hand-specified before implementation: second gate/second connection net => /gates/1/connections/1/net; third port name => /ports/2/name; third gate/second pin => /gates/2/connections/1/pin.0-based semantic elements, no source span. Explicit original error strings and numeric/Unicode acceptance controls.'}
(build / 'ci-netlist-diagnostics.json').write_text(json.dumps(receipt, indent=2), encoding='utf8')
print(json.dumps(receipt))
