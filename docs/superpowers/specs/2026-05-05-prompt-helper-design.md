# Prompt Helper — Design Spec

- **Date:** 2026-05-05
- **Status:** Approved (Phase 1 only)
- **Phase 1 home:** Snippits repo (this repo)
- **Phase 2 home:** A separate dedicated repo (out of scope here)

## Context

The user works with non-technical people who would benefit from Anthropic-style prompt engineering but don't have access to Anthropic's platform tools and don't have the technical depth to install Claude Code skills. The user also wants this for themselves so they stop giving Claude Code low-quality prompts.

The artifact: a single markdown file at the Snippits root containing one pasteable meta-prompt. Users paste it into whatever chat LLM they have (claude.ai free tier, ChatGPT, Gemini, etc.); it interviews them briefly; it emits a structured Anthropic-format prompt they can copy and use for the actual task.

This spec covers Phase 1 only. Phase 2 (turning the same logic into a Claude Code skill) is explicitly out of scope and will get its own spec in a different repo when the time comes.

## Scope

In:

- One markdown file at the Snippits root: `PromptHelper.md`.
- A meta-prompt that runs a fixed six-question interview, then emits an XML-tagged Anthropic-format prompt with a paste-tolerance preamble.

Out:

- The Phase 2 skill.
- Adaptive / branching question flow.
- Built-in worked examples in the meta-prompt.
- Teaching content of any kind.

## Architecture

`PromptHelper.md` contains, in order:

