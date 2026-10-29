"""Frozen real cycle-member diagnostics through existing public entry points."""
import hashlib,json,pathlib,shutil,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[1];CATALOG=ROOT/'examples/cycle-diagnosis-cases.json';catalog=json.loads(CATALOG.read_text(encoding='utf8'))
OUT=ROOT/'_build/cycle-diagnosis-receipts';OUT.mkdir(parents=True,exist_ok=False);NODE=shutil.which('node');rows=[];copies=[]
sha=lambda b:hashlib.sha256(b).hexdigest()
def identity(file):
    b=file.read_bytes();return {'path':str(file.relative_to(ROOT)),'bytes':len(b),'sha256':sha(b)}
def save(passed=False):
    (ROOT/'_build/ci-cycle-diagnosis.json').write_text(json.dumps({'all_passed':passed,'frozen_cases':21,'real_process_invocations':len(rows),'public_typed_cases':21,'affected_typed_methods':5,'additional_json_calls':4,'self_authored_integration':True,'third_party_adoption':False,'newTimingMathOrInputFormat':False,'oldScientificOrCompletedWorkflowRerun':False,'catalog_sha256':sha(CATALOG.read_bytes()),'tested_input_copies':copies,'rows':rows},ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def invoke(name,command,code,directory,files=()):
    before=[identity(file) for file in files];p=subprocess.run(command,cwd=directory,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=60)
    out=OUT/(name+'.stdout');err=OUT/(name+'.stderr');out.write_bytes(p.stdout);err.write_bytes(p.stderr)
    rows.append({'case':name,'command':list(map(str,command)),'cwd':str(directory.relative_to(ROOT)),'exit':p.returncode,'stdout':str(out.relative_to(ROOT)),'stdout_bytes':len(p.stdout),'stdout_sha256':sha(p.stdout),'stderr':str(err.relative_to(ROOT)),'stderr_bytes':len(p.stderr),'stderr_sha256':sha(p.stderr),'input_copies':before})
    copies.extend(row for row in before if row not in copies);save()
    assert p.returncode==code,(name,p.returncode,p.stderr)
    assert [identity(file) for file in files]==before and not p.stderr,(name,'source mutation or stderr')
    return p
def fixture(name,case):
    directory=OUT/name;directory.mkdir();files=[directory/'库.lib',directory/'设计.json']
    files[0].write_bytes(catalog['libraries'][case['library']].encode());files[1].write_bytes(case['request'].encode());return directory,files
source_files=[CATALOG,ROOT/'examples/cycle-diagnosis.lib',ROOT/'examples/cycle-diagnosis-request.json'];source_hashes={file:sha(file.read_bytes()) for file in source_files}
for case in catalog['cases']:
    directory,files=fixture(case['name'],case)
    p=invoke(case['name'],[NODE,str(ROOT/'tools/sta.cjs'),*[file.name for file in files]],case['expected_exit'],directory,files)
    assert p.stdout==case['expected_stdout_utf8'].encode(),case['name']
    assert json.loads(p.stdout)==case['expected'],case['name']
typed=ROOT/'_build/js/release/build/examples/cycle_diagnosis_receiver/cycle_diagnosis_receiver.js'
p=invoke('public-typed',[NODE,str(typed)],0,OUT)
expected_cases=[]
for case in catalog['cases']:
    if case['expected_kind']=='Success':observed={'kind':'Success','timing':case['expected']['result']}
    elif case['expected_kind']=='CombinationalLoopDetected':observed={'kind':'CombinationalLoopDetected','instances':case['expected_cycle_instances']}
    else:observed={'kind':'OtherError','error':case['expected']['error']}
    expected_cases.append({'name':case['name'],'observed':observed,'netlist_unchanged':True,'constraints_unchanged':True})
methods=[{'name':name,'observed':{'kind':'CombinationalLoopDetected','instances':['loop']}} for name in catalog['typed_methods']]
assert json.loads(p.stdout)=={'cases':expected_cases,'methods':methods}
primary=next(case for case in catalog['cases'] if case['primary'])
directory,files=fixture('extra-json',primary);driver=directory/'invoke.cjs'
driver.write_text("const fs=require('node:fs');const core=require(process.argv[2]);const lib=fs.readFileSync(process.argv[3],'utf8'),request=JSON.parse(fs.readFileSync(process.argv[4],'utf8')),net=JSON.stringify(request.netlist),sdc=request.sdc;const query={from:{kind:'input_port',name:'a',edge:'rise'},to:{kind:'output_port',name:'out',edge:'rise'}};console.log(JSON.stringify([{name:'period',result:JSON.parse(core.analyze_json(lib,JSON.stringify({...request,period_budget:true,setup_summary:true})))},{name:'context',result:JSON.parse(core.analyze_constraint_context_json(lib,net,sdc))},{name:'pin-limits',result:JSON.parse(core.analyze_pin_limits_json(lib,net,sdc,'extrapolate'))},{name:'path-query',result:JSON.parse(core.analyze_path_query_json(lib,net,sdc,JSON.stringify(query)))}]));\n",encoding='utf8',newline='\n')
p=invoke('extra-json',[NODE,str(driver),str(ROOT/'_build/js/release/build/js/js.js'),*[str(file) for file in files]],0,directory,[*files,driver])
assert json.loads(p.stdout)==catalog['extra_json_expected']
directory=OUT/'distributed';directory.mkdir();files=[directory/'library.lib',directory/'request.json']
for file,name in zip(files,['cycle-diagnosis.lib','cycle-diagnosis-request.json']):shutil.copyfile(ROOT/'examples'/name,file)
p=invoke('distributed',[NODE,str(ROOT/'tools/sta.cjs'),*[file.name for file in files]],2,directory,files);assert p.stdout==primary['expected_stdout_utf8'].encode()
directory,files=fixture('explicit-setup-check',primary)
p=invoke('explicit-setup-check',[NODE,str(ROOT/'tools/sta.cjs'),'--check-setup',*[file.name for file in files]],2,directory,files);assert p.stdout==primary['expected_stdout_utf8'].encode()
assert len(rows)==25,len(rows)
assert all(sha(file.read_bytes())==digest for file,digest in source_hashes.items())
save(True)
print(json.dumps({'all_passed':True,'frozen_cases':21,'real_process_invocations':25,'public_typed_cases':21,'affected_typed_methods':5,'additional_json_calls':4,'allHealthyAndEarlierErrorBytesUnchanged':True,'self_authored_integration':True,'third_party_adoption':False},sort_keys=True))
