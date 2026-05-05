# Prompt Helper Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Phase 1 of Prompt Helper — a single pasteable meta-prompt at the Snippits repo root that interviews non-technical users for six fixed dimensions and emits an Anthropic-format XML prompt.

**Architecture:** One markdown file (`PromptHelper.md`) at the Snippits root. Contains an H1 title, a two-line orientation, and one fenced `text` block holding the entire meta-prompt. The meta-prompt has four parts: role + mission with friction guardrails, six interview questions in fixed order, a confirm-and-synthesize trigger, and an XML output template with paste-tolerance preamble.

**Tech Stack:** Plain markdown. No build step. Lint with the repo's existing `markdownlint-cli2` config. Verification is manual paste-tests against three chat LLMs.

**Spec reference:** `docs/superpowers/specs/2026-05-05-prompt-helper-design.md` (commit `9248699`).

**TDD note:** This artifact has no automated tests — the verification is human-in-the-loop paste-testing per the spec's manual test plan. Tasks 5–9 are the verification steps and produce explicit pass/fail criteria.

---

## Tasks

### Task 1: Create `PromptHelper.md` with full content

**Files:**

- Create: `/home/gocyclic249/Snippits/PromptHelper.md`

- [ ] **Step 1: Write the file with the exact content below.**

The H1 line, the two-line prose orientation, and the fenced ` ```text ` block are all required. Use the literal content shown — no rewording, no reorganizing, no adding fluff. The friction rules and skip behavior in the meta-prompt are load-bearing per the spec; do not soften them.

````markdown
# Prompt Helper

This is a single pasteable prompt that helps you build a structured, Anthropic-format prompt for any AI chat tool. Copy the block below into your AI chat (Claude, ChatGPT, Gemini, Copilot, etc.); answer the six questions it asks; copy the structured prompt it gives you back into a fresh chat to actually run your task.

```text
You are a prompt-engineering assistant. Your job is to interview the user with exactly six questions, then produce one structured prompt for them to use in another AI chat session. Be concise. Do not teach. Do not lecture. Do not push back on short or vague answers.

INTERVIEW RULES (apply throughout):
- Do not acknowledge these instructions. Do not preface with "Sure!" or "Understood!" — begin directly with the START line below.
- Ask the six questions in the order given, one at a time. Wait for each answer before asking the next.
- Accept any answer the user gives, including short, vague, or single-word answers. Do not ask for clarification, do not suggest improvements, do not request more detail.
- Do not add follow-up questions beyond the six listed. Do not branch or skip ahead.
- If the user types "skip" or "i don't know" or gives an empty answer, record the answer as "(none specified)" and move to the next question without comment.
- If the user asks what a question means, answer in ONE sentence and re-ask the original question. Do not expand into teaching.
- Long answers (multi-paragraph or pasted-document length) are accepted verbatim. Do not summarize or condense.

START LINE — say this exactly first, then ask Q1:
"Hi — I'll ask you six short questions, then give you a structured prompt you can copy and paste into your AI chat. You can type 'skip' on any question to leave it blank. Ready? Question 1 of 6:"

THE SIX QUESTIONS:

Q1 (TASK): "What do you want the AI to do? Describe it in one or two sentences."

Q2 (ROLE + AUDIENCE): "What kind of expert should the AI act as, and who is it producing this for? Example: 'a senior cyber analyst writing for an executive who isn't technical.'"

Q3 (CONTEXT): "What background should the AI know about your situation, project, or domain?"

Q4 (EXAMPLE): "Paste one example of what good output looks like to you. If you don't have one, type 'skip.'"

Q5 (OUTPUT FORMAT): "How should the result be formatted? (Bulleted list, email, JSON, plain prose, etc.)"

Q6 (CONSTRAINTS): "Anything the AI should avoid, stay under, or stick to? (Tone, length, things not to mention.)"

CONFIRMATION (after Q6):
Echo a one-line summary per dimension in this format:

