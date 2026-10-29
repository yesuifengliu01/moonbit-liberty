"""Receive complete frozen facts through actual two-file and public-package runs.

No grouping/binding/area algorithm supplies expected outputs. Retain all raw
stdout/stderr and exact tested input copies, including when a check fails.
"""
import hashlib,json,math,pathlib,shutil,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
CATALOG=ROOT/'examples/cell-usage-cases.json'
catalog=json.loads(CATALOG.read_text(encoding='utf8'))
OUTPUT=ROOT/'_build'/(sys.argv[1] if len(sys.argv)==2 else 'cell-usage-receipts')
assert OUTPUT.resolve().is_relative_to((ROOT/'_build').resolve())
OUTPUT.mkdir(parents=True,exist_ok=False)
CLI=['node',str(ROOT/'tools/cell-usage.cjs')]
rows=[];tested=[]

def sha(blob):return hashlib.sha256(blob).hexdigest()

def identity(file):
    blob=file.read_bytes()
    return {'path':str(file.relative_to(ROOT)),'bytes':len(blob),'sha256':sha(blob)}

def save(passed=False):
    value={'all_passed':passed,'self_authored_integration':True,'third_party_adoption':False,'frozen_cases':len(catalog['cases']),'catalog_sha256':sha(CATALOG.read_bytes()),'real_process_invocations':len(rows),'tested_input_copies':tested,'rows':rows}
    (ROOT/'_build/ci-cell-usage.json').write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf8')

def record(name,p,stdout,stderr):
    out=OUTPUT/(name+'.stdout');err=OUTPUT/(name+'.stderr')
    out.write_bytes(stdout);err.write_bytes(stderr)
    rows.append({'case':name,'exit':p.returncode,'stdout':str(out.relative_to(ROOT)),'stdout_bytes':len(stdout),'stdout_sha256':sha(stdout),'stderr':str(err.relative_to(ROOT)),'stderr_bytes':len(stderr),'stderr_sha256':sha(stderr)})
    save()

def invoke(name,command,expected_exit,cwd,files=()):
    before=[identity(file) for file in files]
    p=subprocess.run(command,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=45)
    record(name,p,p.stdout,p.stderr)
    rows[-1]['command']=list(map(str,command));rows[-1]['cwd']=str(cwd.relative_to(ROOT))
    rows[-1]['input_copies']=before
    tested.extend(item for item in before if item not in tested)
    save()
    assert [identity(file) for file in files]==before,'input files mutated'
    assert p.returncode==expected_exit,(name,p.returncode,p.stderr)
    return p

def receive(actual,expected):
    if type(expected) is dict:
        assert type(actual) is dict and actual.keys()==expected.keys(),(actual,expected)
        for key,value in expected.items():receive(actual[key],value)
    elif type(expected) is list:
        assert type(actual) is list and len(actual)==len(expected)
        for value,reference in zip(actual,expected,strict=True):receive(value,reference)
    elif type(expected) in (float,int):
        assert type(actual) in (float,int) and math.isfinite(actual)
        if type(expected) is int:assert actual==expected,(actual,expected)
        else:assert math.isclose(actual,expected,rel_tol=catalog['relative_tolerance'],abs_tol=catalog['absolute_tolerance']),(actual,expected)
    else:assert type(actual) is type(expected) and actual==expected,(actual,expected)

