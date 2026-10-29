"""Full frozen endpoint-priority facts through real public/file recipients."""
import hashlib,json,math,os,pathlib,shutil,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[1];CATALOG=ROOT/'examples/setup-priority-cases.json'
catalog=json.loads(CATALOG.read_text(encoding='utf8'));OUT=ROOT/'_build/setup-priority-receipts';OUT.mkdir(parents=True,exist_ok=False)
NODE=shutil.which('node');CLI=[NODE,str(ROOT/'tools/prioritize-setup.cjs')]
sha=lambda b:hashlib.sha256(b).hexdigest();rows=[];copies=[]
def identity(file):
    b=file.read_bytes();return {'path':str(file.relative_to(ROOT)),'bytes':len(b),'sha256':sha(b)}
def save(passed=False):
    (ROOT/'_build/ci-setup-priority.json').write_text(json.dumps({'all_passed':passed,'frozen_cases':len(catalog['cases']),'real_process_invocations':len(rows),'public_typed_queries':11,'public_json_setting_queries':7,'freshOriginalProducerCompatibilityCalls':1,'self_authored_integration':True,'third_party_adoption':False,'oldScientificReferenceComparisonOrPublicationRerun':False,'catalog_sha256':sha(CATALOG.read_bytes()),'tested_input_copies':copies,'rows':rows},ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def equal(got,want):
    if isinstance(want,dict):
        assert isinstance(got,dict) and got.keys()==want.keys(),('object keys',got,want)
        for key in want:equal(got[key],want[key])
    elif isinstance(want,list):
        assert isinstance(got,list) and len(got)==len(want),(got,want)
        for a,b in zip(got,want):equal(a,b)
    elif isinstance(want,bool):assert type(got) is bool and got==want,(got,want)
    elif isinstance(want,(float,int)):
        assert type(got) in [int,float] and math.isfinite(got) and got==want,(got,want)
    else:assert type(got) is type(want) and got==want,(got,want)
def record(name,p,out,err,command,cwd,before):
    a=OUT/(name+'.stdout');b=OUT/(name+'.stderr');a.write_bytes(out);b.write_bytes(err)
    rows.append({'case':name,'command':list(map(str,command)),'cwd':str(cwd.relative_to(ROOT)),'exit':p.returncode,'stdout':str(a.relative_to(ROOT)),'stdout_bytes':len(out),'stdout_sha256':sha(out),'stderr':str(b.relative_to(ROOT)),'stderr_bytes':len(err),'stderr_sha256':sha(err),'input_copies':before})
    copies.extend(item for item in before if item not in copies);save()
def invoke(name,command,code,cwd,files=()):
    before=[identity(file) for file in files]
    p=subprocess.run(command,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=60)
    record(name,p,p.stdout,p.stderr,command,cwd,before)
    assert [identity(file) for file in files]==before,'Source file bytes changed'
    assert p.returncode==code,(name,p.returncode,p.stderr)
    return p
def report_file(name,text):
    directory=OUT/name;directory.mkdir();file=directory/'报告😀.json';file.write_bytes(text.encode());return directory,file
source_paths=[CATALOG,ROOT/'examples/setup-priority-report.json',ROOT/'examples/setup-priority.lib',ROOT/'examples/setup-priority-request.json']
source_hashes={path:sha(path.read_bytes()) for path in source_paths}
api_cases=[]
for case in catalog['cases']:
    maximum=case['max_endpoints']
    if 'special_limit' in case or type(maximum) is not int or maximum<0 or maximum>2147483647:
        api_cases.append(case);continue
    directory,file=report_file(case['name'],catalog['reports'][case['report']])
    p=invoke(case['name'],CLI+['--max-endpoints',str(maximum),file.name],case['expected_exit'],directory,[file])
    assert not p.stderr;equal(json.loads(p.stdout),case['expected'])
assert len(api_cases)==7
directory=OUT/'api-settings';directory.mkdir();files=[];settings=[]
for index,case in enumerate(api_cases):
    file=directory/(str(index)+'.json');file.write_bytes(catalog['reports'][case['report']].encode());files.append(file)
    settings.append({'name':case['name'],'file':str(file),'limit':case['max_endpoints'],'special':case.get('special_limit')})
setting_file=directory/'settings.json';setting_file.write_text(json.dumps(settings,ensure_ascii=False),encoding='utf8');files.append(setting_file)
driver=directory/'invoke.cjs';driver.write_text("const fs=require('node:fs');const core=require(process.argv[2]);const settings=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));console.log(JSON.stringify(settings.map(s=>({name:s.name,result:JSON.parse(core.prioritize_setup_json(fs.readFileSync(s.file,'utf8'),s.special==='nan'?NaN:s.special==='positive-infinity'?Infinity:s.special==='negative-infinity'?-Infinity:s.limit))}))));\n",encoding='utf8');files.append(driver)
p=invoke('api-settings',[NODE,str(driver),str(ROOT/'_build/js/release/build/js/js.js'),str(setting_file)],0,directory,files)
assert not p.stderr;equal(json.loads(p.stdout),[{'name':case['name'],'result':case['expected']} for case in api_cases])
typed=ROOT/'_build/js/release/build/examples/setup_priority_receiver/setup_priority_receiver.js'
p=invoke('public-typed',[NODE,str(typed)],0,OUT)
assert not p.stderr
expected=[]
for case in catalog['cases']:
    if case['public_typed']:
        source=json.loads(catalog['reports'][case['report']])['result']['endpoints'];priorities=case['expected']['priorities']
        expected.append({'name':case['name'],'priorities':priorities,'selected_source_endpoints':[source[row['worst_source_index']] for row in priorities['rows']],'original_unchanged':True})
equal(json.loads(p.stdout),expected);assert len(expected)==11
directory=OUT/'distributed';directory.mkdir();file=directory/'report.json';shutil.copyfile(ROOT/'examples/setup-priority-report.json',file)
fresh=next(case for case in catalog['cases'] if case['name']=='fresh-old-cli-report')
p=invoke('distributed',CLI+['--max-endpoints','2',file.name],0,directory,[file]);assert not p.stderr;equal(json.loads(p.stdout),fresh['expected'])
directory,file=report_file('default',catalog['reports']['default-ten-truncates-known-only'])
p=invoke('default',CLI+[file.name],0,directory,[file]);assert not p.stderr;equal(json.loads(p.stdout),next(c['expected'] for c in catalog['cases'] if c['name']=='default-ten-truncates-known-only'))
directory,file=report_file('bom',catalog['reports']['fresh-old-cli-report']);file.write_bytes(b'\xef\xbb\xbf'+file.read_bytes())
p=invoke('bom',CLI+['--max-endpoints','2',file.name],0,directory,[file]);assert not p.stderr;equal(json.loads(p.stdout),fresh['expected'])
directory,file=report_file('bad-utf8','');file.write_bytes(b'\xff')
p=invoke('bad-utf8',CLI+[file.name],2,directory,[file]);assert not p.stdout and b'Invalid UTF-8 in report input' in p.stderr
p=invoke('missing-file',CLI+['absent-report.json'],2,OUT);assert not p.stdout and b'ENOENT' in p.stderr
for name,args in [('argument-count',[]),('missing-option-value',['--max-endpoints','2']),('negative-cli-limit',['--max-endpoints','-1','absent']),('fractional-cli-limit',['--max-endpoints','1.5','absent']),('nonnumeric-cli-limit',['--max-endpoints','no','absent']),('oversized-cli-limit',['--max-endpoints','2147483648','absent'])]:
    p=invoke(name,CLI+args,2,OUT);assert not p.stdout and p.stderr
source_tool=OUT/'source-only/tools/prioritize-setup.cjs';source_tool.parent.mkdir(parents=True);shutil.copyfile(ROOT/'tools/prioritize-setup.cjs',source_tool)
p=invoke('source-only-help',[NODE,str(source_tool),'--help'],0,OUT);assert not p.stderr and b'needs no build' in p.stdout and b'0..2147483647' in p.stdout
directory,file=report_file('missing-build',catalog['reports']['fresh-old-cli-report'])
p=invoke('missing-build',[NODE,str(source_tool),file.name],2,directory,[file]);assert not p.stdout and b'Cannot find module' in p.stderr
directory,file=report_file('stdout-closed',catalog['reports']['fresh-old-cli-report']);command=CLI+[file.name];before=[identity(file)]
p=subprocess.Popen(command,cwd=directory,stdout=subprocess.PIPE,stderr=subprocess.PIPE);p.stdout.close();p.stdout=None
_,stderr=p.communicate(timeout=60);record('stdout-closed',p,b'',stderr,command,directory,before)
assert p.returncode==2 and b'stdout:' in stderr and [identity(file)]==before
directory=OUT/'original-compatibility';directory.mkdir();files=[directory/'library.lib',directory/'request.json']
for file,name in zip(files,['setup-priority.lib','setup-priority-request.json']):shutil.copyfile(ROOT/'examples'/name,file)
p=invoke('original-analysis-byte-compatibility',[NODE,str(ROOT/'tools/sta.cjs'),*[file.name for file in files]],0,directory,files)
assert not p.stderr and p.stdout==(ROOT/'examples/setup-priority-report.json').read_bytes()
assert all(sha(file.read_bytes())==digest for file,digest in source_hashes.items())
assert len(rows)==45,len(rows)
save(True)
print(json.dumps({'all_passed':True,'frozen_cases':35,'real_process_invocations':45,'public_typed_queries':11,'public_json_setting_queries':7,'freshOriginalProducerCompatibilityCalls':1,'self_authored_integration':True,'third_party_adoption':False,'timingQueryReruns':False},sort_keys=True))
