#!/usr/bin/env bash
#
# install-smoke.sh — installer contract smoke test.
#
# Verifies ./install.sh against the written requirement, independent of the
# installer's implementation. Every assertion is derived from the contract:
# it computes the expected inventory by parsing skills/*/SKILL.md frontmatter
# and agents/*.md frontmatter itself, then checks the installer's observable
# behavior (files on disk, exit codes, stdout/stderr) against that inventory.
#
# Written for bash 3.2 (macOS's stock /bin/bash, which this script's
# `#!/usr/bin/env bash` shebang will resolve to on a machine with no newer
# bash on PATH). That means: no associative arrays, no `mapfile`/`readarray`,
# and every `"${arr[@]}"` expansion is guarded with a `${#arr[@]} -gt 0`
# check, because bash <4.4 treats expanding an empty array under `set -u` as
# an unbound-variable error.
#
# Usage:
#   ./test/install-smoke.sh                 normal mode
#   ./test/install-smoke.sh --expect-broken  inverts the final exit code, so
#                                             this can be pointed at a known
#                                             broken installer to prove the
#                                             test actually detects failure.
#
set -uo pipefail

MODE="normal"
if [[ "${1:-}" == "--expect-broken" ]]; then
  MODE="expect-broken"
fi

# ---------------------------------------------------------------------------
# Paths and prerequisites
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLER="$REPO_ROOT/install.sh"
SKILLS_DIR="$REPO_ROOT/skills"
AGENTS_DIR="$REPO_ROOT/agents"

PASS=0
FAIL=0
GROUP="init"

group() {
  GROUP="$1"
  echo
  echo "== $1 =="
}

pass() {
  PASS=$((PASS + 1))
  echo "PASS [$GROUP] $*"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "FAIL [$GROUP] $*"
}

die() {
  echo "ABORT: $*" >&2
  exit 2
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required tool '$1' not found on PATH"
}

need_cmd jq
need_cmd python3
need_cmd shasum

[[ -d "$SKILLS_DIR" ]] || die "canonical skills tree not found at $SKILLS_DIR"
[[ -d "$AGENTS_DIR" ]] || die "canonical agents tree not found at $AGENTS_DIR"

# ---------------------------------------------------------------------------
# Safety: never touch the real HOME. Every HOME/dest we hand the installer
# must live under our own mktemp root, checked before every use.
# ---------------------------------------------------------------------------

REAL_HOME="${HOME:-}"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/install-smoke.XXXXXX")" || die "mktemp failed"
cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

