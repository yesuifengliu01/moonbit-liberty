"""Receive complete pre-code setup comparison facts through real report files."""
import hashlib,json,math,pathlib,shutil,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
CATALOG=ROOT/'examples/setup-comparison-cases.json'
catalog=json.loads(CATALOG.read_text(encoding='utf8'));assert len(catalog['cases'])==30
OUTPUT=ROOT/'_build'/(sys.argv[1] if len(sys.argv)==2 else 'setup-comparison-receipts')
assert OUTPUT.resolve().is_relative_to((ROOT/'_build').resolve())
OUTPUT.mkdir(parents=True,exist_ok=False)
CLI=['node',str(ROOT/'tools/compare-setup.cjs')]
rows=[];tested=[]
def sha(blob):return hashlib.sha256(blob).hexdigest()
def identity(file):
    blob=file.read_bytes();return {'path':str(file.relative_to(ROOT)),'bytes':len(blob),'sha256':sha(blob)}
def save(passed=False):
    value={'all_passed':passed,'self_authored_integration':True,'third_party_adoption':False,'frozen_cases':30,'catalog_sha256':sha(CATALOG.read_bytes()),'real_process_invocations':len(rows),'tested_input_copies':tested,'rows':rows}
    (ROOT/'_build/ci-setup-comparison.json').write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
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
    assert [identity(file) for file in files]==before,'Report input bytes mutated'
    assert p.returncode==code,(name,p.returncode,p.stderr)
    return p
def receive(actual,expected):
    if type(expected) is dict:
        assert type(actual) is dict and actual.keys()==expected.keys(),(actual,expected)
        for key,value in expected.items():receive(actual[key],value)
    elif type(expected) is list:
        assert type(actual) is list and len(actual)==len(expected)
        for value,reference in zip(actual,expected,strict=True):receive(value,reference)
    elif type(expected) in (int,float):
        assert type(actual) in (int,float) and math.isfinite(actual)
        if type(expected) is int:assert actual==expected,(actual,expected)
        else:assert math.isclose(actual,expected,rel_tol=catalog['relative_tolerance'],abs_tol=catalog['absolute_tolerance']),(actual,expected)
    else:assert type(actual) is type(expected) and actual==expected,(actual,expected)
sources=[CATALOG,*[ROOT/'examples'/name for name in ['setup-baseline.json','setup-candidate.json','setup-comparison-baseline.lib','setup-comparison-candidate.lib','setup-comparison-request.json']]]
hashes={file:sha(file.read_bytes()) for file in sources}
results={};inputs={}
exit_for={'NoSetupRegression':0,'SetupRegressed':3,'SetupComparisonIncomplete':4}
for case in catalog['cases']:
    directory=OUTPUT/'inputs'/case['name'];directory.mkdir(parents=True)
    files=[directory/'基线.json',directory/'候选.json']
    for side,file in zip(['baseline','candidate'],files,strict=True):file.write_bytes(catalog['reports'][case[side]].encode())
    expected=case['expected'];code=2 if 'error' in expected else exit_for[expected['status']]
    p=invoke(case['name'],CLI+['--max-slack-loss',str(case['max_slack_loss_seconds'])]+[file.name for file in files],code,directory,files)
    assert not p.stderr
    payload=json.loads(p.stdout);results[case['name']]=payload;inputs[case['name']]=files
    assert payload['schema']=='moonbit.sta.setup-compare.v1'
    if 'error' in expected:
        assert payload.keys()=={'ok','schema','error'} and payload['ok'] is False and expected['error'] in payload['error']
    else:
        assert payload.keys()=={'ok','schema','comparison'} and payload['ok'] is True
        receive(payload['comparison'],expected)
receiver=ROOT/'_build/js/release/build/examples/setup_comparison_receiver/setup_comparison_receiver.js'
p=invoke('public-package',['node',str(receiver)],0,OUTPUT);assert not p.stderr
typed=json.loads(p.stdout);assert len(typed)==5
for value,name in zip(typed,['positive-slack-loss','exact-tolerance-allowed','candidate-slack-missing','known-regression-and-set-changes','actual-old-cli-both-met'],strict=True):
    receive(value,next(case['expected'] for case in catalog['cases'] if case['name']==name))
    receive(value,results[name]['comparison'])
