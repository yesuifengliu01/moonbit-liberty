"""Full independent scalar-reference receiving gate; preserve actual byte receipts."""
import hashlib,json,pathlib,shutil,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
CATALOG=ROOT/'examples/reference-cases.json'
catalog=json.loads(CATALOG.read_text(encoding='utf8'))
assert len(catalog['cases'])==24
OUTPUT=ROOT/'_build'/(sys.argv[1] if len(sys.argv)==2 else 'reference-receipts')
assert OUTPUT.resolve().is_relative_to((ROOT/'_build').resolve())
OUTPUT.mkdir(parents=True,exist_ok=False)
CLI=['node',str(ROOT/'tools/check-references.cjs')]
rows=[];tested=[]
def sha(blob):return hashlib.sha256(blob).hexdigest()
def identity(file):
    blob=file.read_bytes();return {'path':str(file.relative_to(ROOT)),'bytes':len(blob),'sha256':sha(blob)}
def save(passed=False):
    value={'all_passed':passed,'self_authored_integration':True,'third_party_adoption':False,'frozen_cases':24,'catalog_sha256':sha(CATALOG.read_bytes()),'real_process_invocations':len(rows),'tested_input_copies':tested,'rows':rows}
    (ROOT/'_build/ci-references.json').write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def record(name,p,stdout,stderr):
    out=OUTPUT/(name+'.stdout');err=OUTPUT/(name+'.stderr')
    out.write_bytes(stdout);err.write_bytes(stderr)
    rows.append({'case':name,'exit':p.returncode,'stdout':str(out.relative_to(ROOT)),'stdout_bytes':len(stdout),'stdout_sha256':sha(stdout),'stderr':str(err.relative_to(ROOT)),'stderr_bytes':len(stderr),'stderr_sha256':sha(stderr)})
    save()
def invoke(name,command,code,cwd,files=()):
    before=[identity(file) for file in files]
    p=subprocess.run(command,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=45)
    record(name,p,p.stdout,p.stderr)
    rows[-1].update(command=list(map(str,command)),cwd=str(cwd.relative_to(ROOT)),input_copies=before)
    tested.extend(item for item in before if item not in tested);save()
    assert [identity(file) for file in files]==before,'Input bytes mutated'
    assert p.returncode==code,(name,p.returncode,p.stderr)
    return p
def receive(actual,expected):
    assert type(actual) is type(expected),(actual,expected)
    if isinstance(expected,dict):
        assert actual.keys()==expected.keys(),(actual,expected)
        for key,value in expected.items():receive(actual[key],value)
    elif isinstance(expected,list):
        assert len(actual)==len(expected)
        for value,reference in zip(actual,expected,strict=True):receive(value,reference)
    else:assert actual==expected,(actual,expected)
sources=[CATALOG,ROOT/catalog['existingSky130Path'],*[ROOT/'examples'/name for name in ['reference.lib','reference-netlist.json','reference-issues.json']]]
hashes={file:sha(file.read_bytes()) for file in sources}
results={};inputs={}
for case in catalog['cases']:
    directory=OUTPUT/'inputs'/case['name'];directory.mkdir(parents=True)
    files=[directory/'库.lib',directory/'设计.json']
    library=(ROOT/catalog['existingSky130Path']).read_bytes() if case['library']=='existing-sky130' else catalog['libraries'][case['library']].encode()
    files[0].write_bytes(library);files[1].write_bytes((json.dumps(case['netlist'],ensure_ascii=False,indent=2)+'\n').encode())
    expected=case['expected'];code=2 if 'error' in expected else (0 if expected['status']=='ReferencesResolved' else 3)
    p=invoke(case['name'],CLI+[file.name for file in files],code,directory,files)
    assert not p.stderr
    payload=json.loads(p.stdout);results[case['name']]=payload;inputs[case['name']]=files
    assert payload['schema']=='moonbit.sta.references.v1'
    if 'error' in expected:
        assert payload.keys()=={'ok','schema','error','pointer'} and payload['ok'] is False
        assert expected['error'] in payload['error'] and payload['pointer']==expected['pointer']
    else:
        assert payload.keys()=={'ok','schema','references'} and payload['ok'] is True
        receive(payload['references'],expected)