assert_safe_dir() {
  local d="$1"
  if [[ -z "$d" || "$d" == "/" || "$d" == "$REAL_HOME" ]]; then
    die "refusing to use unsafe directory '$d' as a test HOME/dest"
  fi
  case "$d" in
    "$TMP_ROOT"/*) : ;;
    *) die "refusing to use directory '$d' outside test tmp root '$TMP_ROOT'" ;;
  esac
}

new_home() {
  local d
  d="$(mktemp -d "$TMP_ROOT/home.XXXXXX")" || die "mktemp failed"
  assert_safe_dir "$d"
  printf '%s' "$d"
}

new_dest() {
  local d
  d="$(mktemp -d "$TMP_ROOT/dest.XXXXXX")" || die "mktemp failed"
  assert_safe_dir "$d"
  printf '%s' "$d"
}

# ---------------------------------------------------------------------------
# Build the expected inventory from the canonical tree (skills/, agents/).
# We deliberately do not read install.sh or install.d/: everything below is
# derived from frontmatter in the canonical content tree only.
# ---------------------------------------------------------------------------

INV_PY="$TMP_ROOT/inventory.py"
INV_JSON="$TMP_ROOT/inventory.json"

cat >"$INV_PY" <<'PYEOF'
import json, re, pathlib, sys

repo_root = pathlib.Path(sys.argv[1])
skills_dir = repo_root / "skills"
agents_dir = repo_root / "agents"


def parse_frontmatter(text):
    lines = text.splitlines()
    result = {"requires": [], "degrades": [], "has_model": False, "has_disable": False}
    if not lines or lines[0].strip() != "---":
        return result
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return result
    fm = lines[1:end]
    i, n = 0, len(fm)
    while i < n:
        line = fm[i]
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))
        if indent == 0 and re.match(r"^model\s*:", stripped):
            result["has_model"] = True
            i += 1
            continue
        if indent == 0 and re.match(r"^disable-model-invocation\s*:", stripped):
            result["has_disable"] = True
            i += 1
            continue
        if indent == 0 and stripped == "harness:":
            i += 1
            while i < n:
                hline = fm[i]
                hstripped = hline.strip()
                hindent = len(hline) - len(hline.lstrip(" "))
                if hstripped == "":
                    i += 1
                    continue
                if hindent == 0:
                    break
                m = re.match(r"requires\s*:\s*\[(.*?)\]", hstripped)
                if m:
                    result["requires"] = [x.strip() for x in m.group(1).split(",") if x.strip()]
                    i += 1
                    continue
                m = re.match(r"degrades\s*:\s*\[(.*?)\]", hstripped)
                if m:
                    result["degrades"] = [x.strip() for x in m.group(1).split(",") if x.strip()]
                    i += 1
                    continue
                i += 1
            continue
        if indent == 0 and re.match(r"^description\s*:", stripped):
            # Skip a block-scalar (or any indented continuation) description
            # so its content is never mistaken for a top-level key.
            i += 1
            while i < n:
                nxt = fm[i]
                if nxt.strip() == "":
                    i += 1
                    continue
                nindent = len(nxt) - len(nxt.lstrip(" "))
                if nindent == 0:
                    break
                i += 1
            continue
        i += 1
    return result


skills = {}
for d in sorted(skills_dir.iterdir()):
    if not d.is_dir():
        continue
    skill_md = d / "SKILL.md"
    if not skill_md.exists():
        continue
    text = skill_md.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    files = sorted(
        str(p.relative_to(d)).replace("\\", "/") for p in d.rglob("*") if p.is_file()
    )
    skills[d.name] = {
        "requires": fm["requires"],
        "degrades": fm["degrades"],
        "has_model": fm["has_model"],
        "has_disable": fm["has_disable"],
        "files": files,
    }

skill_dirs_without_skill_md = sorted(
    d.name for d in skills_dir.iterdir() if d.is_dir() and not (d / "SKILL.md").exists()
)

agents = {}
for f in sorted(agents_dir.glob("*.md")):
    text = f.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    agents[f.stem] = {"has_model": fm["has_model"], "has_disable": fm["has_disable"]}

json.dump(
    {
        "skills": skills,
        "agents": agents,
        "skill_dirs_without_skill_md": skill_dirs_without_skill_md,
    },
    sys.stdout,
    indent=2,
)
PYEOF

python3 "$INV_PY" "$REPO_ROOT" >"$INV_JSON" || die "failed to build inventory from canonical tree"

VALID_CAPS="subagents claude-transcripts mcp-browser hooks slash-commands"

cap_is_valid() {
  local c="$1" v
  for v in $VALID_CAPS; do
    [[ "$v" == "$c" ]] && return 0
  done
  return 1
}

# lines_from_cmd ARRAYNAME CMD... — bash-3.2-safe replacement for `mapfile`.
# Reads newline-separated, non-empty lines from a command's stdout into the
# named array (via eval, since bash 3.2 has no `local -n`/nameref).
lines_from_cmd() {
  local __outvar="$1"
  shift
  local __line __result=()
  while IFS= read -r __line; do
    [[ -n "$__line" ]] && __result+=("$__line")
  done < <("$@")
  # Guard the empty case explicitly: expanding "${__result[@]}" when
  # __result has zero elements is an unbound-variable error under bash <4.4
  # with `set -u`, even though __result was initialized as an array.
  if [[ ${#__result[@]} -eq 0 ]]; then
    eval "$__outvar=()"
  else
    eval "$__outvar=(\"\${__result[@]}\")"
  fi
}

# ---------------------------------------------------------------------------
# Canonical tree sanity (guards the test's own inputs, not the installer)
# ---------------------------------------------------------------------------

group "canonical-tree"

no_skill_md=()
lines_from_cmd no_skill_md jq -r '.skill_dirs_without_skill_md[]?' "$INV_JSON"
if [[ ${#no_skill_md[@]} -eq 0 ]]; then
  pass "every skills/<name>/ directory has a SKILL.md"
else
  fail "every skills/<name>/ directory has a SKILL.md (missing in: ${no_skill_md[*]})"
fi

bad_caps=()
lines_from_cmd bad_caps jq -r '.skills[] | (.requires[]?, .degrades[]?)' "$INV_JSON"
bad_list=()
if [[ ${#bad_caps[@]} -gt 0 ]]; then
  for c in "${bad_caps[@]}"; do
    cap_is_valid "$c" || bad_list+=("$c")
  done
fi
if [[ ${#bad_list[@]} -eq 0 ]]; then
  pass "all harness.requires/degrades capability names are in the valid set ($VALID_CAPS)"
else
  fail "all harness.requires/degrades capability names are valid (expected subset of [$VALID_CAPS], got unknown: ${bad_list[*]})"
fi

ALL_SKILLS=()
lines_from_cmd ALL_SKILLS jq -r '.skills | keys[]' "$INV_JSON"
ALL_AGENTS=()
lines_from_cmd ALL_AGENTS jq -r '.agents | keys[]' "$INV_JSON"

if [[ ${#ALL_SKILLS[@]} -gt 0 ]]; then
  pass "discovered ${#ALL_SKILLS[@]} canonical skill(s): ${ALL_SKILLS[*]}"
else
  fail "discovered at least one canonical skill (expected >0, got 0)"
fi

if [[ ${#ALL_AGENTS[@]} -gt 0 ]]; then
  pass "discovered ${#ALL_AGENTS[@]} canonical agent(s): ${ALL_AGENTS[*]}"
else
  fail "discovered at least one canonical agent (expected >0, got 0)"
fi

# ---------------------------------------------------------------------------
# Target definitions (from the requirement, not from install.sh)
# ---------------------------------------------------------------------------

TARGETS=(claude codex pi agents)

target_caps() {
  case "$1" in
    claude) printf '%s' "subagents claude-transcripts mcp-browser hooks slash-commands" ;;
    codex) printf '%s' "subagents slash-commands" ;;
    pi) printf '%s' "" ;;
    agents) printf '%s' "" ;;
  esac
}

caps_has() {
  local caps="$1" want="$2" c
  for c in $caps; do
    [[ "$c" == "$want" ]] && return 0
  done
  return 1
}

# missing_caps_for TARGET SKILL_NAME -> space-separated list of capabilities
# the skill requires that the target does not have (empty if it installs).
missing_caps_for() {
  local target="$1" name="$2" caps requires=() r out=()
  caps="$(target_caps "$target")"
  lines_from_cmd requires jq -r --arg n "$name" '.skills[$n].requires[]?' "$INV_JSON"
  if [[ ${#requires[@]} -gt 0 ]]; then
    for r in "${requires[@]}"; do
      caps_has "$caps" "$r" || out+=("$r")
    done
  fi
  printf '%s' "${out[*]:-}"
}

# skill_dir_path TARGET HOME DEST NAME -> path to the installed skill directory
skill_dir_path() {
  local target="$1" home="$2" dest="$3" name="$4"
  case "$target" in
    claude) printf '%s/.claude/skills/%s' "$home" "$name" ;;
    codex) printf '%s/.codex/skills/%s' "$home" "$name" ;;
    pi) printf '%s/.pi/agent/skills/%s' "$home" "$name" ;;
    agents) printf '%s/skills/%s' "$dest" "$name" ;;
  esac
}

# agent_artifact_path TARGET HOME DEST NAME -> path to the installed agent
# artifact. claude/codex keep agents as agents; pi/agents demote agents to
# skills, installed into the same skills directory as regular skills, using
# the same layout as a regular skill: <skills-dir>/<agent-name>/SKILL.md.
# (Confirmed against design intent, not by reading the installer.)
agent_artifact_path() {
  local target="$1" home="$2" dest="$3" name="$4"
  case "$target" in
    claude) printf '%s/.claude/agents/%s.md' "$home" "$name" ;;
    codex) printf '%s/.codex/agents/%s.toml' "$home" "$name" ;;
    pi) printf '%s/.pi/agent/skills/%s/SKILL.md' "$home" "$name" ;;
    agents) printf '%s/skills/%s/SKILL.md' "$dest" "$name" ;;
  esac
}

snapshot_tree() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    printf 'NO_SUCH_DIR'
    return
  fi
  {
    find "$dir" -mindepth 1 \( -type d -o -type f \) 2>/dev/null | sort
    find "$dir" -type f -print0 2>/dev/null | sort -z | xargs -0 shasum -a 256 2>/dev/null
  } | shasum -a 256 | awk '{print $1}'
}

run_installer() {
  # run_installer TARGET HOME DEST [EXTRA_ARGS...] -> sets RC and OUT globals
  local target="$1" home="$2" dest="$3"
  shift 3
  local cmd=(bash "$INSTALLER" "--target=$target")
  if [[ "$target" == "agents" ]]; then
    cmd+=("--dest=$dest")
  fi
  if [[ $# -gt 0 ]]; then
    cmd+=("$@")
  fi
  # The "agents" target writes only under --dest and does not use $HOME, but
  # we still isolate HOME defensively for every target/run so a future
  # change to any target can never reach the real HOME unnoticed.
  OUT="$(cd "$REPO_ROOT" && HOME="$home" "${cmd[@]}" 2>&1)"
  RC=$?
}

# ---------------------------------------------------------------------------
# Per-target checks
# ---------------------------------------------------------------------------

for target in "${TARGETS[@]}"; do
  group "target=$target"

  installed_skills=()
  skipped_skills=()
  skipped_missing=()  # parallel to skipped_skills: missing-caps string per index

  if [[ ${#ALL_SKILLS[@]} -gt 0 ]]; then
    for name in "${ALL_SKILLS[@]}"; do
      missing="$(missing_caps_for "$target" "$name")"
      if [[ -z "$missing" ]]; then
        installed_skills+=("$name")
      else
        skipped_skills+=("$name")
        skipped_missing+=("$missing")
      fi
    done
  fi

  expected_count=${#installed_skills[@]}

  # --- Sub-test A: normal install -----------------------------------------

  home1="$(new_home)"
  dest1=""
  [[ "$target" == "agents" ]] && dest1="$(new_dest)"

  run_installer "$target" "$home1" "$dest1"
  install_out="$OUT"
  install_rc="$RC"

  if [[ "$expected_count" -eq 0 ]]; then
    if [[ "$install_rc" -ne 0 ]]; then
      pass "install exits non-zero when zero skills are installable (expected non-zero, got $install_rc)"
    else
      fail "install exits non-zero when zero skills are installable (expected non-zero exit, got 0 -- installer silently installed nothing and exited success)"
    fi
  else
    if [[ "$install_rc" -eq 0 ]]; then
      pass "install exits 0 with $expected_count installable skill(s) (expected 0, got 0)"
    else
      fail "install exits 0 with $expected_count installable skill(s) (expected 0, got $install_rc; output: $(printf '%s' "$install_out" | tail -5 | tr '\n' '|'))"
    fi
  fi

  # Installed skills: SKILL.md present, siblings byte-identical, no leaked keys.
  if [[ ${#installed_skills[@]} -gt 0 ]]; then
    for name in "${installed_skills[@]}"; do
      dir="$(skill_dir_path "$target" "$home1" "$dest1" "$name")"
      skill_md="$dir/SKILL.md"

      if [[ -s "$skill_md" ]]; then
        pass "skill '$name' installed with non-empty SKILL.md at $skill_md"
      else
        fail "skill '$name' installed with non-empty SKILL.md (expected file at $skill_md, got $( [[ -e "$skill_md" ]] && echo 'empty file' || echo 'missing' ))"
      fi

      sib_files=()
      lines_from_cmd sib_files bash -c 'jq -r --arg n "$1" ".skills[\$n].files[]?" "$2" | grep -v "^SKILL\\.md\$"' _ "$name" "$INV_JSON"

      bad_sibs=()
      if [[ ${#sib_files[@]} -gt 0 ]]; then
        for rel in "${sib_files[@]}"; do
          src="$SKILLS_DIR/$name/$rel"
          dst="$dir/$rel"
          if [[ ! -f "$dst" ]]; then
            bad_sibs+=("$rel:missing")
          elif ! cmp -s "$src" "$dst"; then
            bad_sibs+=("$rel:content-differs")
          fi
        done
      fi
      if [[ ${#sib_files[@]} -eq 0 ]]; then
        pass "skill '$name' has no sibling files to verify"
      elif [[ ${#bad_sibs[@]} -eq 0 ]]; then
        pass "skill '$name' sibling files/subdirs installed byte-identical (${#sib_files[@]} file(s))"
      else
        fail "skill '$name' sibling files/subdirs installed byte-identical (expected ${#sib_files[@]} ok, got ${#bad_sibs[@]} problem(s): ${bad_sibs[*]})"
      fi

      if [[ -f "$skill_md" ]] && grep -qE '^harness:' "$skill_md" 2>/dev/null; then
        fail "skill '$name' installed SKILL.md has no 'harness:' key (expected absent, got present in $skill_md)"
      else
        pass "skill '$name' installed SKILL.md has no 'harness:' key"
      fi

      if [[ "$target" == "pi" || "$target" == "agents" ]]; then
        if [[ -f "$skill_md" ]] && grep -qE '^model:' "$skill_md" 2>/dev/null; then
          fail "skill '$name' installed to $target has no 'model:' key (expected absent, got present)"
        else
          pass "skill '$name' installed to $target has no 'model:' key"
        fi
        if [[ -f "$skill_md" ]] && grep -qE '^disable-model-invocation:' "$skill_md" 2>/dev/null; then
          fail "skill '$name' installed to $target has no 'disable-model-invocation:' key (expected absent, got present)"
        else
          pass "skill '$name' installed to $target has no 'disable-model-invocation:' key"
        fi
      fi
    done
  fi

  # Skipped skills: absent from target, and the missing capability was named.
  if [[ ${#skipped_skills[@]} -gt 0 ]]; then
    idx=0
    for name in "${skipped_skills[@]}"; do
      missing="${skipped_missing[$idx]}"
      idx=$((idx + 1))

      dir="$(skill_dir_path "$target" "$home1" "$dest1" "$name")"
      if [[ ! -e "$dir/SKILL.md" ]]; then
        pass "skipped skill '$name' not installed at $target (missing capability: $missing)"
      else
        fail "skipped skill '$name' not installed at $target (expected no SKILL.md at $dir, got one present; missing capability was $missing)"
      fi

      named_line_found=0
      for cap in $missing; do
        if printf '%s\n' "$install_out" | grep -F -- "$name" | grep -qF -- "$cap"; then
          named_line_found=1
        fi
      done
      if [[ "$named_line_found" -eq 1 ]]; then
        pass "installer output names skill '$name' and its missing capability ($missing)"
      else
        fail "installer output names skill '$name' and its missing capability (expected a line mentioning '$name' and one of [$missing], got: $(printf '%s' "$install_out" | tail -8 | tr '\n' '|'))"
      fi
    done
  fi

  # Agents: always installed (no capability gating defined for agents/).
  if [[ ${#ALL_AGENTS[@]} -gt 0 ]]; then
    for name in "${ALL_AGENTS[@]}"; do
      artifact="$(agent_artifact_path "$target" "$home1" "$dest1" "$name")"

      if [[ -s "$artifact" ]]; then
        pass "agent '$name' installed to $target at $artifact"
      else
        fail "agent '$name' installed to $target (expected non-empty file at $artifact, got $( [[ -e "$artifact" ]] && echo 'empty file' || echo 'missing' ))"
      fi

      if [[ "$target" == "codex" ]]; then
        toml_check="$(python3 - "$artifact" <<'PYEOF'
import sys, tomllib
path = sys.argv[1]
try:
    with open(path, "rb") as fh:
        data = tomllib.load(fh)
except FileNotFoundError:
    print("MISSING")
    sys.exit(1)
except Exception as e:
    print(f"INVALID:{e}")
    sys.exit(1)
missing = [k for k in ("name", "description", "developer_instructions") if k not in data]
if missing:
    print("MISSING_KEYS:" + ",".join(missing))
    sys.exit(1)
print("OK")
sys.exit(0)
PYEOF
)"
        if [[ "$toml_check" == "OK" ]]; then
          pass "codex agent '$name' TOML is valid and has name/description/developer_instructions"
        else
          fail "codex agent '$name' TOML is valid and has name/description/developer_instructions (expected OK, got $toml_check)"
        fi
      fi

      if [[ -f "$artifact" ]] && grep -qE '^harness:' "$artifact" 2>/dev/null; then
        fail "agent '$name' installed to $target has no 'harness:' key (expected absent, got present)"
      else
        pass "agent '$name' installed to $target has no 'harness:' key"
      fi

      if [[ "$target" == "pi" || "$target" == "agents" ]]; then
        bad_keys=()
        if [[ -f "$artifact" ]] && grep -qE '^model:' "$artifact" 2>/dev/null; then
          bad_keys+=("model:")
        fi
        if [[ -f "$artifact" ]] && grep -qE '^disable-model-invocation:' "$artifact" 2>/dev/null; then
          bad_keys+=("disable-model-invocation:")
        fi
        if [[ ${#bad_keys[@]} -eq 0 ]]; then
          pass "agent '$name' demoted to $target has no Claude-only frontmatter keys"
        else
          fail "agent '$name' demoted to $target has no Claude-only frontmatter keys (expected none, got: ${bad_keys[*]})"
        fi
      fi
    done
  fi

  # --- Sub-test B: --dry-run writes nothing at all ------------------------

  home2="$(new_home)"
  dest2=""
  [[ "$target" == "agents" ]] && dest2="$(new_dest)"

  before_home="$(snapshot_tree "$home2")"
  before_dest=""
  [[ "$target" == "agents" ]] && before_dest="$(snapshot_tree "$dest2")"

  run_installer "$target" "$home2" "$dest2" --dry-run

  after_home="$(snapshot_tree "$home2")"
  after_dest=""
  [[ "$target" == "agents" ]] && after_dest="$(snapshot_tree "$dest2")"

  if [[ "$before_home" == "$after_home" ]]; then
    pass "--dry-run writes nothing under HOME (tree hash unchanged)"
  else
    fail "--dry-run writes nothing under HOME (expected hash $before_home, got $after_home)"
  fi

  if [[ "$target" == "agents" ]]; then
    if [[ "$before_dest" == "$after_dest" ]]; then
      pass "--dry-run writes nothing under --dest (tree hash unchanged)"
    else
      fail "--dry-run writes nothing under --dest (expected hash $before_dest, got $after_dest)"
    fi
  fi

  # --- Sub-test C: re-run without --force is a no-op success --------------

  if [[ "$expected_count" -eq 0 ]]; then
    echo "SKIP [$GROUP] idempotency re-run not applicable: $target installs 0 skills (rule 7 already governs exit code)"
  else
    before_rerun_home="$(snapshot_tree "$home1")"
    before_rerun_dest=""
    [[ "$target" == "agents" ]] && before_rerun_dest="$(snapshot_tree "$dest1")"

    run_installer "$target" "$home1" "$dest1"
    rerun_rc="$RC"

    after_rerun_home="$(snapshot_tree "$home1")"
    after_rerun_dest=""
    [[ "$target" == "agents" ]] && after_rerun_dest="$(snapshot_tree "$dest1")"

    if [[ "$rerun_rc" -eq 0 ]]; then
      pass "re-run without --force exits 0 (expected 0, got 0)"
    else
      fail "re-run without --force exits 0 (expected 0, got $rerun_rc)"
    fi

    if [[ "$before_rerun_home" == "$after_rerun_home" ]] && [[ "$before_rerun_dest" == "$after_rerun_dest" ]]; then
      pass "re-run without --force does not overwrite existing installed files (tree hash unchanged)"
    else
      fail "re-run without --force does not overwrite existing installed files (HOME hash: expected $before_rerun_home got $after_rerun_home; dest hash: expected $before_rerun_dest got $after_rerun_dest)"
    fi
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo
echo "== summary =="
echo "$PASS passed, $FAIL failed"

if [[ "$FAIL" -gt 0 ]]; then
  RESULT=1
else
  RESULT=0
fi

if [[ "$MODE" == "expect-broken" ]]; then
  if [[ "$RESULT" -eq 0 ]]; then
    echo "--expect-broken: all assertions passed against a target expected to be broken -- test did NOT detect the breakage"
    exit 1
  else
    echo "--expect-broken: failures were detected as expected"
    exit 0
  fi
fi

exit "$RESULT"
