#!/usr/bin/env node
// Existing MoonBit analysis, with exclusive complete-file publication only.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/save-analysis.cjs LIB.lib REQUEST.json OUTPUT.json';
let published = false;
let destination;
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
  if (published) console.error('published output remains at ' + destination);
});
function readUtf8(file, label) {
  const bytes = fs.readFileSync(file);
  const text = bytes.toString('utf8');
  if (!Buffer.from(text, 'utf8').equals(bytes)) throw new Error('Invalid UTF-8 in ' + label);
  return text;
}
function publishNew(bytes) {
  const temporary = path.join(path.dirname(destination), `.moonbit-sta-${process.pid}-${crypto.randomUUID()}.tmp`);
  let descriptor;
  let created = false;
  let failure;
  try {
    descriptor = fs.openSync(temporary, 'wx', 0o600);
    created = true;
    fs.writeFileSync(descriptor, bytes);
    fs.fsyncSync(descriptor);
    const closing = descriptor;
    descriptor = undefined;
    fs.closeSync(closing);
    // link creates a new name only: no check-then-overwrite race or copy fallback.
    fs.linkSync(temporary, destination);
    published = true;
  } catch (error) {
    failure = error;
  }
  if (descriptor !== undefined) {
    try { fs.closeSync(descriptor); } catch (error) { failure ||= error; }
  }
  if (created) {
    try { fs.unlinkSync(temporary); } catch (error) { failure ||= error; }
  }
  if (failure) throw failure;
}
try {
  if (args.length === 1 && args[0] === '--help') {
    console.log(`${usage}

Save an original successful moonbit.sta.v1 report into a new output file.
Uses the existing analyze_json API, input formats, flags and timing model.
All ok:true reports may publish, including negative or unknown setup slack.
Strict UTF-8 input files accept their existing initial BOM policy; caller cwd.
Parent directory must exist. Existing destinations, directories or input paths
are never overwritten; no force mode, automatic mkdir or stdin variant.
Writes, flushes and closes an owned sibling candidate, then exclusively hard-links
the complete bytes into OUTPUT.json. Unsupported hard links fail visibly.
Before publication, input/analysis/write/flush/close/link failures cannot publish
partial output. Only the owned temporary name is removed during cleanup.
After publication, cleanup/stdout errors can return 2 while the complete file
remains; stderr identifies that committed state. No rollback deletion.
Exit 0: published report and original JSON stdout. Exit 2: input/analysis/host IO.
Analysis errors retain original error JSON stdout and do not publish a file.
This is complete-file visibility, not directory/power-loss durability or signoff.
--help needs no build or files. Build: moon build --target js --release`);
  } else if (args.length !== 3) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    destination = path.resolve(args[2]);
    const library = readUtf8(args[0], 'Liberty input');
    const request = readUtf8(args[1], 'request input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const report = core.analyze_json(library, request);
    const payload = JSON.parse(report);
    if (payload.ok !== true) {
      console.log(report);
      process.exitCode = 2;
    } else {
      publishNew(Buffer.from(report + '\n', 'utf8'));
      console.log(report);
    }
  }
} catch (error) {
  console.error(String(error));
  if (published) console.error('published output remains at ' + destination);
  process.exitCode = 2;
}
