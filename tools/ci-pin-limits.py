"""Independent complete-row recipient; no timing/limit derivation algorithm.

All raw process outputs survive failures. The fixed catalog predates new code;
real GBA slew measurements are from the accepted prior compiled API.
"""
import hashlib,json,math,pathlib,shutil,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
CATALOG=ROOT/'examples/pin-limit-cases.json'
catalog=json.loads(CATALOG.read_text(encoding='utf8'))
OUTPUT=ROOT/'_build'/(sys.argv[1] if len(sys.argv)==2 else 'pin-limit-receipts')
assert OUTPUT.resolve().is_relative_to((ROOT/'_build').resolve())
OUTPUT.mkdir(parents=True,exist_ok=False)
CLI=['node',str(ROOT/'tools/check-pin-limits.cjs')]
rows=[]
def sha(blob):return hashlib.sha256(blob).hexdigest()
def save(passed=False):
    value={'all_passed':passed,'self_authored_integration':True,'third_party_adoption':False,'frozen_cases':len(catalog['cases']),'catalog_sha256':sha(CATALOG.read_bytes()),'real_process_invocations':len(rows),'rows':rows}
    (ROOT/'_build/ci-pin-limits.json').write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def record(name,p,stdout,stderr):
    out=OUTPUT/(name+'.stdout');err=OUTPUT/(name+'.stderr')
    out.write_bytes(stdout);err.write_bytes(stderr)
    rows.append({'case':name,'exit':p.returncode,'stdout':str(out.relative_to(ROOT)),'stdout_bytes':len(stdout),'stdout_sha256':sha(stdout),'stderr':str(err.relative_to(ROOT)),'stderr_bytes':len(stderr),'stderr_sha256':sha(stderr)})
    save()
def invoke(name,command,expected_exit,cwd):
    p=subprocess.run(command,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=45)
    record(name,p,p.stdout,p.stderr)
    assert p.returncode==expected_exit,(name,p.returncode,p.stderr)
    return p
def receive(actual,reference):
    assert actual.keys()==reference.keys()
    for key in ['status','checked_rules','violated_rules','unspecified_rules','invalid_rules']:
        assert actual[key]==reference[key],(key,actual[key],reference[key])
    assert len(actual['checks'])==len(reference['checks'])
    for observed,expected in zip(actual['checks'],reference['checks'],strict=True):
        assert observed.keys()==expected.keys(),(observed,expected)
        for key,value in expected.items():
            if key in ['actual_si','limit_si','margin_si']:
                assert type(observed[key]) in (int,float) and math.isfinite(observed[key])
                absolute=catalog['tolerance']['seconds_absolute' if expected['unit']=='seconds' else 'farads_absolute']
                assert math.isclose(observed[key],value,rel_tol=catalog['tolerance']['relative'],abs_tol=absolute),(key,observed[key],value,expected)
            else:assert observed[key]==value,(key,observed[key],value)

exit_for={'Met':0,'Violated':3,'InvalidLimits':4,'NoDeclaredLimits':4}
source_paths=[CATALOG,ROOT/catalog['existingSky130Path'],*[ROOT/'examples'/name for name in ['pin-limits.lib','pin-limits-met.lib','pin-limits-netlist.json','pin-limits.sdc','pin-limits-real-netlist.json','pin-limits-real.sdc']]]
source_hashes={p:sha(p.read_bytes()) for p in source_paths}
results={};inputs={}
for case in catalog['cases']:
    directory=OUTPUT/'inputs'/case['name'];directory.mkdir(parents=True)
    files=[directory/name for name in ['库.lib','设计.json','约束.sdc']]
    library=(ROOT/catalog['existingSky130Path']).read_bytes() if case['library']=='existing-sky130' else catalog['libraries'][case['library']].encode()
    for file,blob in zip(files,[library,json.dumps(catalog['netlists'][case['netlist']],ensure_ascii=False).encode(),catalog['sdc'][case['sdc']].encode()],strict=True):file.write_bytes(blob)
    before=[sha(p.read_bytes()) for p in files]
    code=2 if 'error' in case['expected'] else exit_for[case['expected']['status']]
    p=invoke(case['name'],CLI+['--range-policy',case['policy']]+[p.name for p in files],code,directory)
    assert not p.stderr
    payload=json.loads(p.stdout);results[case['name']]=payload;inputs[case['name']]=files
    rows[-1]['input_sha256']=before
    assert [sha(p.read_bytes()) for p in files]==before
    assert payload['schema']=='moonbit.sta.pin-limits.v1'
    if 'error' in case['expected']:
        assert payload['ok'] is False and case['expected']['error'] in payload['error']
    else:
        assert payload['ok'] is True
        receive(payload['pin_limits'],case['expected'])
