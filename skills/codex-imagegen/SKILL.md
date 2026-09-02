---
name: codex-imagegen
description: Generate or edit real image files (PNG/JPEG) by shelling out to Codex CLI's bundled imagegen skill (gpt-image family, billed to the ChatGPT subscription, no API key). Use when the user asks Claude to generate, create, or edit images, illustrations, hero images, icons, OG/social images, textures, or photo-style assets, or when a task needs an image file that markup/SVG cannot produce. Not for charts or token-driven UI graphics (build those in code).
---

# Codex imagegen

Claude Code has no first-party image model. Codex CLI ships one: its bundled `imagegen` skill generates and edits images against the user's existing ChatGPT login. Verified against codex-cli 0.144.1 with `codex login status` reporting ChatGPT; re-check both if a run fails at the auth step.

## Decision rule first

Prefer code over pixels when the surface allows it: theme-aware markup/SVG for infographics, dataviz, and UI graphics (they follow light/dark and stay accessible). Use imagegen for photographic/illustrative assets, textures, mascots, hero art, and anything destined for social/marketing where a bitmap is the deliverable.

## Command shape

```bash
codex exec --skip-git-repo-check -s workspace-write \
  -C "<absolute output dir>" \
  "<prompt>" </dev/null
```

- `--skip-git-repo-check` is required outside git repos (scratchpad); harmless inside them.
- `-s workspace-write` so Codex can write the file. Never `danger-full-access` for images.
- `</dev/null` prevents a stdin hang.
- Set an explicit Bash timeout of 300000 or more; generation takes 1 to 3 minutes per image.

## Prompt requirements

Everything is natural language, there are no size/quality flags. Always state:

1. "Use your imagegen skill" (anchors tool choice).
2. The image content, style, and palette. Where the project fixes a palette or a tone, state the hex values and the mood in the prompt — the model has no access to the repo's design tokens.
3. Size (e.g. 1024x1024, 1536x1024), quality (LOW for drafts and plumbing tests, HIGH only for finals), count, transparency if needed.
4. The EXACT output path: "Save it as ./name.png in this directory."
5. "Do nothing else."

For edits: give the input file path and list invariants ("change only the background; keep the subject unchanged").

## After the run

- `Read` the output image and judge it before shipping; iterate with a follow-up edit run rather than regenerating from scratch when composition is right but details are off.
- Masters are also archived under `~/.codex/generated_images/`.
- Cost awareness: each run consumes roughly 30k Codex agent tokens from the ChatGPT plan quota on top of the image generation itself. Batch related images into one run when practical.

If `codex` is missing or auth expired, say so and suggest `! codex login` rather than falling back silently.