1. An H1 title.
2. Two prose lines: what this is, how to use it.
3. One ` ```text ` fenced code block containing the entire meta-prompt.

The meta-prompt inside the code block has four parts in this order:

1. **Role + mission paragraph.** Tells the receiving LLM it's a prompt-engineering assistant whose job is a brief interview followed by one synthesized prompt. Contains explicit anti-friction guardrails: *"Ask exactly the six questions in order. Do not add follow-ups. Do not push back on short answers. Do not suggest improvements. Accept the user's first answer and move on."*
2. **Interview instructions.** Numbered list of the six dimensions with literal question wording (see next section). The LLM asks them one at a time, waits for each answer, accepts skips.
3. **Confirm-and-synthesize trigger.** After Q6, the LLM produces a one-line-per-dimension summary of captured answers and asks *"Ready, or anything to change?"* On confirmation it produces the final prompt; if the user names a dimension to change, the LLM re-asks that single question and re-confirms.
4. **Output template.** The literal XML skeleton the LLM fills in for synthesis (see "Output template" below).

## Interview dimensions

Six dimensions, asked in this fixed order. The literal question wording the meta-prompt instructs the LLM to use is in italics.

| # | Dimension | Literal question |
| --- | --- | --- |
| 1 | Task | *"What do you want the AI to do? Describe it in one or two sentences."* |
| 2 | Role + audience | *"What kind of expert should the AI act as, and who is it producing this for? Example: 'a senior cyber analyst writing for an executive who isn't technical.'"* |
| 3 | Context | *"What background should the AI know about your situation, project, or domain?"* |
| 4 | Example | *"Paste one example of what good output looks like to you. If you don't have one, type 'skip.'"* |
| 5 | Output format | *"How should the result be formatted? (Bulleted list, email, JSON, plain prose, etc.)"* |
| 6 | Constraints | *"Anything the AI should avoid, stay under, or stick to? (Tone, length, things not to mention.)"* |

## Behavior rules

These are explicit instructions in the meta-prompt's role + mission paragraph:

- **Fixed question count.** Ask exactly the six questions. No follow-ups, no branching, no drilling into vague answers.
- **First-answer-final.** Accept whatever the user types. Move to the next question without comment, even if the answer is short, vague, or obviously incomplete.
- **Skips are first-class.** *"skip"*, *"i don't know"*, or empty answers are recorded as `(none specified)` and the corresponding XML section is omitted entirely at synthesis time. The meta-prompt instructs the receiving LLM to mention this option in its user-facing intro before Q1 (e.g., *"You can type 'skip' on any question to leave it blank."*) so users don't have to discover it through Q4 alone.
- **One question per turn.** Don't bundle questions or restate context between them.
- **No suggestion or improvement during the interview.** Don't tell the user their answer is too vague. Don't offer alternatives. Don't lecture about why the question matters.
- **Direct clarifications are allowed, in one sentence.** If the user asks *"what do you mean by audience?"*, answer in one sentence and re-ask the original question. Don't expand into teaching.
- **Long answers are accepted verbatim.** No summarization, no condensing.

## Output template

The synthesized prompt the LLM emits has the paste-tolerance preamble at the top, then the XML body. Skipped sections are omitted entirely (not left as empty tags or `(none specified)` placeholders — empty XML blocks confuse some LLMs into thinking the user explicitly negated the section).

The notation `{...}` and `OMIT THIS ENTIRE SECTION...` below is spec-internal: it tells the prompt author what intent to encode. The actual meta-prompt phrases these as natural-language instructions to the receiving LLM (e.g., *"fill in the user's answer to question 1 here, lightly polished"*), not as literal placeholders in the synthesized output.

````text
The following prompt uses XML-style tags as section delimiters. If any tags appear malformed (missing close tags, escaped characters, unicode artifacts) due to copy-paste damage, infer the intended structure from context and proceed.

<role>
{1–2 sentences synthesized from Q2: who the AI is, who its output is for.}
</role>

<task>
{Q1, lightly polished — fix obvious typos, no rewriting.}
</task>

<context>
{Q3. OMIT THIS ENTIRE SECTION if Q3 was skipped.}
</context>

<examples>
<example>
{Q4, verbatim. OMIT THIS ENTIRE SECTION if Q4 was skipped.}
</example>
</examples>

<output_format>
{Q5. OMIT THIS ENTIRE SECTION if Q5 was skipped.}
</output_format>

<constraints>
{Q6. OMIT THIS ENTIRE SECTION if Q6 was skipped.}
</constraints>

Respond to the <task> above using the surrounding context.
````

The synthesizer applies *light polish only*: typo fixes and converting shorthand into a complete sentence. It does not rewrite, expand, or "improve" the user's words.

## Edge cases

- **Skipped Q1 (task).** A prompt with no task is useless, but pushing back at interview time violates the friction rules. The meta-prompt instructs the LLM to synthesize, in this case only, a `<task>` block reading: *"The user did not specify a task during setup. Begin by asking the user what they want you to do."* This shifts the friction to use-time, when the user is already in the receiving LLM's chat and committed.
- **User asks a direct question mid-interview.** A one-sentence answer plus re-asking the original question is allowed. Anything more is teaching, which is forbidden.
- **Wall-of-text answer.** Accepted verbatim. No summarization or pushback.

Out of scope on purpose: receiving-LLM-specific quirks (different platforms inserting preambles, refusing tags, etc.), spam/nonsense input, non-English input. The paste-tolerance preamble in the synthesized prompt is the only resilience built in; everything else is the user's problem at use-time.

## Testing

Manual, but disciplined. Before declaring Phase 1 done:

1. **Three live runs** with the same representative non-technical task (suggested: *"draft a follow-up email after a vendor demo"*), pasting the meta-prompt into:
   - claude.ai (free tier)
   - ChatGPT (free tier)
   - One other (Gemini or Copilot — whichever the target users actually use)
2. **For each run**, verify: the LLM asks all six questions in order with no follow-ups, accepts a `skip` cleanly on at least one question, presents the confirm summary, and emits the synthesized prompt with the paste-tolerance preamble plus only the non-skipped sections.
3. **Cross-paste check.** Take the synthesized prompt from run #1 and paste it into a *different* LLM than the one that produced it. Confirm the receiving LLM honors the XML structure and produces a reasonable response.
4. **Skip-Q1 check.** Run once with `skip` on Q1 and verify the synthesized prompt's `<task>` contains the "ask the user what they want" instruction rather than something empty or generic.

If any run fails, the meta-prompt's instructions get adjusted and we re-test. No automated tests; the artifact is a prompt, not code.

## Sources

User-supplied:

- <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
- <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview>
- <https://www-cdn.anthropic.com/62df988c101af71291b06843b63d39bbd600bed8.pdf>

Added during brainstorm:

- <https://github.com/anthropics/prompt-eng-interactive-tutorial> — Anthropic's own Jupyter-notebook tutorial built specifically to teach prompt engineering to non-experts. Covers the same techniques as the docs but with worked examples and exercises that match the target audience.

## Explicitly rejected during design

- **Adaptive interview flow** — reserved for Phase 2 (the skill), where orchestration logic can live outside the prompt.
- **Worked-example header** in the meta-prompt — violates the "users don't care about learning" rule.
- **Coaching or teaching mode** — same reason.
- **Two-variant output** (XML and markdown side by side) — adds complexity, doubles the surface area; users picked XML.
- **Markdown-headed output sections** — would lose the visible "Anthropic format" signature the user explicitly wants.
