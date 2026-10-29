#!/usr/bin/env node
// File IO and exit policy only; all census/area computation is MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/cell-usage.cjs LIB.lib NETLIST.json';
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

Count flat mapped instances and declared Liberty area, before timing setup.
No SDC, clock, timing units/models or GBA run is required.
JSON stdout: moonbit.sta.cell-usage.v1, with complete instance and used-cell rows.
Area unit is liberty_declared_area, without physical-unit normalization.
Unknown cells, missing/invalid area and arithmetic overflow remain explicit;
total area is omitted for incomplete coverage. A finite known subtotal remains.
Instance names must be nonempty and unique. No connection/pin/timing validation.
Complete describes area coverage, not graph validity, PPA or signoff.
Files are strict UTF-8 with one optional initial BOM; paths use caller cwd.
Source files are never rewritten. Empty design is Complete with total zero.
Exit 0 Complete; 4 Incomplete; 2 argument/encoding/IO/parse/identity/output error.
--help needs no build or files. Build: moon build --target js --release`);
  } else if (args.length !== 2) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    const library = readUtf8(args[0], 'Liberty input');
    const netlist = readUtf8(args[1], 'netlist input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const output = core.analyze_cell_usage_json(library, netlist);
    console.log(output);
    const payload = JSON.parse(output);
    if (!payload.ok) process.exitCode = 2;
    else switch (payload.usage.status) {
      case 'Complete': break;
      case 'Incomplete': process.exitCode = 4; break;
      default: throw new Error('Missing or unknown cell usage status');
    }
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