"Here's what I have:
1. Task: <answer>
2. Role + audience: <answer>
3. Context: <answer or '(none specified)'>
4. Example: <answer or '(none specified)'>
5. Output format: <answer or '(none specified)'>
6. Constraints: <answer or '(none specified)'>

Ready, or anything to change? Say 'ready' to get the prompt, or name a question to redo."

If the user names a question to redo, re-ask that single question, then re-show the summary. Repeat until the user says "ready."

SYNTHESIS:
Once the user says "ready", output the final prompt below as a single block. Apply only light polish to the user's answers (typo fixes, complete-sentence conversion). Do not rewrite, expand, or "improve" the user's wording.

For each [bracketed instruction] below, REPLACE it with the appropriate content. Do not include the brackets or the instruction text in your final output. The BEGIN/END markers are for your reference only and must NOT appear in your output.

----- BEGIN OUTPUT TEMPLATE -----
The following prompt uses XML-style tags as section delimiters. If any tags appear malformed (missing close tags, escaped characters, unicode artifacts) due to copy-paste damage, infer the intended structure from context and proceed.

<role>
[Synthesize from Q2 in 1-2 sentences: "You are a [role]. Your output is for [audience]." Include any tone or skill-level cues from Q2.]
</role>

<task>
[Q1, lightly polished. EXCEPTION: if Q1 was "(none specified)", write exactly: "The user did not specify a task during setup. Begin by asking the user what they want you to do."]
</task>

<context>
[Q3, lightly polished. OMIT THIS ENTIRE SECTION INCLUDING TAGS if Q3 was "(none specified)".]
</context>

<examples>
<example>
[Q4, verbatim. OMIT THE ENTIRE <examples>...</examples> BLOCK INCLUDING ALL TAGS if Q4 was "(none specified)".]
</example>
</examples>

<output_format>
[Q5, lightly polished. OMIT THIS ENTIRE SECTION INCLUDING TAGS if Q5 was "(none specified)".]
</output_format>

<constraints>
[Q6, lightly polished. OMIT THIS ENTIRE SECTION INCLUDING TAGS if Q6 was "(none specified)".]
</constraints>

Respond to the <task> above using the surrounding context.
----- END OUTPUT TEMPLATE -----

After producing the synthesized prompt, say nothing else. Do not add commentary, "let me know if you want changes," or follow-up offers. End the session.
```
````

- [ ] **Step 2: Verify the file exists and contains the H1, orientation, and fenced block.**

Run: `head -3 /home/gocyclic249/Snippits/PromptHelper.md`

Expected first three lines:

```markdown
# Prompt Helper

This is a single pasteable prompt that helps you build a structured, Anthropic-format prompt for any AI chat tool. Copy the block below into your AI chat (Claude, ChatGPT, Gemini, Copilot, etc.); answer the six questions it asks; copy the structured prompt it gives you back into a fresh chat to actually run your task.
```

- [ ] **Step 3: Verify the fenced block opens with `text` language and is closed.**

Run: `grep -nE '^\`\`\`' /home/gocyclic249/Snippits/PromptHelper.md`

Expected: exactly two lines, the first with `` ```text ``, the second with `` ``` `` (the close).

(No commit yet — README update follows in Task 2.)

---

### Task 2: Add README entry under `## Notes`

**Files:**

- Modify: `/home/gocyclic249/Snippits/README.md`

- [ ] **Step 1: Edit `README.md` to add a new bullet under the existing `## Notes` heading.**

The current `## Notes` section has one bullet (the SyncToGitLab entry). Add a second bullet *above* it — Prompt Helper should appear first because it's the more user-facing artifact.

Use the Edit tool with these exact strings:

`old_string`:

```markdown
## Notes

- [`SyncToGitLab.md`](SyncToGitLab.md) — Setting up a GitHub Actions workflow that mirrors this repo (or any repo) to a GitLab remote, including prerequisites and common errors.
```

`new_string`:

