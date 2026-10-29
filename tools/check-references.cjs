#!/usr/bin/env node
// Strict file IO and exit policy only; all reference checks are MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/check-references.cjs LIB.lib NETLIST.json';
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

Preflight all scalar names/references before SDC or timing setup.
Checks net/port/instance identities, exact cell/pin references, duplicate or
missing scalar pins and undeclared port/connection nets in deterministic order.
JSON stdout: moonbit.sta.references.v1, complete references report with raw names,
0-based semantic JSON Pointers and first-declaration pointers for duplicates.
No units, capacitance models, SDC, graph build or GBA required.
ReferencesResolved means this profile only. Driver/cycle/numeric/direction,
hierarchy/bus, sequential/timing readiness and graph signoff are not checked.
Unknown cells suppress unknowable pin findings; independent checks continue.
Files are strict UTF-8 with one optional initial BOM, caller-relative paths;
source files are never rewritten. Structural decoding retains original pointers.
Exit 0 ReferencesResolved; 3 ReferenceIssuesFound; 2 args/encoding/IO/parse/output.
--help needs no build or files. Build: moon build --target js --release`);
  } else if (args.length !== 2) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    const library = readUtf8(args[0], 'Liberty input');
    const netlist = readUtf8(args[1], 'netlist input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const output = core.check_netlist_references_json(library, netlist);
    console.log(output);
    const payload = JSON.parse(output);
    if (!payload.ok) process.exitCode = 2;
    else switch (payload.references.status) {
      case 'ReferencesResolved': break;
      case 'ReferenceIssuesFound': process.exitCode = 3; break;
      default: throw new Error('Missing or unknown reference status');
    }
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
