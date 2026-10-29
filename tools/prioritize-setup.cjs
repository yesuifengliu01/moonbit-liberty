#!/usr/bin/env node
// File IO and argument policy only; the existing-result query is MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/prioritize-setup.cjs [--max-endpoints N] REPORT.json';
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
});
try {
  if (args.length === 1 && args[0] === '--help') {
    console.log(`${usage}

Query distinct setup endpoints in an existing successful moonbit.sta.v1 report.
Choose the worst known edge per exact pin; equal slacks retain source order.
--max-endpoints is decimal digits in 0..2147483647, default 10. Zero selects none.
All-unknown pins and total known/unknown/omitted counts remain fully visible.
Returned zero-based source indices retrieve the original endpoint/path records.
This reads pin/edge/slack only; it does not recompute or validate timing/paths.
Negative/unknown slacks remain successful queries; this is no setup pass gate.
Input is strict UTF-8 with optional one initial BOM; caller cwd/Unicode paths.
Exit 0: complete query JSON. Exit 2: args/report/limit/encoding/build/host IO.
No file save/overwrite mode. --help needs no build, files or stdin.
Build: moon build --target js --release`);
  } else {
    let maximum = 10;
    let file;
    if (args.length === 1) file = args[0];
    else if (args.length === 3 && args[0] === '--max-endpoints') {
      if (!/^\d+$/.test(args[1])) throw new Error('max-endpoints must be decimal digits in 0..2147483647');
      maximum = Number(args[1]);
      if (!Number.isInteger(maximum) || maximum > 2147483647) throw new Error('max-endpoints must be decimal digits in 0..2147483647');
      file = args[2];
    } else throw new Error(usage);
    const bytes = fs.readFileSync(file);
    const text = bytes.toString('utf8');
    if (!Buffer.from(text, 'utf8').equals(bytes)) throw new Error('Invalid UTF-8 in report input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const result = core.prioritize_setup_json(text, maximum);
    console.log(result);
    if (JSON.parse(result).ok !== true) process.exitCode = 2;
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