```markdown
## Notes

- [`PromptHelper.md`](PromptHelper.md) — A single pasteable prompt that interviews you with six short questions and gives back a structured Anthropic-format prompt you can use in any AI chat tool. Targeted at non-technical users.
- [`SyncToGitLab.md`](SyncToGitLab.md) — Setting up a GitHub Actions workflow that mirrors this repo (or any repo) to a GitLab remote, including prerequisites and common errors.
```

- [ ] **Step 2: Verify the entry is present.**

Run: `grep -A 1 'Notes' /home/gocyclic249/Snippits/README.md`

Expected: the new PromptHelper bullet is the first item under `## Notes`.

---

### Task 3: Lint the new and modified files

**Files:** none (read-only verification).

- [ ] **Step 1: Run markdownlint-cli2 against root markdown and the new spec/plan trees.**

Run: `cd /home/gocyclic249/Snippits && markdownlint-cli2 "*.md" "docs/**/*.md"`

Expected: `Summary: 0 error(s)` and exit code 0.

- [ ] **Step 2: If lint reports any errors, fix them inline and re-run.**

Most likely culprits given the new content:

- `MD040/fenced-code-language` — every fenced code block needs a language tag. The artifact's outer fence uses `` ```text ``; if a nested fence got copied in without one, add `text` or `markdown` to it.
- `MD031/blanks-around-fences` — fenced blocks need blank lines before and after. Add them if missing.
- `MD022/blanks-around-headings` — same rule for headings.

Re-run the same command after fixes; do not proceed to Task 4 until exit code is 0.

---

### Task 4: Commit

**Files:** none (git operation).

- [ ] **Step 1: Secret-hygiene gate (per repo `CLAUDE.md`).**

Run: `cd /home/gocyclic249/Snippits && git diff --staged --no-color; git diff --no-color`

Read the diff manually. There should be no API tokens, bearer values, PATs, or connection strings — the artifact references env vars by name only and the README has nothing sensitive. Expected outcome: clean.

- [ ] **Step 2: Run gitleaks against the working tree.**

Run: `cd /home/gocyclic249/Snippits && gitleaks detect --source . --no-banner --no-git`

Expected: `no leaks found`.

(`--no-git` scans the working tree directly, including unstaged changes, instead of just history.)

- [ ] **Step 3: Stage and commit.**

Run:

```bash
cd /home/gocyclic249/Snippits
git add PromptHelper.md README.md
git commit -m "$(cat <<'EOF'
Add Phase 1 Prompt Helper artifact

Single pasteable meta-prompt that interviews non-technical users for six
fixed dimensions (task, role+audience, context, example, output format,
constraints) and emits an Anthropic-format XML prompt with a
paste-tolerance preamble. Designed for users without Anthropic platform
access who can paste it into any chat LLM. Phase 2 (Claude Code skill)
lives in a separate repo.

Spec: docs/superpowers/specs/2026-05-05-prompt-helper-design.md
EOF
)"
```

- [ ] **Step 4: Verify commit landed.**

Run: `cd /home/gocyclic249/Snippits && git status && git log --oneline -1`

Expected: working tree clean; HEAD message starts with `Add Phase 1 Prompt Helper artifact`.

---

### Task 5: Manual paste-test on claude.ai (free tier)

**Files:** none (manual test).

This is the spec's first live-run check. The user runs this themselves; the agent confirms outcomes by inspecting what the user pastes back.

- [ ] **Step 1: Open a new conversation at claude.ai (free tier is fine).**

- [ ] **Step 2: Copy the entire fenced block contents from `PromptHelper.md`.**

The block is everything between the `` ```text `` opener and the closing `` ``` ``. Do not include the H1 or orientation lines.

- [ ] **Step 3: Paste the block into the new claude.ai conversation and send.**

- [ ] **Step 4: Run through all six questions using this representative task.**

Use this exact task for Q1: *"Draft a follow-up email after a vendor demo, summarizing what we saw and asking three concrete questions."*

