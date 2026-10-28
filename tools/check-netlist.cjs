#!/usr/bin/env node
// File IO only; the MoonBit decoder owns field order, errors and semantic paths.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/check-netlist.cjs NETLIST.json';
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
});
try {
  if (args.length === 1 && args[0] === '--help') {
    console.log(`${usage}

Check the existing standalone Netlist JSON structure (ports, gates, nets).
UTF-8 input may have one initial BOM. Input bytes are never rewritten.
JSON stdout uses moonbit.sta.netlist.v1. Exit 0: decoded. Exit 2: error.
Decode errors retain the original error and a semantic JSON Pointer.
Pointers are relative to the Netlist root: empty string is root, array indices
are 0-based elements. Missing fields point to the intended absent child.
Invalid JSON syntax has null pointer. These are not character/line offsets.
First error follows decoder field order, not JSON object-key insertion order.
Unknown fields, Unicode values and the old numeric acceptance are preserved.
This checks structure only, not graph validity, numeric ranges or timing closure.
Host IO/encoding/output diagnostics use stderr. --help needs no build or inputs.
Build: moon build --target js --release`);
  } else if (args.length !== 1) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    const bytes = fs.readFileSync(args[0]);
    const text = bytes.toString('utf8');
    if (!Buffer.from(text, 'utf8').equals(bytes)) {
      throw new Error('Invalid UTF-8 in netlist input');
    }
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const result = core.check_netlist_json(text);
    console.log(result);
    if (!JSON.parse(result).ok) process.exitCode = 2;
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
