"""Real public-package/four-file receivers against frozen hand expectations.

This program validates constants and returned steps; it implements no timing or
path search. All process outputs survive assertion failures under _build.
"""
import hashlib
import json
import math
import pathlib
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
CATALOG = ROOT / 'examples/path-query-cases.json'
catalog = json.loads(CATALOG.read_text(encoding='utf8'))
OUTPUT = ROOT / '_build' / (sys.argv[1] if len(sys.argv) == 2 else 'path-query-receipts')
assert OUTPUT.resolve().is_relative_to((ROOT / '_build').resolve())
OUTPUT.mkdir(parents=True, exist_ok=False)
CLI = ['node', str(ROOT / 'tools/path-query.cjs')]
rows = []


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def save_receipt(passed=False):
    receipt = {'all_passed': passed, 'self_authored_integration': True,
               'third_party_adoption': False, 'frozen_cases': len(catalog['cases']),
               'catalog_sha256': digest(CATALOG.read_bytes()),
               'real_process_invocations': len(rows), 'rows': rows}
    (ROOT / '_build/ci-path-query.json').write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + '\n', encoding='utf8')


def record(name, process, stdout, stderr):
    out = OUTPUT / (name + '.stdout')
    err = OUTPUT / (name + '.stderr')
    out.write_bytes(stdout)
    err.write_bytes(stderr)
    rows.append({'case': name, 'exit': process.returncode,
                 'stdout': str(out.relative_to(ROOT)), 'stdout_bytes': len(stdout), 'stdout_sha256': digest(stdout),
                 'stderr': str(err.relative_to(ROOT)), 'stderr_bytes': len(stderr), 'stderr_sha256': digest(stderr)})
    save_receipt()


def invoke(name, command, expected_exit, cwd):
    process = subprocess.run(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=45)
    record(name, process, process.stdout, process.stderr)
    assert process.returncode == expected_exit, (name, process.returncode, process.stderr)
    return process


def near(actual, expected):
    assert isinstance(actual, (int, float)) and math.isfinite(actual)
    assert math.isclose(actual, expected, rel_tol=0, abs_tol=catalog['absolute_tolerance_seconds']), (actual, expected)


def report_identity(point):
    def part(raw):
        return raw.replace('~', '~0').replace('/', '~1')
    if point['kind'] in ['input_port', 'output_port']:
        return part(point['name'])
    return part(point['instance']) + '/' + part(point['pin'])


def receive(analysis, case):
    expected = case['expected']
    query = analysis['path_query']
    assert query['status'] == expected['status'], case['name']
    for label, point in [('launch', case['query']['from']), ('capture', case['query']['to'])]:
        assert query[label + '_pin'] == report_identity(point)
        assert query[label + '_edge'] == point['edge'].capitalize()
    path = query['path']
    if expected['status'] != 'Found':
        assert path == []
        assert not any(k in query for k in ['queried_arrival_seconds', 'required_seconds', 'queried_slack_seconds'])
        return
    for key in ['queried_arrival_seconds', 'required_seconds', 'queried_slack_seconds']:
        if expected[key] is None:
            assert key not in query
        else:
            near(query[key], expected[key])
    assert len(path) == len(expected['pins'])
    assert [s['pin'] for s in path] == expected['pins']
    assert [s['edge'] for s in path] == expected['edges']
    assert [s['arc'] for s in path] == expected['arcs']
    for step, delay, arrival in zip(path, expected['delays_seconds'], expected['arrivals_seconds'], strict=True):
        near(step['delay_seconds'], delay)
        near(step['arrival_seconds'], arrival)


source_hashes = {str(p.relative_to(ROOT)): digest(p.read_bytes()) for p in [CATALOG, ROOT/'examples/path-query.lib', ROOT/'examples/path-query-netlist.json', ROOT/'examples/path-query.sdc', ROOT/'examples/path-query.json']}
results = {}
inputs = {}
for case in catalog['cases']:
    directory = OUTPUT / 'inputs' / case['name']
    directory.mkdir(parents=True)
    files = [directory / name for name in ['库.lib', '网表.json', '约束.sdc', '查询.json']]
    texts = [catalog['libraries'][case['library']], json.dumps(catalog['netlists'][case['netlist']], ensure_ascii=False), catalog['sdc'][case['sdc']], json.dumps(case['query'], ensure_ascii=False)]
    for file, text in zip(files, texts, strict=True):
        file.write_bytes(text.encode('utf8'))
    before = [digest(p.read_bytes()) for p in files]
    expected_exit = 2 if 'error' in case['expected'] else 0
    process = invoke(case['name'], CLI + [p.name for p in files], expected_exit, directory)
    assert not process.stderr
    result = json.loads(process.stdout)
    results[case['name']] = result
    inputs[case['name']] = files
    rows[-1]['input_sha256'] = before
    assert [digest(p.read_bytes()) for p in files] == before
    assert result['schema'] == 'moonbit.sta.path-query.v1'
    if expected_exit:
        assert result['ok'] is False and case['expected']['error'] in result['error']
    else:
        assert result['ok'] is True
        receive(result, case)

