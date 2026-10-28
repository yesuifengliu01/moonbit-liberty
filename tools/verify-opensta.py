#!/usr/bin/env python3
"""Reproduce the external oracle comparison. Tested with OpenSTA 2.0.17.
No timing algorithm is implemented here: it serializes the same graph to Verilog,
runs OpenSTA and the MoonBit Node consumer, and compares numeric reports.
"""
import argparse,json,pathlib,re,subprocess,sys

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--sta',default='sta',help='OpenSTA 2.0.17 executable')
    ap.add_argument('--request',default='examples/four_paths.json')
    ap.add_argument('--liberty',default='examples/sky130-demo.lib')
    args=ap.parse_args()
    root=pathlib.Path(__file__).resolve().parents[1]
    request=(root/args.request).resolve();lib=(root/args.liberty).resolve()
    data=json.loads(request.read_text(encoding='utf8'));n=data['netlist']
    for port in n['ports']:
        if port['direction'] in ('Input','Output'):port['direction']=port['direction'].lower()
    work=root/'_build'/'oracle'/request.stem;work.mkdir(parents=True,exist_ok=True)
    # Reject names that cannot be represented by this intentionally small Verilog writer.
    names=[p['name'] for p in n['ports']]+[v['name'] for v in n['nets']]+[g['name'] for g in n['gates']]
    if any(not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',v) for v in names):raise ValueError('oracle writer requires plain Verilog identifiers')
    ports=', '.join(p['direction']+' '+p['name'] for p in n['ports'])
    internal=[v['name'] for v in n['nets'] if v['name'] not in [p['name'] for p in n['ports']]]
    lines=['module dut('+ports+');']
    if internal:lines+=['wire '+', '.join(internal)+';']
    for port in n['ports']:
        if port['name'] != port['net']:
            assignment = (port['net']+' = '+port['name']) if port['direction']=='input' else (port['name']+' = '+port['net'])
            lines.append('assign '+assignment+';')
    for g in n['gates']:
        lines.append(g['cell']+' '+g['name']+' ('+', '.join('.'+v['pin']+'('+v['net']+')' for v in g['connections'])+');')
    lines+=['endmodule'];(work/'input.v').write_text('\n'.join(lines),encoding='utf8')
    (work/'input.sdc').write_text(data['sdc'],encoding='utf8')
    def tclpath(p):return '{'+p.as_posix()+'}'
    tcl=[f'read_liberty {tclpath(lib)}',f'read_verilog {tclpath(work/"input.v")}','link_design dut',f'read_sdc {tclpath(work/"input.sdc")}']
    # Model injection outside SDC: net capacitance comes from the structured input in SI.
    # This fixture declares 1pF library units (checked against the source .lib).
    library_text=lib.read_text(encoding='utf8')
    if 'capacitive_load_unit (1.0, "pf")' not in library_text or 'time_unit : "1ns"' not in library_text:raise ValueError('oracle writer currently requires example library units: 1pF and 1ns')
    if not any(p['name']=='clk' and p['direction']=='input' for p in n['ports']):raise ValueError("oracle writer currently requires the example clock port 'clk'")
    for net in n['nets']:
        if net['wire_cap_farads']:tcl.append(f'set_load {net["wire_cap_farads"]*1e12:.17g} [get_nets {net["name"]}]')
    tcl+=['set sta_report_default_digits 12','report_checks -path_delay max -digits 12 -group_count 100 -endpoint_count 100','set clk [lindex [get_clocks *] 0]']
    pins=[p['name'] for p in n['ports'] if p['name']!='clk']
    pins += [g['name']+'/'+v['pin'] for g in n['gates'] for v in g['connections'] if not (g['cell'].endswith('__dfxtp_1') and v['pin']=='CLK')]
    for pin in pins:
        tcl += [f'set pin [sta::get_port_pin_error pin {pin}]','foreach v [$pin vertices] {',
            f'foreach e {{rise fall}} {{puts "AT {pin} $e [$v arrivals_clk_delays $e $clk rise 12]"}}',
            f'foreach e {{rise fall}} {{puts "REQ {pin} $e [$v requireds_clk_delays $e $clk rise 12]"}}',
            f'foreach e {{rise fall}} {{puts "SLACK {pin} $e [$v slacks_clk_delays $e $clk rise 12]"}}','}',
            f'puts "SLEW {pin} rise [get_property $pin actual_rise_transition_max]"',f'puts "SLEW {pin} fall [get_property $pin actual_fall_transition_max]"']
    tcl += ['puts "ORACLE_DONE"','exit']
    (work/'run.tcl').write_text('\n'.join(tcl),encoding='utf8')
    ref=subprocess.run([args.sta,'-no_init','-exit',str(work/'run.tcl')],capture_output=True,text=True)
    raw=ref.stdout+ref.stderr;(work/'opensta.txt').write_text(raw,encoding='utf8')
    if ref.returncode or 'Error:' in raw or 'ORACLE_DONE' not in raw:raise RuntimeError('oracle failed; see '+str(work/'opensta.txt'))
    consumer=subprocess.run(['node',str(root/'tools/sta.cjs'),str(lib),str(request)],capture_output=True,text=True)
    (work/'moonbit.json').write_text(consumer.stdout,encoding='utf8')
    if consumer.returncode:raise RuntimeError(consumer.stdout+consumer.stderr)
    actual=json.loads(consumer.stdout)['result'];reference={}
    for line in raw.splitlines():
        m=re.match(r'^(AT|REQ|SLACK|SLEW) (\S+) (rise|fall) (.+)$',line)
        if m:
            k,p,e,v=m.groups();v=v.split()[-1]
            if 'INF' not in v:reference[(k,p,e.title())]=float(v)*1e-9
    checks=[]
    for records,fields in [(actual['nodes'],[('AT','arrival_seconds'),('SLEW','slew_seconds')]),(actual['endpoints'],[('REQ','required_seconds'),('SLACK','slack_seconds')])]:
        for item in records:
            if item['pin']=='clk' or item['pin'].endswith('/CLK'):continue
            for kind,field in fields:
                if field not in item:continue
                key=(kind,item['pin'],item['edge'])
                if key not in reference:raise ValueError('missing reference '+str(key))
                checks.append({'key':key,'actual_seconds':item[field],'reference_seconds':reference[key],'absolute_error_seconds':abs(item[field]-reference[key])})
    maximum=max(c['absolute_error_seconds'] for c in checks)
    result={'passed':maximum<=1e-12,'fields':len(checks),'maximum_absolute_error_seconds':maximum,'budget_seconds':1e-12,'checks':checks}
    (work/'comparison.json').write_text(json.dumps(result,indent=2),encoding='utf8')
    print(json.dumps({k:v for k,v in result.items() if k!='checks'},indent=2))
    return 0 if result['passed'] else 1

if __name__=='__main__':
    try:sys.exit(main())
    except Exception as e:print(str(e),file=sys.stderr);sys.exit(2)