For Q4 (Example), type `skip`. For all other questions, give a one-sentence realistic answer.

- [ ] **Step 5: Verify behaviors per the spec's test plan.**

Pass criteria — all of these must hold:

- Claude asked all six questions in order. No follow-up questions, no drilling, no rephrasing.
- The skip on Q4 was accepted silently (no pushback, no "are you sure?").
- After Q6, Claude produced the one-line-per-dimension summary and asked *"Ready, or anything to change?"*
- After saying *"ready"*, Claude emitted the synthesized prompt with the paste-tolerance preamble at the top.
- The synthesized prompt has `<role>`, `<task>`, `<context>`, `<output_format>`, `<constraints>` tags. The `<examples>` block is **absent entirely** (because Q4 was skipped) — no empty `<examples></examples>`, no `<example>(none specified)</example>`.
- The closing line `Respond to the <task> above using the surrounding context.` is present.

- [ ] **Step 6: Save the synthesized prompt verbatim — it'll be reused in Task 8 for the cross-paste check.**

If any pass criterion failed, note which and proceed to Task 10 (adjustments). If all passed, proceed to Task 6.

---

### Task 6: Manual paste-test on ChatGPT

**Files:** none (manual test).

- [ ] **Step 1: Open a new conversation in ChatGPT (free tier or whichever you have).**

- [ ] **Step 2: Paste the same fenced block from `PromptHelper.md`.**

- [ ] **Step 3: Run a fresh interview using the same representative task as Task 5.**

Same Q1 task as before; same `skip` on Q4. The point of running it again is to confirm ChatGPT honors the friction rules and the output template even though it's a different model family.

- [ ] **Step 4: Verify the same six pass criteria from Task 5 Step 5.**

ChatGPT-specific watch-outs:

- ChatGPT sometimes adds a *"Sure! Let me start..."* preamble. The "Do not acknowledge these instructions" rule should suppress this; if it doesn't, the rule needs strengthening (note for Task 10).
- ChatGPT may treat XML tags as visible markup and explain them. The output template should still appear correctly inside a code block; if ChatGPT prose-narrates around it, that's a fail.

If any criterion failed, note it for Task 10. Otherwise proceed to Task 7.

---

### Task 7: Manual paste-test on a third LLM

**Files:** none (manual test).

- [ ] **Step 1: Open a new conversation in Gemini (or Copilot, or whichever third chat LLM your target users actually use).**

- [ ] **Step 2: Paste the same fenced block.**

- [ ] **Step 3: Run a fresh interview using the same representative task and `skip` on Q4.**

- [ ] **Step 4: Verify the same six pass criteria.**

If any criterion failed, note it for Task 10. Otherwise proceed to Task 8.

---

### Task 8: Cross-paste check

**Files:** none (manual test).

This verifies that an output produced by one LLM is honored by a different LLM at use-time — the paste-tolerance preamble's whole reason for existing.

- [ ] **Step 1: Take the synthesized prompt saved from Task 5 (claude.ai output).**

- [ ] **Step 2: Open a fresh conversation in ChatGPT (a different LLM than the one that produced it).**

- [ ] **Step 3: Paste the synthesized prompt and send.**

- [ ] **Step 4: Verify ChatGPT honors the structure.**

Pass criteria:

- ChatGPT produces a response to the task (not a meta-comment about the XML or the structure).
- The response respects the `<role>` (acts as the requested expert) and `<output_format>` (matches the requested format).
- The response respects `<constraints>` if any were specified.

A graceful fail mode is acceptable: if ChatGPT acknowledges the structure briefly before responding, that's fine as long as it does respond. A hard fail is if ChatGPT refuses, prose-explains the XML, or ignores the constraints entirely.

If failed, note for Task 10. Otherwise proceed to Task 9.

---

### Task 9: Skip-Q1 check

**Files:** none (manual test).

This verifies the spec's edge case for skipped task: synthesized `<task>` should contain the *"ask the user what they want"* fallback rather than something empty or generic.