source_paths=[CATALOG,ROOT/catalog['existingSky130Path'],ROOT/'examples/cell-usage.lib',ROOT/'examples/cell-usage-netlist.json']
source_hashes={file:sha(file.read_bytes()) for file in source_paths}
results={};inputs={}
for case in catalog['cases']:
    directory=OUTPUT/'inputs'/case['name'];directory.mkdir(parents=True)
    files=[directory/'库.lib',directory/'设计.json']
    library=(ROOT/catalog['existingSky130Path']).read_bytes() if case['library']=='existing-sky130' else catalog['libraries'][case['library']].encode()
    files[0].write_bytes(library)
    files[1].write_bytes((json.dumps(case['netlist'],ensure_ascii=False,indent=2)+'\n').encode())
    expected=case['expected']
    code=2 if 'error' in expected else (0 if expected['status']=='Complete' else 4)
    p=invoke(case['name'],CLI+[file.name for file in files],code,directory,files)
    assert not p.stderr
    payload=json.loads(p.stdout);results[case['name']]=payload;inputs[case['name']]=files
    assert payload['schema']=='moonbit.sta.cell-usage.v1'
    if 'error' in expected:
        assert payload.keys()=={'ok','schema','error'} and payload['ok'] is False
        assert expected['error'] in payload['error']
    else:
        assert payload.keys()=={'ok','schema','usage'} and payload['ok'] is True
        receive(payload['usage'],expected)

receiver=ROOT/'_build/js/release/build/examples/cell_usage_receiver/cell_usage_receiver.js'
p=invoke('public-package',['node',str(receiver)],0,OUTPUT)
assert not p.stderr
typed=json.loads(p.stdout);assert len(typed)==5
for value,name in zip(typed,['complete-no-timing','mixed-coverage','zero-area','subtotal-overflow','real-sky130'],strict=True):
    receive(value,next(case['expected'] for case in catalog['cases'] if case['name']==name))
    receive(value,results[name]['usage'])

source_tool=OUTPUT/'source-only/tools/cell-usage.cjs';source_tool.parent.mkdir(parents=True)
shutil.copyfile(ROOT/'tools/cell-usage.cjs',source_tool)
p=invoke('source-only-help',['node',str(source_tool),'--help'],0,OUTPUT)
assert not p.stderr and b'no build' in p.stdout and b'liberty_declared_area' in p.stdout
p=invoke('argument-count',CLI,2,OUTPUT);assert not p.stdout and b'Usage:' in p.stderr
io=OUTPUT/'io';io.mkdir();base=inputs['complete-no-timing']
for index,label in enumerate(['Liberty','netlist']):
    invalid=io/('bad-utf8-'+str(index));invalid.write_bytes(b'\xff')
    files=base.copy();files[index]=invalid
    p=invoke('invalid-utf8-'+str(index),CLI+list(map(str,files)),2,io,files)
    assert not p.stdout and ('Invalid UTF-8 in '+label+' input').encode() in p.stderr
for name,blob,index,fragment in [
    ('invalid-json',b'{',1,'invalid netlist JSON'),
    ('invalid-library',b'library (',0,'LibraryFailure'),
    ('invalid-schema',b'{}',1,None),
]:
    invalid=io/name;invalid.write_bytes(blob);files=base.copy();files[index]=invalid
    p=invoke(name,CLI+list(map(str,files)),2,io,files)
    payload=json.loads(p.stdout)
    assert not p.stderr and payload['ok'] is False
    if fragment:assert fragment in payload['error']
bom=[]
for index,original in enumerate(base):
    file=io/('bom-'+str(index));file.write_bytes(b'\xef\xbb\xbf'+original.read_bytes());bom.append(file)
p=invoke('library-netlist-bom',CLI+list(map(str,bom)),0,io,bom)
assert not p.stderr and json.loads(p.stdout)==results['complete-no-timing']
p=invoke('missing-library',CLI+[str(io/'absent.lib'),str(base[1])],2,io,[base[1]])
assert not p.stdout and b'ENOENT' in p.stderr
p=subprocess.Popen(CLI+list(map(str,base)),cwd=io,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
p.stdout.close();p.stdout=None
_,stderr=p.communicate(timeout=45)
record('stdout-closed',p,b'',stderr)
rows[-1]['input_copies']=[identity(file) for file in base]
assert p.returncode==2 and b'stdout:' in stderr
assert all(sha(file.read_bytes())==value for file,value in source_hashes.items())
save(True)
print(json.dumps({'all_passed':True,'frozen_cases':21,'public_package_results':5,'real_process_invocations':len(rows),'tested_input_copies':len(tested),'self_authored_integration':True,'third_party_adoption':False},sort_keys=True))
