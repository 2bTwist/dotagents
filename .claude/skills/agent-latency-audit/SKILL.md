---
name: agent-latency-audit
description: Measure where an agent session's wall-clock actually goes, then fix the parts that matter. Parses Claude Code session transcripts to attribute time across inference, tool execution, approval waits, and external processes. Use when the user says the agent "feels slow", asks what's causing latency/bottlenecks, wants tool calls "in ms", or wants to optimize how the agent operates. Topic- and project-agnostic.
---

# Agent Latency Audit

A discipline for answering "what is making this agent slow?" with evidence, not intuition. The data already exists: Claude Code writes every session to JSONL with per-message timestamps, so the full wall-clock can be reconstructed.

**Lead with the punchline so the user doesn't chase the wrong thing:** across large real-session studies, *tool execution is ~0.4% of end-to-end wall-clock*. Making a tool faster (e.g. ripgrep 14.7ms → 1.7ms) barely moves total runtime. The time goes to **model inference, the number of round-trips, approval/human waits, and external processes (builds/installs/network)**. Optimize those. Tool-speed micro-optimization is almost always low-leverage even when it's a satisfying multiple.

## Phase 1 — Reconstruct the wall-clock from transcripts

Transcripts live at `~/.claude/projects/<sanitized-cwd>/*.jsonl`. Each line is a JSON object. Pair every `tool_use` (in an `assistant` message) to its `tool_result` (in the next `user` message) by `tool_use_id`, and diff the top-level `timestamp` fields for true tool wall-clock. Diff consecutive messages for model turnaround.

Stream the files (they can be >1 GB); never load them whole. Core loop:

```js
// node: stream all sessions, attribute ms per tool and model turnaround
const fs=require("fs"),rl=require("readline"),path=require("path");
const DIR=process.argv[2]; // ~/.claude/projects/<slug>
const files=fs.readdirSync(DIR).filter(f=>f.endsWith(".jsonl")).map(f=>path.join(DIR,f));
const tool={}, turn=[]; const push=(o,k,v)=>(o[k]=o[k]||[]).push(v);
(async()=>{ for(const f of files){ await new Promise(res=>{
  const pend=new Map(); let lastTs=null,lastUser=false;
  rl.createInterface({input:fs.createReadStream(f)}).on("line",l=>{
    let o; try{o=JSON.parse(l)}catch{return}
    const ts=o.timestamp?Date.parse(o.timestamp):null, c=o.message&&o.message.content;
    if(o.type==="assistant"&&ts&&lastTs&&lastUser){const d=ts-lastTs; if(d>=0&&d<1.8e6)turn.push(d);}
    if(Array.isArray(c)){
      for(const b of c) if(b.type==="tool_use"&&ts) pend.set(b.id,{ts,name:b.name});
      for(const b of c) if(b.type==="tool_result"&&ts){const m=pend.get(b.tool_use_id);
        if(m){const d=ts-m.ts; if(d>=0) push(tool,m.name,d); pend.delete(b.tool_use_id);}}
    }
    if(ts){lastTs=ts; lastUser=(o.type==="user");}
  }).on("close",res); })}
  const stat=a=>{const s=a.sort((x,y)=>x-y),q=p=>s[Math.floor(p*s.length)];
    return{n:s.length,p50:q(.5),p99:q(.99),max:s.at(-1),total:s.reduce((x,y)=>x+y,0)};};
  for(const [k,a] of Object.entries(tool).sort((A,B)=>B[1].length-A[1].length))
    console.log(k.padEnd(24), JSON.stringify(stat(a)));
  console.log("MODEL TURNAROUND", JSON.stringify(stat(turn)));
})();
```

Report a table sorted by **total** time (frequency × duration), not by peak. Then split each tool's distribution into bands (`<300ms / 0.3-1s / 1-3s / 3-10s / >10s`) — bimodality reveals hidden waits (see Phase 2).

## Phase 2 — Attribute, don't assume

A `tool_use → tool_result` delta conflates several things. Separate them:

- **Read/Grep/Glob need no approval** → they are the pure harness floor (typically 1-31ms). Use them as the control.
- **Edit/Write/Bash often need approval** → a fat cluster in the 3-10s band is *human approval-click time*, not tool speed. Confirm by comparing allowlisted vs non-allowlisted commands: same command class, large p50 gap = approval tax.
- **External processes** (build/install/test/network) → irreducible runtime; lever is frequency, not speed.
- **Model turnaround** → queue + prefill + generate. Usually the single largest total. Scales with context size and how much the agent thinks, not with hardware.

Prove micro-costs locally before claiming them. Example: shell-init is the usual culprit behind a "slow" Bash floor — `zsh -i` re-sources the full profile *every call* (a stateless-shell-per-call design). Benchmark it: `zsh -i -c true` vs `zsh -c true`; profile the rc with `zmodload zsh/zprof`; time each `eval "$(...)"` line (version managers like pyenv/rbenv/nvm run external binaries on every shell). But weigh the result against the 0.4% rule before celebrating.

## Phase 3 — Fix by leverage, highest first

Rank fixes by total wall-clock returned, and name which are physics vs config vs habit:

1. **Round-trip count (highest).** Fewer, better searches. Definition-first ranking, filter out tests/vendor/generated, group and trim output so the *first* result is right and the agent stops re-searching. Batch independent tool calls into one turn (amortizes per-call overhead; 10 ops in one shell ≈ per-op cost of one). Read the right file once instead of bouncing.
2. **Approval & human waits.** Allowlist read-only commands. Don't wrap commands in `cd path;` or `VAR=…;` prefixes — the cwd persists between calls, and the compound defeats allowlist matching, forcing a prompt that costs ~1-2s of human time per call. Use absolute paths / `git -C`. Consider acceptEdits mode.
3. **Don't fixed-`sleep`-poll.** Background long jobs and let the harness wake on completion; fixed sleeps over-wait and silently dominate (often hours across a project's history).
4. **Context size.** Keep tool output and full-file Reads out of context unless they'll be used — prefill is re-paid every turn. Compact intentionally.
5. **External process frequency.** Incremental type-check/build caches, fewer clean rebuilds. Not "make the build ms"; make it run rarely.
6. **Tool/shell micro-speed (lowest).** Real but ~0.4% of end-to-end. Free wins (trim shell profile, cache completions) are worth taking once, but never the headline.

## Output

A short report: the time-attribution table (sorted by total), the bimodality finding (what is tool vs approval vs inference), and a leverage-ranked fix list that is honest about what is physics, what is config, and what is the agent's own habit. End by stating the single highest-leverage change, which is almost never "the tool was slow."
