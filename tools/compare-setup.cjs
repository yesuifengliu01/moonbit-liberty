#!/usr/bin/env node
// File IO and exit policy only; report matching/slack comparison is MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/compare-setup.cjs [--max-slack-loss SECONDS] BASELINE.json CANDIDATE.json';
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

Compare endpoint/edge setup slack in two existing moonbit.sta.v1 success reports.
Default allowed loss is zero; SECONDS must be finite and nonnegative.
Delta is candidate minus baseline; a loss equal to the threshold is allowed.
All rows follow baseline order then candidate-only order, with exact pin/edge names.
Missing/added endpoints, unknown slack and subtraction overflow are explicit;
unknown values are not zero and overflowing deltas are omitted.
JSON stdout: moonbit.sta.setup-compare.v1, complete comparison counts and rows.
Exit 0 fully comparable/no regression; 3 any known regression; 4 incomplete;
2 args/encoding/IO/report/settings/output error. Known regression takes precedence.
This is relative preservation only; unchanged negative slack can pass this gate.
Use the original setup checker for absolute compliance. Caller controls comparable
design/model/constraint provenance. No timing rerun, mapping guesses or signoff.
Strict UTF-8 reports accept one initial BOM, caller cwd, no source rewrite.
--help needs no build or files. Build: moon build --target js --release`);
  } else {
    let limit = 0;
    let files = args;
    if (args.length === 4 && args[0] === '--max-slack-loss') {
      limit = args[1].trim() ? Number(args[1]) : NaN;
      files = args.slice(2);
    }
    if (files.length !== 2) {
      console.error(usage);
      process.exitCode = 2;
    } else {
      const baseline = readUtf8(files[0], 'baseline report');
      const candidate = readUtf8(files[1], 'candidate report');
      const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
      const output = core.compare_setup_json(baseline, candidate, limit);
      console.log(output);
      const payload = JSON.parse(output);
      if (!payload.ok) process.exitCode = 2;
      else switch (payload.comparison.status) {
        case 'NoSetupRegression': break;
        case 'SetupRegressed': process.exitCode = 3; break;
        case 'SetupComparisonIncomplete': process.exitCode = 4; break;
        default: throw new Error('Missing or unknown setup comparison status');
      }
    }
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