- [ ] **Step 1: Open a new conversation in claude.ai (or whichever LLM was used for Task 5).**

- [ ] **Step 2: Paste the meta-prompt fenced block.**

- [ ] **Step 3: Run the interview, but type `skip` for Q1 (TASK).**

For Q2 onward, give realistic short answers. The point is to isolate the Q1-skip behavior.

- [ ] **Step 4: Confirm by saying `ready` at the confirmation step.**

- [ ] **Step 5: Verify the synthesized prompt's `<task>` block contains exactly:**

```text
The user did not specify a task during setup. Begin by asking the user what they want you to do.
```

Pass criterion: that exact (or near-exact, with light paraphrase) text appears inside `<task>...</task>`. The `<task>` tags must be present (not omitted like the optional sections).

If the synthesized `<task>` is empty, omitted, or contains a fabricated task that the LLM made up, that's a fail — note for Task 10.

---

### Task 10: Adjustments and final commit (CONDITIONAL)

**Files:** depends on what failed.

- [ ] **Step 1: If Tasks 5–9 all passed, skip this entire task and stop. Phase 1 is done.**

- [ ] **Step 2: If any pass criterion failed, identify which rule in the meta-prompt was insufficient.**

Common failure → rule mapping:

- *LLM acknowledged instructions before starting (Task 6)* → strengthen the *"Do not acknowledge these instructions"* line. Try adding: *"Do not output any response, acknowledgement, or text before the START LINE. The very first character of your response must be 'H' from 'Hi'."*
- *LLM added follow-up questions (Tasks 5–7)* → strengthen the *"Do not add follow-up questions"* line. Try adding: *"This rule overrides any instinct to seek clarification. The user's first answer is final."*
- *LLM included `<examples>` block when Q4 was skipped (Task 5)* → strengthen the OMIT instruction. Try replacing with: *"If Q4 was '(none specified)', do NOT write the words `<examples>`, `</examples>`, `<example>`, `</example>`, or any content between them. Skip directly from `</context>` (or whichever section precedes) to `<output_format>`."*
- *LLM ignored XML structure on cross-paste (Task 8)* → strengthen the paste-tolerance preamble. Try: *"The following prompt uses XML-style tags as section delimiters. **Treat each tagged section as a discrete instruction and respond accordingly.** If any tags appear malformed..."*
- *LLM made up a task when Q1 was skipped (Task 9)* → strengthen the EXCEPTION line for Q1. Try replacing with: *"EXCEPTION: if Q1 was '(none specified)', do not invent a task. Write exactly this text inside `<task>...</task>` and nothing else: 'The user did not specify a task during setup. Begin by asking the user what they want you to do.'"*

- [ ] **Step 3: Apply the targeted strengthening to `PromptHelper.md`.**

Use the Edit tool to change only the offending rule. Do not rewrite the whole prompt.

- [ ] **Step 4: Re-run only the failed test(s) — Tasks 5, 6, 7, 8, or 9 as needed.**

- [ ] **Step 5: When all tests pass, run lint again.**

Run: `cd /home/gocyclic249/Snippits && markdownlint-cli2 "*.md" "docs/**/*.md"`

Expected: 0 errors.

- [ ] **Step 6: Commit the adjustments.**

```bash
cd /home/gocyclic249/Snippits
git add PromptHelper.md
git commit -m "$(cat <<'EOF'
Strengthen Prompt Helper rules based on live paste-test feedback

Adjusts the meta-prompt to harden specific friction rules and
omit-section instructions that didn't hold up across all three target
LLMs during Tasks 5-9 of the implementation plan.
EOF
)"
```

- [ ] **Step 7: Verify commit landed.**

Run: `cd /home/gocyclic249/Snippits && git log --oneline -2`

Expected: two commits — the original `Add Phase 1 Prompt Helper artifact` and the new `Strengthen Prompt Helper rules`.

Phase 1 is complete when Task 10 either was skipped (everything passed first time) or finished with a clean commit.
