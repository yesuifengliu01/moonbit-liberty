#!/usr/bin/env node
// IO/check policy only. Original GBA and declared-limit comparisons are MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/check-pin-limits.cjs [--range-policy MODE] LIB.lib NETLIST.json CONSTRAINTS.sdc';
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
});
function readUtf8(file, label) {
  const bytes = fs.readFileSync(file);
  const text = bytes.toString('utf8');
  if (!Buffer.from(text, 'utf8').equals(bytes)) throw new Error('Invalid UTF-8 in ' + label);
  return text;
}
try {
  if (args.length === 1 && args[0] === '--help') {
    console.log(`${usage}

Check explicit output max_capacitance and input/output max_transition limits.
Missing pin transition bounds fall back to library.default_max_transition.
Uses original full-design GBA slew/load, including FF CLK/D/Q and alias loads.
No new timing model, PBA, port/SDC overrides, minimum or fanout rule checks.
MODE: extrapolate (default), reject, clamp; physical reported load is never clamped.
JSON stdout: moonbit.sta.pin-limits.v1, original result and complete pin_limits.
Rows contain SI actual/limit/margin and declaration origin. Missing/invalid bounds
never become zero. Met describes supported declared rules, not bound coverage/signoff.
Files are strict UTF-8; library/netlist accept one initial BOM, SDC stays verbatim.
Relative paths use caller cwd; source files are never rewritten.
Exit 0 Met; 3 Violated; 4 InvalidLimits/NoDeclaredLimits; 2 input/IO/analysis/output error.
--help needs no build or files. Build: moon build --target js --release`);
  } else {
    let mode = 'extrapolate';
    let files = args;
    if (args.length === 5 && args[0] === '--range-policy') {
      mode = args[1];
      files = args.slice(2);
    }
    if (files.length !== 3) {
      console.error(usage);
      process.exitCode = 2;
    } else {
      const library = readUtf8(files[0], 'Liberty input');
      const netlist = readUtf8(files[1], 'netlist input');
      const sdc = readUtf8(files[2], 'SDC input');
      const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
      const output = core.analyze_pin_limits_json(library, netlist, sdc, mode);
      console.log(output);
      const payload = JSON.parse(output);
      if (!payload.ok) process.exitCode = 2;
      else switch (payload.pin_limits.status) {
        case 'Met': break;
        case 'Violated': process.exitCode = 3; break;
        case 'InvalidLimits':
        case 'NoDeclaredLimits': process.exitCode = 4; break;
        default: throw new Error('Missing or unknown pin limit status');
      }
    }
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