assert results['losing-base']['result'] == results['losing-changed']['result']
near(results['losing-base']['result']['worst_slack_seconds'], .3e-9)
assert results['losing-base']['path_query']['queried_slack_seconds'] != results['losing-base']['result']['worst_slack_seconds']

# Separate MoonBit executable package imports public @sta, never private graph.
receiver = ROOT / '_build/js/release/build/examples/path_query_receiver/path_query_receiver.js'
process = invoke('public-package', ['node', str(receiver)], 0, OUTPUT)
assert not process.stderr
received = json.loads(process.stdout)
assert len(received) == 5
for analysis, name in zip(received, ['losing-base', 'losing-changed', 'inverting-no-path', 'unknown-launch', 'q-to-d'], strict=True):
    receive(analysis, next(c for c in catalog['cases'] if c['name'] == name))
assert received[0]['timing'] == results['losing-base']['result']

# A source-only help call verifies that no core or files are loaded.
help_tool = OUTPUT / 'source-only/tools/path-query.cjs'
help_tool.parent.mkdir(parents=True)
shutil.copyfile(ROOT/'tools/path-query.cjs', help_tool)
process = invoke('source-only-help', ['node', str(help_tool), '--help'], 0, OUTPUT)
assert not process.stderr and b'UnconstrainedLaunch' in process.stdout and b'no build' in process.stdout
process = invoke('argument-count', CLI, 2, OUTPUT)
assert not process.stdout and b'Usage:' in process.stderr

io = OUTPUT / 'io'; io.mkdir()
base_files = inputs['losing-base']
bom_files = []
for i, original in enumerate(base_files):
    target = io / ('bom-' + str(i))
    target.write_bytes((b'\xef\xbb\xbf' if i != 2 else b'') + original.read_bytes())
    bom_files.append(target)
process = invoke('bom-library-netlist-query', CLI + list(map(str, bom_files)), 0, io)
assert not process.stderr and json.loads(process.stdout) == results['losing-base']

for index, label in enumerate(['Liberty', 'netlist', 'SDC', 'query']):
    invalid = io / ('invalid-utf8-' + str(index))
    invalid.write_bytes(b'\xff')
    paths = base_files.copy(); paths[index] = invalid
    process = invoke('invalid-utf8-' + str(index), CLI + list(map(str, paths)), 2, io)
    assert not process.stdout and ('Invalid UTF-8 in ' + label + ' input').encode() in process.stderr

for index, label in [(1, 'netlist'), (3, 'path query')]:
    invalid = io / ('bad-json-' + str(index)); invalid.write_bytes(b'{')
    paths = base_files.copy(); paths[index] = invalid
    process = invoke('invalid-json-' + str(index), CLI + list(map(str, paths)), 2, io)
    payload = json.loads(process.stdout)
    assert not process.stderr and payload['ok'] is False and ('invalid ' + label + ' JSON') in payload['error']

paths = base_files.copy(); paths[3] = io / 'absent-query.json'
process = invoke('missing-query-file', CLI + list(map(str, paths)), 2, io)
assert not process.stdout and b'ENOENT' in process.stderr

# Original analysis failure wins over a well-shaped but invalid point identity.
bad_sdc = io / 'missing-transition.sdc'
bad_sdc.write_bytes('\n'.join(line for line in catalog['sdc']['base'].splitlines() if not line.startswith('set_input_transition')).encode())
bad_query = io / 'bad-point.json'
bad_query.write_bytes(json.dumps({'from': {'kind':'input_port','name':'absent','edge':'rise'}, 'to': {'kind':'output_port','name':'absent','edge':'rise'}}).encode())
process = invoke('original-analysis-error-precedence', CLI + [str(base_files[0]),str(base_files[1]),str(bad_sdc),str(bad_query)], 2, io)
assert not process.stderr and 'missing input transition' in json.loads(process.stdout)['error']

process = subprocess.Popen(CLI + list(map(str, base_files)), cwd=io, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
process.stdout.close(); process.stdout = None
_, stderr = process.communicate(timeout=45)
record('stdout-closed', process, b'', stderr)
assert process.returncode == 2 and b'stdout:' in stderr

assert all(digest((ROOT/p).read_bytes()) == expected for p,expected in source_hashes.items())
save_receipt(True)
print(json.dumps({'all_passed': True, 'frozen_cases':len(catalog['cases']), 'public_package_results':5,
                  'real_process_invocations':len(rows), 'self_authored_integration':True, 'third_party_adoption':False}, sort_keys=True))
