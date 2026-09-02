#!/usr/bin/env node
// Attribute an agent session's wall-clock across tools and model turnaround.
//
//   node attribute.mjs ~/.claude/projects/<sanitized-cwd>
//
// Streams every .jsonl in the directory (they reach gigabytes; never read one
// whole). Pairs each `tool_use` block to its `tool_result` by `tool_use_id` and
// diffs the top-level `timestamp` fields, which is true tool wall-clock
// including any approval wait. Separately diffs user->assistant message pairs
// for model turnaround.
//
// Prints one row per tool sorted by TOTAL time (frequency x duration), because
// a 20ms tool called 4000 times outranks a 9s tool called twice.

import fs from "node:fs";
import path from "node:path";
import readline from "node:readline";

const DIR = process.argv[2];
if (!DIR) {
  console.error("usage: node attribute.mjs <transcript-dir>");
  process.exit(2);
}

// A turnaround longer than 30 minutes is the human walking away, not the model.
const TURNAROUND_CEILING_MS = 30 * 60 * 1000;

const toolDurations = new Map(); // tool name -> ms[]
const turnarounds = [];

function record(map, key, value) {
  if (!map.has(key)) map.set(key, []);
  map.get(key).push(value);
}

async function scan(file) {
  const pending = new Map(); // tool_use_id -> {ts, name}
  let lastTs = null;
  let lastWasUser = false;

  const rl = readline.createInterface({ input: fs.createReadStream(file) });
  for await (const line of rl) {
    let entry;
    try {
      entry = JSON.parse(line);
    } catch {
      continue; // a partially-flushed final line is normal on a live session
    }

    const ts = entry.timestamp ? Date.parse(entry.timestamp) : null;
    const content = entry.message && entry.message.content;

    if (entry.type === "assistant" && ts && lastTs && lastWasUser) {
      const delta = ts - lastTs;
      if (delta >= 0 && delta < TURNAROUND_CEILING_MS) turnarounds.push(delta);
    }

    if (Array.isArray(content)) {
      for (const block of content) {
        if (block.type === "tool_use" && ts) {
          pending.set(block.id, { ts, name: block.name });
        }
      }
      for (const block of content) {
        if (block.type !== "tool_result" || !ts) continue;
        const started = pending.get(block.tool_use_id);
        if (!started) continue; // result whose call is in an earlier file
        const delta = ts - started.ts;
        if (delta >= 0) record(toolDurations, started.name, delta);
        pending.delete(block.tool_use_id);
      }
    }

    if (ts) {
      lastTs = ts;
      lastWasUser = entry.type === "user";
    }
  }
}

function stats(values) {
  const sorted = [...values].sort((a, b) => a - b);
  const at = (p) => sorted[Math.min(sorted.length - 1, Math.floor(p * sorted.length))];
  return {
    n: sorted.length,
    p50: at(0.5),
    p99: at(0.99),
    max: sorted[sorted.length - 1],
    total: sorted.reduce((a, b) => a + b, 0),
  };
}

const files = fs
  .readdirSync(DIR)
  .filter((f) => f.endsWith(".jsonl"))
  .map((f) => path.join(DIR, f));

for (const file of files) await scan(file);

const rows = [...toolDurations.entries()]
  .map(([name, values]) => [name, stats(values)])
  .sort((a, b) => b[1].total - a[1].total);

let toolTotal = 0;
for (const [name, s] of rows) {
  toolTotal += s.total;
  console.log(name.padEnd(24), JSON.stringify(s));
}

const turn = stats(turnarounds);
console.log("MODEL TURNAROUND".padEnd(24), JSON.stringify(turn));

const measured = toolTotal + turn.total;
if (measured > 0) {
  const share = ((toolTotal / measured) * 100).toFixed(2);
  console.log(
    `\nTOOL SHARE ${share}% of (tool + turnaround) = ${Math.round(toolTotal / 1000)}s of ${Math.round(measured / 1000)}s`,
  );
  console.log(
    "Denominator is measured time only: it excludes idle gaps between sessions,\n" +
      "so treat it as an upper bound on the tool share of true end-to-end wall-clock.",
  );
}