demo=OUTPUT/'distributed-demo';demo.mkdir()
files=[demo/'setup-baseline.json',demo/'setup-candidate.json']
for file in files:shutil.copyfile(ROOT/'examples'/file.name,file)
assert files[0].read_bytes()==catalog['reports']['actual-baseline'].encode()
assert files[1].read_bytes()==catalog['reports']['actual-candidate'].encode()
p=invoke('distributed-default',CLI+[file.name for file in files],3,demo,files)
assert not p.stderr and json.loads(p.stdout)==results['actual-old-cli-both-met']
p=invoke('distributed-tolerated',CLI+['--max-slack-loss','5e-10']+[file.name for file in files],0,demo,files)
assert not p.stderr and json.loads(p.stdout)==results['actual-old-cli-tolerance']
source_tool=OUTPUT/'source-only/tools/compare-setup.cjs';source_tool.parent.mkdir(parents=True)
shutil.copyfile(ROOT/'tools/compare-setup.cjs',source_tool)
p=invoke('source-only-help',['node',str(source_tool),'--help'],0,OUTPUT)
assert not p.stderr and b'no build' in p.stdout and b'--max-slack-loss' in p.stdout
p=invoke('argument-count',CLI,2,OUTPUT);assert not p.stdout and b'Usage:' in p.stderr
io=OUTPUT/'io';io.mkdir();base=inputs['positive-slack-loss']
p=invoke('invalid-option',CLI+['--unknown','0']+list(map(str,base)),2,io,base)
assert not p.stdout and b'Usage:' in p.stderr
for index,label in enumerate(['baseline report','candidate report']):
    bad=io/('bad-utf8-'+str(index));bad.write_bytes(b'\xff');files=base.copy();files[index]=bad
    p=invoke('invalid-utf8-'+str(index),CLI+list(map(str,files)),2,io,files)
    assert not p.stdout and ('Invalid UTF-8 in '+label).encode() in p.stderr
bad=io/'bad.json';bad.write_bytes(b'{')
p=invoke('invalid-json',CLI+[str(bad),str(base[1])],2,io,[bad,base[1]])
assert not p.stderr and 'invalid baseline report JSON' in json.loads(p.stdout)['error']
failed=io/'failed-report.json';failed.write_bytes(b'{"ok":false,"schema":"moonbit.sta.v1","error":"fixture"}')
p=invoke('failed-analysis-report',CLI+[str(failed),str(base[1])],2,io,[failed,base[1]])
assert not p.stderr and 'invalid baseline report schema' in json.loads(p.stdout)['error']
p=invoke('missing-candidate',CLI+[str(base[0]),str(io/'absent.json')],2,io,[base[0]])
assert not p.stdout and b'ENOENT' in p.stderr
bom=[]
for index,original in enumerate(base):
    file=io/('bom-'+str(index));file.write_bytes(b'\xef\xbb\xbf'+original.read_bytes());bom.append(file)
p=invoke('report-boms',CLI+list(map(str,bom)),3,io,bom)
assert not p.stderr and json.loads(p.stdout)==results['positive-slack-loss']
for index,token in enumerate(catalog['invalid_budget_tokens']):
    p=invoke('invalid-budget-'+str(index),CLI+['--max-slack-loss',token]+list(map(str,base)),2,io,base)
    assert not p.stderr and 'finite and nonnegative' in json.loads(p.stdout)['error']
p=subprocess.Popen(CLI+list(map(str,base)),cwd=io,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
p.stdout.close();p.stdout=None
_,stderr=p.communicate(timeout=45);record('stdout-closed',p,b'',stderr)
rows[-1]['input_copies']=[identity(file) for file in base]
assert p.returncode==2 and b'stdout:' in stderr
assert all(sha(file.read_bytes())==value for file,value in hashes.items())
assert len(rows)==46,len(rows)
save(True)
print(json.dumps({'all_passed':True,'frozen_cases':30,'public_package_results':5,'real_process_invocations':46,'tested_input_copies':len(tested),'original_timing_rerun':False,'self_authored_integration':True,'third_party_adoption':False},sort_keys=True))