receiver=ROOT/'_build/js/release/build/examples/reference_receiver/reference_receiver.js'
p=invoke('public-package',['node',str(receiver)],0,OUTPUT);assert not p.stderr
typed=json.loads(p.stdout);assert len(typed)==5
for value,name in zip(typed,['resolved-no-timing','all14-issues','raw-names-native-directions','cycle-outside-scope','real-sky130'],strict=True):
    receive(value,next(case['expected'] for case in catalog['cases'] if case['name']==name))
    receive(value,results[name]['references'])
demo=OUTPUT/'distributed-demo';demo.mkdir()
for name in ['reference.lib','reference-netlist.json','reference-issues.json']:shutil.copyfile(ROOT/'examples'/name,demo/name)
for name,netlist,case,code in [('distributed-resolved','reference-netlist.json','resolved-no-timing',0),('distributed-issues','reference-issues.json','all14-issues',3)]:
    files=[demo/'reference.lib',demo/netlist]
    p=invoke(name,CLI+[file.name for file in files],code,demo,files)
    assert not p.stderr and json.loads(p.stdout)==results[case]
source_tool=OUTPUT/'source-only/tools/check-references.cjs';source_tool.parent.mkdir(parents=True)
shutil.copyfile(ROOT/'tools/check-references.cjs',source_tool)
p=invoke('source-only-help',['node',str(source_tool),'--help'],0,OUTPUT)
assert not p.stderr and b'no build' in p.stdout and b'scalar names/references' in p.stdout
p=invoke('argument-count',CLI,2,OUTPUT);assert not p.stdout and b'Usage:' in p.stderr
io=OUTPUT/'io';io.mkdir();base=inputs['resolved-no-timing']
for index,label in enumerate(['Liberty','netlist']):
    bad=io/('bad-utf8-'+str(index));bad.write_bytes(b'\xff');files=base.copy();files[index]=bad
    p=invoke('invalid-utf8-'+str(index),CLI+list(map(str,files)),2,io,files)
    assert not p.stdout and ('Invalid UTF-8 in '+label+' input').encode() in p.stderr
for name,blob,index,fragment,pointer in [('invalid-json',b'{',1,'invalid netlist JSON',None),('invalid-library',b'library (',0,'LibraryFailure',None),('invalid-schema',b'{}',1,'missing JSON field ports','/ports')]:
    bad=io/name;bad.write_bytes(blob);files=base.copy();files[index]=bad
    p=invoke(name,CLI+list(map(str,files)),2,io,files);payload=json.loads(p.stdout)
    assert not p.stderr and payload['ok'] is False and fragment in payload['error'] and payload['pointer']==pointer
bom=[]
for index,original in enumerate(base):
    file=io/('bom-'+str(index));file.write_bytes(b'\xef\xbb\xbf'+original.read_bytes());bom.append(file)
p=invoke('library-netlist-bom',CLI+list(map(str,bom)),0,io,bom)
assert not p.stderr and json.loads(p.stdout)==results['resolved-no-timing']
p=invoke('missing-library',CLI+[str(io/'absent.lib'),str(base[1])],2,io,[base[1]])
assert not p.stdout and b'ENOENT' in p.stderr
p=subprocess.Popen(CLI+list(map(str,base)),cwd=io,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
p.stdout.close();p.stdout=None
_,stderr=p.communicate(timeout=45);record('stdout-closed',p,b'',stderr)
rows[-1]['input_copies']=[identity(file) for file in base]
assert p.returncode==2 and b'stdout:' in stderr
assert all(sha(file.read_bytes())==value for file,value in hashes.items())
assert len(rows)==37
save(True)
print(json.dumps({'all_passed':True,'frozen_cases':24,'public_package_results':5,'real_process_invocations':37,'tested_input_copies':len(tested),'self_authored_integration':True,'third_party_adoption':False},sort_keys=True))
