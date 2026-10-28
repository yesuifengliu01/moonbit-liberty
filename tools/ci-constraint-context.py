"""Actual causal-context consumers, with predeclared hand graph/edge/SI facts."""
import hashlib
import json
import math
import pathlib
import shutil
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
CLI = ['node', str(ROOT / 'tools/constraint-context.cjs')]
LIB = ROOT / 'examples/constraint-context.lib'
NET = ROOT / 'examples/constraint-context-netlist.json'
PARTIAL = ROOT / 'examples/constraint-context-partial.sdc'
COMPLETE = ROOT / 'examples/constraint-context-complete.sdc'
original_hashes = {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in [LIB, NET, PARTIAL, COMPLETE]}
rows, contexts, legacy = [], {}, {}

def invoke(name, files, expected_exit):
    p = subprocess.run(CLI + [str(f) for f in files], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert p.returncode == expected_exit, (name, p.returncode, p.stderr.decode('utf8', errors='replace'))
    payload = json.loads(p.stdout) if p.stdout else None
    rows.append({'case': name, 'exit': p.returncode, 'stdout_bytes': len(p.stdout)})
    return p, payload

def near(actual, expected):
    assert math.isclose(actual, expected, rel_tol=0.0, abs_tol=1e-22), (actual, expected)

def witness(value, pins, edges, arcs, delays):
    assert value['kind'] == 'MissingInputDelay' and value['port'] == 'a/~😀'
    assert value['pin'] == 'a~1~0😀' and value['edge'] == 'Fall'
    path = value['path']
    assert [s['pin'] for s in path] == pins
    assert [s['edge'] for s in path] == edges
    assert [s['arc'] for s in path] == arcs
    for step, expected in zip(path, delays, strict=True):
        if expected is None:
            assert 'delay_seconds' not in step
        else:
            near(step['delay_seconds'], expected)

with tempfile.TemporaryDirectory(prefix='ci-context-', dir=ROOT / '_build') as temporary:
    work = pathlib.Path(temporary)
    source_tool = work / 'tools/constraint-context.cjs'
    source_tool.parent.mkdir()
    shutil.copyfile(ROOT / 'tools/constraint-context.cjs', source_tool)
    p = subprocess.run(['node', str(source_tool), '--help'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
    assert p.returncode == 0 and not p.stderr
    assert all(v in p.stdout for v in [b'causal launch witness', b'PartialCoverage', b'not timed arrivals', b'no build'])
    rows.append({'case': 'source-only-help', 'exit': 0, 'stdout_bytes': len(p.stdout)})

    for name, source, expected_status, old_exit in [('partial', PARTIAL, 'PartialCoverage', 4), ('complete', COMPLETE, 'Met', 0)]:
        p, result = invoke(name, [LIB, NET, source], 0)
        assert not p.stderr and result['ok'] is True and result['schema'] == 'moonbit.sta.constraint-context.v1'
        assert result['setup_summary']['status'] == expected_status
        contexts[name] = result
        request = work / (name + '.json')
        request.write_text(json.dumps({'netlist': json.loads(NET.read_text(encoding='utf8')), 'sdc': source.read_text(encoding='utf8'), 'period_budget': True, 'setup_summary': True}, ensure_ascii=False), encoding='utf8')
        p = subprocess.run(['node', str(ROOT / 'tools/sta.cjs'), '--check-setup', str(LIB), str(request)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
        assert p.returncode == old_exit and not p.stderr
        legacy[name] = json.loads(p.stdout)
        assert result['result'] == legacy[name]['result'] and result['setup_summary'] == legacy[name]['setup_summary']
        rows.append({'case': 'legacy-' + name, 'exit': p.returncode, 'stdout_bytes': len(p.stdout)})

    partial = contexts['partial']
    gaps = partial['constraint_context']
    assert len(gaps) == 2 and partial['setup_summary']['unconstrained_endpoint_edges'] == 2
    assert (gaps[0]['pin'], gaps[0]['edge']) == ('out~1~0😀', 'Rise')
    assert 'missing_output_delay_port' not in gaps[0]
    witness(gaps[0]['launch_witness'], ['a~1~0😀', 'inv~1~0😀/A', 'inv~1~0😀/Y', 'out~1~0😀'], ['Fall', 'Fall', 'Rise', 'Rise'], ['source', 'net', 'A->Y', 'net'], [None, 0.0, 0.2e-9, 0.0])
    assert (gaps[1]['pin'], gaps[1]['edge'], gaps[1]['missing_output_delay_port']) == ('alias~1#', 'Fall', 'alias/#')
    witness(gaps[1]['launch_witness'], ['a~1~0😀', 'alias~1#'], ['Fall', 'Fall'], ['source', 'net'], [None, 0.0])
    assert contexts['complete']['constraint_context'] == []
    for edge in ['Rise', 'Fall']:
        endpoint = next(e for e in contexts['complete']['result']['endpoints'] if e['pin'] == 'out~1~0😀' and e['edge'] == edge)
        near(endpoint['arrival_seconds'], 0.8e-9)
        near(endpoint['required_seconds'], 1.8e-9)
        near(endpoint['slack_seconds'], 1.0e-9)
        endpoint = next(e for e in contexts['complete']['result']['endpoints'] if e['pin'] == 'alias~1#' and e['edge'] == edge)
        near(endpoint['arrival_seconds'], 0.6e-9)
        near(endpoint['slack_seconds'], 1.2e-9)

    script = "const fs=require('node:fs');const core=require('./_build/js/release/build/js/js.js');console.log(core.analyze_constraint_context_json(...process.argv.slice(1).map(x=>fs.readFileSync(x,'utf8'))));"
    p = subprocess.run(['node', '-e', script, str(LIB), str(NET), str(PARTIAL)], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    assert p.returncode == 0 and not p.stderr and json.loads(p.stdout) == partial
    rows.append({'case': 'direct-public-js-api', 'exit': 0, 'stdout_bytes': len(p.stdout)})

    bom_lib, bom_net = work / 'bom.lib', work / 'bom-netlist.json'
    bom_lib.write_bytes(b'\xef\xbb\xbf' + LIB.read_bytes())
    bom_net.write_bytes(b'\xef\xbb\xbf' + NET.read_bytes())
    p, result = invoke('library-netlist-bom', [bom_lib, bom_net, PARTIAL], 0)
    assert not p.stderr and result == partial

    invalid = work / 'invalid.json'
    invalid.write_bytes(b'{')
    p, result = invoke('invalid-json', [LIB, invalid, PARTIAL], 2)
    assert not p.stderr and result == {'ok': False, 'schema': 'moonbit.sta.constraint-context.v1', 'error': 'InvalidInput("invalid netlist JSON")'}
    transition = work / 'missing-transition.sdc'
    transition.write_text('\n'.join(line for line in PARTIAL.read_text(encoding='utf8').splitlines() if not line.startswith('set_input_transition')) + '\n', encoding='utf8')
    p, result = invoke('same-transition-error', [LIB, NET, transition], 2)
    assert not p.stderr and result == {'ok': False, 'schema': 'moonbit.sta.constraint-context.v1', 'error': 'InvalidInput("missing input transition for a/~😀")'}
    encoding = work / 'invalid-utf8.sdc'
    encoding.write_bytes(b'\xff')
    p, result = invoke('invalid-utf8', [LIB, NET, encoding], 2)
    assert result is None and b'Invalid UTF-8 in SDC input' in p.stderr
    p, result = invoke('missing-file', [LIB, NET, work / 'absent.sdc'], 2)
    assert result is None and b'ENOENT' in p.stderr
    p = subprocess.Popen(CLI + [str(LIB), str(NET), str(COMPLETE)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p.stdout.close()
    p.stdout = None
    _, stderr = p.communicate(timeout=30)
    assert p.returncode == 2 and stderr.startswith(b'stdout: Error:')
    rows.append({'case': 'closed-output-reader', 'exit': p.returncode, 'stdout_bytes': 0})

assert all(hashlib.sha256(path.read_bytes()).hexdigest() == before for path, before in original_hashes.items())
receipt = {'all_passed': True, 'real_process_invocations': len(rows), 'cases': rows, 'source_files_unchanged': True, 'legacyReports': legacy, 'contextReports': contexts, 'expectation_basis': 'Preimplementation hand INV/alias: missing input Fall -> inverted Rise via0.2ns arc; direct alias Fall also lacks output delay. Period2ns - output0.2ns => required1.8ns; input0.6ns -> INV0.8ns/slack1ns, alias slack1.2ns. No missing launch value/arrival is filled with zero.'}
(ROOT / '_build/ci-constraint-context.json').write_text(json.dumps(receipt, indent=2), encoding='utf8')
print(json.dumps({'all_passed': True, 'real_process_invocations': len(rows), 'cases': rows, 'source_files_unchanged': True}))
