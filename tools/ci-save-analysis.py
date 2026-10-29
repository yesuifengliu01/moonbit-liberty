"""Actual filesystem/report recipients; controlled faults are not real ENOSPC claims."""
import hashlib,json,os,pathlib,shutil,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parents[1]
CATALOG=ROOT/'examples/save-analysis-cases.json';catalog=json.loads(CATALOG.read_text(encoding='utf8'))
OUTPUT=ROOT/'_build'/(sys.argv[1] if len(sys.argv)==2 else 'save-analysis-receipts')
assert OUTPUT.resolve().is_relative_to((ROOT/'_build').resolve());OUTPUT.mkdir(parents=True,exist_ok=False)
NODE=shutil.which('node');CLI=[NODE,str(ROOT/'tools/save-analysis.cjs')]
rows=[];copies=[];states=[]
sha=lambda blob:hashlib.sha256(blob).hexdigest()
def identity(file):
    blob=file.read_bytes();return {'path':str(file.relative_to(ROOT)),'bytes':len(blob),'sha256':sha(blob)}
def save(passed=False):
    (ROOT/'_build/ci-save-analysis.json').write_text(json.dumps({'all_passed':passed,'real_process_invocations':len(rows),'originalTimingPhysicsValidation':False,'self_authored_integration':True,'third_party_adoption':False,'controlledFaultsNotRealDiskExhaustion':True,'catalog_sha256':sha(CATALOG.read_bytes()),'tested_input_copies':copies,'rows':rows,'filesystem_states':states},ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def record(name,p,stdout,stderr,command,cwd,inputs):
    out=OUTPUT/(name+'.stdout');err=OUTPUT/(name+'.stderr');out.write_bytes(stdout);err.write_bytes(stderr)
    rows.append({'case':name,'exit':p.returncode,'command':list(map(str,command)),'cwd':str(cwd.relative_to(ROOT)),'stdout':str(out.relative_to(ROOT)),'stdout_bytes':len(stdout),'stdout_sha256':sha(stdout),'stderr':str(err.relative_to(ROOT)),'stderr_bytes':len(stderr),'stderr_sha256':sha(stderr),'input_copies':inputs})
    copies.extend(item for item in inputs if item not in copies);save()
def invoke(name,command,code,cwd,files=(),env=None):
    before=[identity(file) for file in files]
    p=subprocess.run(command,cwd=cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=45)
    record(name,p,p.stdout,p.stderr,command,cwd,before)
    assert [identity(file) for file in files]==before,'Input bytes changed'
    assert p.returncode==code,(name,p.returncode,p.stderr)
    return p
def fixture(name,source='plain'):
    data=next(case for case in catalog['cases'] if case['name']==source)
    directory=OUTPUT/name;directory.mkdir()
    files=[directory/'库.lib',directory/'请求.json']
    files[0].write_bytes(data['library'].encode());files[1].write_bytes(data['request'].encode())
    return directory,files,directory/'报告.json',data['expected_report_utf8'].encode()
def snapshot(name,directory,target,allow_temporary=False):
    temporaries=list(directory.glob('.moonbit-sta-*.tmp'))
    state={'case':name,'target_kind':'file' if target.is_file() else ('directory' if target.is_dir() else 'absent'),'target':identity(target) if target.is_file() else None,'directory_entries':sorted(file.name for file in target.iterdir()) if target.is_dir() else None,'temporary_files':[identity(file) for file in temporaries]}
    states.append(state);save()
    if not allow_temporary:assert not temporaries,(name,'temporary file leaked')
    return state
def run_case(name,source='plain',code=0):
    directory,files,target,expected=fixture(name,source)
    p=invoke(name,CLI+[file.name for file in files]+[target.name],code,directory,files)
    return directory,files,target,expected,p
sources=[CATALOG,ROOT/'examples/save-analysis.lib',ROOT/'examples/save-analysis-request.json']
source_hashes={file:sha(file.read_bytes()) for file in sources}
for case in catalog['cases']:
    directory,files,target,expected,p=run_case('frozen-'+case['name'],case['name'],case['expected_exit'])
    assert p.stdout==expected and not p.stderr
    if case['publishes']:assert target.read_bytes()==expected
    else:assert not target.exists()
    snapshot('frozen-'+case['name'],directory,target)
directory,files,target,expected=fixture('existing-destination');seed=catalog['existing_destination_seed_utf8'].encode();target.write_bytes(seed)
p=invoke('existing-destination',CLI+[file.name for file in files]+[target.name],2,directory,files)
assert not p.stdout and b'EEXIST' in p.stderr and target.read_bytes()==seed
snapshot('existing-destination',directory,target)
for index,label in enumerate(['library','request']):
    directory,files,target,expected=fixture('destination-is-'+label)
    p=invoke('destination-is-'+label,CLI+[file.name for file in files]+[files[index].name],2,directory,files)
    assert not p.stdout and b'EEXIST' in p.stderr
    snapshot('destination-is-'+label,directory,target)
for index,label in enumerate(['library','request']):
    directory,files,target,expected=fixture('missing-'+label)
    actual=files.copy();actual[index]=directory/'absent'
    p=invoke('missing-'+label,CLI+[file.name for file in actual]+[target.name],2,directory,[file for file in actual if file.exists()])
    assert not p.stdout and b'ENOENT' in p.stderr and not target.exists()
    snapshot('missing-'+label,directory,target)
for index,label in enumerate(['Liberty input','request input']):
    directory,files,target,expected=fixture('bad-utf8-'+str(index));files[index].write_bytes(b'\xff')
    p=invoke('bad-utf8-'+str(index),CLI+[file.name for file in files]+[target.name],2,directory,files)
    assert not p.stdout and ('Invalid UTF-8 in '+label).encode() in p.stderr and not target.exists()
    snapshot('bad-utf8-'+str(index),directory,target)
directory,files,target,expected=fixture('missing-parent');target=directory/'absent-parent/report.json'
p=invoke('missing-parent',CLI+[file.name for file in files]+[str(target)],2,directory,files)
assert not p.stdout and b'ENOENT' in p.stderr and not target.exists()
snapshot('missing-parent',directory,target)
directory,files,target,expected=fixture('destination-directory');target.mkdir()
p=invoke('destination-directory',CLI+[file.name for file in files]+[target.name],2,directory,files)
assert not p.stdout and p.stderr and target.is_dir() and not list(target.iterdir())
snapshot('destination-directory',directory,target)
directory,files,target,expected=fixture('input-boms')
for file in files:file.write_bytes(b'\xef\xbb\xbf'+file.read_bytes())
p=invoke('input-boms',CLI+[file.name for file in files]+[target.name],0,directory,files)
assert p.stdout==target.read_bytes()==expected and not p.stderr
snapshot('input-boms',directory,target)
source_tool=OUTPUT/'source-only/tools/save-analysis.cjs';source_tool.parent.mkdir(parents=True);shutil.copyfile(ROOT/'tools/save-analysis.cjs',source_tool)
p=invoke('source-only-help',[NODE,str(source_tool),'--help'],0,OUTPUT)
assert not p.stderr and b'no build' in p.stdout and b'never overwritten' in p.stdout
directory,files,target,expected=fixture('missing-build')
p=invoke('missing-build',[NODE,str(source_tool)]+[str(file) for file in files]+[str(target)],2,directory,files)
assert not p.stdout and b'Cannot find module' in p.stderr and not target.exists()
snapshot('missing-build',directory,target)
p=invoke('argument-count',CLI,2,OUTPUT);assert not p.stdout and b'Usage:' in p.stderr
directory=OUTPUT/'distributed';directory.mkdir();files=[directory/'save-analysis.lib',directory/'save-analysis-request.json']
for file in files:shutil.copyfile(ROOT/'examples'/file.name,file)
target=directory/'report.json';expected=next(case['expected_report_utf8'].encode() for case in catalog['cases'] if case['name']=='plain')
p=invoke('distributed',CLI+[file.name for file in files]+[target.name],0,directory,files)
assert p.stdout==target.read_bytes()==expected and not p.stderr
snapshot('distributed',directory,target)

# Test-only injection wraps real fs calls; the publisher has no test hooks.
preload=OUTPUT/'controlled-filesystem.cjs'
preload.write_text('''const fs=require('node:fs'),path=require('node:path');
const mode=process.env.STA_IO_TEST_MODE,trace=process.env.STA_IO_TEST_TRACE;
const open=fs.openSync,write=fs.writeFileSync,sync=fs.fsyncSync,close=fs.closeSync,link=fs.linkSync,unlink=fs.unlinkSync;
const descriptors=new Set(),names=new Set();
function fault(site,code='EIO'){write(path.join(trace,site+'.json'),JSON.stringify({site,synthetic:true,realFilesystemCalls:true})+'\\n');return Object.assign(new Error('controlled '+site+' failure'),{code});}
fs.openSync=function(file,flags,...rest){const fd=open(file,flags,...rest);if(flags==='wx'){descriptors.add(fd);names.add(String(file));}return fd;};
fs.writeFileSync=function(file,data,...rest){if(mode==='partial-write'&&descriptors.has(file)){const part=Buffer.from(data).subarray(0,17);const n=fs.writeSync(file,part);write(path.join(trace,'actual-partial.bin'),part.subarray(0,n));throw fault('partial-write','ENOSPC');}return write(file,data,...rest);};
fs.fsyncSync=function(fd){if(descriptors.has(fd)&&mode==='fsync')throw fault('fsync');const value=sync(fd);if(descriptors.has(fd)&&mode==='barrier'){write(path.join(trace,process.pid+'.ready'),JSON.stringify({pid:process.pid,candidate:[...names][0]})+'\\n');const until=Date.now()+30000;while(!fs.existsSync(path.join(trace,'release'))){if(Date.now()>until)throw fault('barrier-timeout');Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,20);}}return value;};
fs.closeSync=function(fd){const ours=descriptors.has(fd);const value=close(fd);descriptors.delete(fd);if(ours&&mode==='close')throw fault('close');return value;};
fs.linkSync=function(from,to){if(names.has(String(from))&&mode==='link')throw fault('link');return link(from,to);};
fs.unlinkSync=function(file){if(names.has(String(file))&&mode==='cleanup-after-publication')throw fault('cleanup','EACCES');return unlink(file);};
''',encoding='utf8')
for mode in catalog['controlled_faults']:
    directory,files,target,expected=fixture('fault-'+mode);trace=directory/'trace';trace.mkdir()
    env=os.environ.copy();env.update(STA_IO_TEST_MODE=mode,STA_IO_TEST_TRACE=str(trace))
    p=invoke('fault-'+mode,[NODE,'-r',str(preload),*CLI[1:]]+[file.name for file in files]+[target.name],2,directory,files,env)
    assert not p.stdout and b'controlled' in p.stderr
    committed=mode=='cleanup-after-publication'
    if committed:assert target.read_bytes()==expected and b'published output remains at' in p.stderr
    else:assert not target.exists() and b'published output remains at' not in p.stderr
    state=snapshot('fault-'+mode,directory,target,allow_temporary=committed)
    if committed:
        assert len(state['temporary_files'])==1
        assert (ROOT/state['temporary_files'][0]['path']).read_bytes()==expected
    if mode=='partial-write':assert (trace/'actual-partial.bin').read_bytes()==expected[:17]
directory,files,target,expected=fixture('stdout-closed')
command=CLI+[file.name for file in files]+[target.name];before=[identity(file) for file in files]
p=subprocess.Popen(command,cwd=directory,stdout=subprocess.PIPE,stderr=subprocess.PIPE);p.stdout.close();p.stdout=None
_,stderr=p.communicate(timeout=45);record('stdout-closed',p,b'',stderr,command,directory,before)
assert p.returncode==2 and b'stdout:' in stderr and b'published output remains at' in stderr and target.read_bytes()==expected
assert [identity(file) for file in files]==before;snapshot('stdout-closed',directory,target)
directory,files,target,expected=fixture('concurrent');barrier=directory/'barrier';barrier.mkdir()
env=os.environ.copy();env.update(STA_IO_TEST_MODE='barrier',STA_IO_TEST_TRACE=str(barrier))
command=[NODE,'-r',str(preload),*CLI[1:]]+[file.name for file in files]+[target.name]
before=[identity(file) for file in files]
processes=[subprocess.Popen(command,cwd=directory,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE) for _ in range(2)]
race_error=None
try:
    until=time.monotonic()+35
    while len(list(barrier.glob('*.ready')))<2 and time.monotonic()<until:time.sleep(.02)
    ready=list(barrier.glob('*.ready'));assert len(ready)==2,'Both actual candidates must reach the fsync barrier'
    assert not target.exists(),'Destination appeared before either publication'
    for index,file in enumerate(sorted(ready)):
        candidate=pathlib.Path(json.loads(file.read_text(encoding='utf8'))['candidate']);blob=candidate.read_bytes();assert blob==expected
        (barrier/('candidate-'+str(index)+'.before')).write_bytes(blob)
except BaseException as error:race_error=error
finally:(barrier/'release').write_bytes(b'release\n')
race_results=[]
for index,p in enumerate(processes):
    stdout,stderr=p.communicate(timeout=45);record('concurrent-'+str(index),p,stdout,stderr,command,directory,before)
    race_results.append((p,stdout,stderr))
if race_error:raise race_error
for p,stdout,stderr in race_results:
    assert p.returncode in [0,2]
    if p.returncode==0:assert stdout==expected and not stderr
    else:assert not stdout and b'EEXIST' in stderr
assert sorted(p.returncode for p in processes)==[0,2] and target.read_bytes()==expected
assert [identity(file) for file in files]==before;snapshot('concurrent',directory,target)
assert len(rows)==27,len(rows)
assert all(sha(file.read_bytes())==value for file,value in source_hashes.items())
save(True)
print(json.dumps({'all_passed':True,'real_process_invocations':27,'frozen_original_reports':5,'concurrent_winners':1,'controlled_faults':5,'self_authored_integration':True,'third_party_adoption':False,'timing_science_or_old_suite_rerun':False},sort_keys=True))