assert results['strict']['result']==results['met']['result']

receiver=ROOT/'_build/js/release/build/examples/pin_limit_receiver/pin_limit_receiver.js'
p=invoke('public-package',['node',str(receiver)],0,OUTPUT)
assert not p.stderr
typed=json.loads(p.stdout);assert len(typed)==5
for value,name in zip(typed,['strict','met','no-limits','invalid-default','ff-pins'],strict=True):
    case=next(c for c in catalog['cases'] if c['name']==name)
    receive(value['pin_limits'],case['expected'])
    assert value['timing']==results[name]['result']

# Default remains Extrapolate, retaining both physical high load and diagnostics.
p=invoke('default-extrapolate',CLI+list(map(str,inputs['high-load-extrapolate'])),3,OUTPUT)
assert not p.stderr and json.loads(p.stdout)==results['high-load-extrapolate']

# A real old setup-check receiver still passes exactly the same strict input.
request=OUTPUT/'strict-request.json'
request.write_text(json.dumps({'netlist':catalog['netlists']['base'],'sdc':catalog['sdc']['base'],'range_policy':'reject'}),encoding='utf8')
p=invoke('legacy-setup-met',['node',str(ROOT/'tools/sta.cjs'),'--check-setup',str(inputs['strict'][0]),str(request)],0,OUTPUT)
legacy=json.loads(p.stdout)
assert not p.stderr and legacy['ok'] and legacy['setup_summary']['status']=='Met'
assert legacy['result']==results['strict']['result']

source_tool=OUTPUT/'source-only/tools/check-pin-limits.cjs';source_tool.parent.mkdir(parents=True)
shutil.copyfile(ROOT/'tools/check-pin-limits.cjs',source_tool)
p=invoke('source-only-help',['node',str(source_tool),'--help'],0,OUTPUT)
assert not p.stderr and b'no build' in p.stdout and b'NoDeclaredLimits' in p.stdout
p=invoke('argument-count',CLI,2,OUTPUT);assert not p.stdout and b'Usage:' in p.stderr
io=OUTPUT/'io';io.mkdir()
base=inputs['strict']
for index,label in enumerate(['Liberty','netlist','SDC']):
    invalid=io/('bad-utf8-'+str(index));invalid.write_bytes(b'\xff')
    files=base.copy();files[index]=invalid
    p=invoke('invalid-utf8-'+str(index),CLI+list(map(str,files)),2,io)
    assert not p.stdout and ('Invalid UTF-8 in '+label+' input').encode() in p.stderr
invalid=io/'bad.json';invalid.write_bytes(b'{')
p=invoke('invalid-json',CLI+[str(base[0]),str(invalid),str(base[2])],2,io)
assert not p.stderr and 'invalid netlist JSON' in json.loads(p.stdout)['error']
p=invoke('invalid-policy',CLI+['--range-policy','other']+list(map(str,base)),2,io)
assert not p.stderr and 'unknown range_policy' in json.loads(p.stdout)['error']
bom=[]
for index,original in enumerate(base):
    file=io/('bom-'+str(index));file.write_bytes((b'\xef\xbb\xbf' if index<2 else b'')+original.read_bytes());bom.append(file)
p=invoke('library-netlist-bom',CLI+list(map(str,bom)),3,io)
assert not p.stderr and json.loads(p.stdout)==results['strict']
p=invoke('missing-sdc',CLI+[str(base[0]),str(base[1]),str(io/'absent.sdc')],2,io)
assert not p.stdout and b'ENOENT' in p.stderr
p=subprocess.Popen(CLI+list(map(str,base)),cwd=io,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
p.stdout.close();p.stdout=None
_,stderr=p.communicate(timeout=45)
record('stdout-closed',p,b'',stderr)
assert p.returncode==2 and b'stdout:' in stderr
assert all(sha(p.read_bytes())==value for p,value in source_hashes.items())
save(True)
print(json.dumps({'all_passed':True,'frozen_cases':22,'public_package_results':5,'real_process_invocations':len(rows),'self_authored_integration':True,'third_party_adoption':False},sort_keys=True))
