---
name: perf-harness-init
description: Scaffold the full performance harness into any React/web project (Next.js, Vite-React, or plain web). Installs the measurement engines, copies the configs + the perf-check verifier CLI from this skill's templates, sets telemetry-off, wires CI, and calibrates budgets. Invoke in a fresh repo to make it perf-gated. Triggers "set up the perf harness", "add perf gating to this project", "init perf harness".
harness:
  degrades: [mcp-browser]
---

# perf-harness-init

Turns any React/web repo into a perf-gated project using the layered harness
(design: portfolio `specs/plans/2026-06-22-groundwork-perf-harness.md`). All
resources live in this skill's `templates/` dir — copy, adapt, calibrate.

## Scope check (do first)
- ✅ Web apps: Next.js, Vite-React, plain web. The browser layer (Lighthouse,
  Playwright, CWV, CPU profiles) works for any web app.
- ⚠️ React-specific extras (React Scan overlay, render-count tests) only apply
  to React. For non-React web, skip those two, keep the rest.
- ❌ Not for backend/CLI/library projects (no page to measure). Stop and say so.

Detect the stack: read `package.json` + `next.config.*` / `vite.config.*`.

## Steps
1. **Install deps** (respect the repo's package manager; use `socket` prefix if available):
   - Core: `vitest @vitejs/plugin-react vite @testing-library/react @testing-library/dom jsdom @playwright/test @lhci/cli size-limit @size-limit/file tsx lighthouse`
   - React: `react-scan eslint-plugin-react-hooks`
   - Next.js only: `@next/bundle-analyzer`; Vite only: `rollup-plugin-visualizer`
   - If deployed on Vercel: `@vercel/speed-insights` (runtime dep)
   - Then `pnpm exec playwright install chromium` (ignore-scripts skips the auto-download).
2. **Copy templates** from `<this skill dir>/templates/` into the repo root, adapting:
   - `vitest.config.ts`, `vitest.setup.ts`, `playwright.config.ts`, `lighthouserc.js`, `.size-limit.js`, `budgets.json`, `perf/`, `tools/perf-check/`, `e2e/`, `PERF.md`.
   - `github-workflows/perf.yml` → `.github/workflows/perf.yml`.
3. **Adapt per stack:**
   - **Next.js:** keep `.size-limit.js` path `.next/static/chunks/**/*.js`; serve = `next start`; wrap `next.config` with `@next/bundle-analyzer`.
   - **Vite:** `.size-limit.js` path `dist/assets/*.js`; serve = `vite preview --port 3000`; `lighthouserc.js` startServerCommand = `vite preview --port 3000`; swap analyzer for `rollup-plugin-visualizer`.
   - Update `playwright.config.ts` webServer command + `lighthouserc.js` to the repo's build/serve.
4. **Wire scripts** into `package.json`: `test`, `test:watch`, `e2e`, `e2e:perf`, `size`, `lh`, `analyze`, `perf:check`, `perf:calibrate`, `perf` (copy from `templates/PERF.md`'s reference table).
5. **Telemetry off:** create/merge `.claude/settings.json` with `env: { NO_TELEMETRY:"1", NEXT_TELEMETRY_DISABLED:"1", DO_NOT_TRACK:"1" }`; run `pnpm exec next telemetry disable` if Next.
6. **React only:** add dev-only React Scan init in the root client provider/layout (guard `NODE_ENV==="development"`); raise `react-hooks/exhaustive-deps` to error.
7. **Calibrate:** `pnpm build` → serve → `pnpm perf:calibrate` → stop. Fills `budgets.json` from measured prod values (measure-then-ratchet).
8. **Verify:** `pnpm test`, `pnpm lint`, `pnpm build` green; `pnpm perf:check --json` emits a verdict.

## Known gotchas (already solved in the templates)
- `perf-check` shells out (child_process) to lighthouse + size-limit — the node APIs break under tsx/esbuild (`__name`, unicorn-magic). Don't "fix" them back to imports.
- Use `@size-limit/file` (not `preset-app`) — preset-app needs a Chromium it can't get under ignore-scripts.
- Playwright transpiles to CJS — no `import.meta.url` in specs (read files via cwd).

## Composes with
- **`perf-loop`** skill — the diff-driven autonomous test+optimize run loop (this skill only sets up the gates it polls).
- **`mcp__MCP_DOCKER__browser_*`** — the agent's live browser tools for exploration (no third-party browser-testing dep needed; we removed Expect in favor of these).
