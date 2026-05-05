# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository nature

Snippits is a grab-bag of standalone scripts and short markdown notes that are individually too small to deserve their own repo, kept here so they're easy to grab from GitHub/GitLab. Per `README.md`: "Scripts and Notes too small for their own project."

These are mostly **testing / exploration scripts**, not production tooling. Optimize accordingly:

- **Simplicity over abstraction.** Don't refactor a 10-line snippet into functions, modules, or param blocks unless the user asks. The point is something paste-and-runnable.
- **Good error messages matter.** When a snippet fails (missing env var, AD lookup returns nothing, API returns a non-success code), it should say *what* failed in plain language — these run on someone else's machine where the failure mode isn't obvious. Prefer explicit `Write-Error` / guard checks over silent `-ErrorAction SilentlyContinue` unless suppressing noise is the actual goal (e.g. `Get-PnpDevice` on a host without that device class).
- **No build system or test suite is wired up; lint configs (see "Linting" below) are.** Don't scaffold more.
- New additions should follow the same shape: a single small file at the repo root, named for what it does.

## Top priority: don't commit secrets

The user is candid that they get lazy about secret hygiene on these short scripts ("I'll just paste the token in to test it real quick"). Before any commit or PR in this repo, **explicitly check the diff for hardcoded credentials** — API keys, bearer tokens, PATs, passwords, connection strings, internal hostnames that imply credentials. Treat this as a hard gate, not a nice-to-have. `gitleaks detect` is installed and is the right backstop.

What "good" looks like in this repo: secrets come from environment variables (`[System.Environment]::GetEnvironmentVariable("FOO_TOKEN")` or `$env:FOO_TOKEN`), referenced by name only. `GetArmyAskSageInfo.ps1` and `ArmyAskSageMinimal.ps1` are the reference patterns — `GENAI_API_TOKEN` is read from the environment, never inlined.

If you find a hardcoded secret while editing or reviewing, stop and flag it before continuing — don't quietly "fix" it in a commit, because the secret is still in history and needs rotation.

## Documentation expectations

Documentation is the second priority after secret hygiene. For every script:

- **In-file**: a top-of-file comment (one or two lines is fine for trivial snippets; a PowerShell `<# .SYNOPSIS … #>` block for anything that takes parameters or env vars) saying *what* the script does and *why* you'd run it. `GetArmyAskSageInfo.ps1` and `ArmyAskSageMinimal.ps1` show the synopsis-block style.
- **Required env vars / prereqs**: if the script needs `GENAI_API_TOKEN`, a domain-joined host, admin rights, etc., note it in-file.
- **README**: when adding a new snippet, add a one-line entry to `README.md` so the index stays useful — as the collection grows that's where someone hunting for "the script that does X" will look first.

## Target environment for the PowerShell scripts

The scripts target **a mix of Windows PowerShell 5.1 and PowerShell 7+** because the user's environment runs both. Every `.ps1` here MUST work on both versions. Practical rules:

- **No PS7-only syntax.** Avoid ternary `? :`, null-conditional `?.` / `?[]`, null-coalescing `??` / `??=`, pipeline chain `&&` / `||`, `ForEach-Object -Parallel`.
- **Use CIM, not WMI.** `Get-WmiObject` / `Invoke-WmiMethod` etc. were removed in PowerShell 7. Use `Get-CimInstance -ClassName Win32_X` — works identically on 5.1 and 7+, and the output property names are the same. Note `-ClassName` (CIM) vs the WMI cmdlet's `-Class`.
- **Color via `Write-Host -ForegroundColor`**, not `$PSStyle` (PS7-only).

The scripts also assume a **domain-joined Windows host** (not Linux/pwsh). Specifically they rely on:

- `Get-PnpDevice` (Windows-only PnP cmdlet)
- `Get-CimInstance` with `Win32_*` classes (Windows CIM/WMI infrastructure)
- `System.DirectoryServices.DirectorySearcher` against the user's domain (uses `$env:USERNAME` to look up `givenname`, `sn`, `mail`, `employeeid` in AD)
- Process-scoped environment variables for secrets (e.g. `GENAI_API_TOKEN` in `GetArmyAskSageInfo.ps1`)

Do not "port" these to pwsh-on-Linux or replace PnP/DirectoryServices with cross-platform equivalents — that defeats their purpose. The dev workstation here is Linux, but execution is on Windows.

## Context for specific scripts

- `DVRInfoForDLP.ps1` — gathers the data fields required for an Air Force / Space Force **DLP (Data Loss Prevention) waiver**: removable-media identifiers, the user's AD profile, and host hardware. Output is intentionally tab-separated with three blank columns to match the waiver form layout. Don't "clean up" the blank columns or skip-1 trim — that formatting is the contract.
- `GetArmyAskSageInfo.ps1` — lists models, personas, and datasets exposed by `https://api.genai.army.mil/server/*` (the Army's GenAI / "Ask Sage" service). Auth: bearer token from `GENAI_API_TOKEN` env var via the `x-access-tokens` header. All endpoints are POST even for read-only listing calls; that's the API's convention, not a bug.
- `ArmyAskSageMinimal.ps1` — minimal one-shot example of `POST /server/query` against the same Ask Sage API, demonstrating persona / model / temperature / live-search params. Use `GetArmyAskSageInfo.ps1` to look up valid persona IDs, model names, and dataset names.

## GitLab mirroring

`.github/workflows/mirror.yml` mirrors every push and branch deletion to a GitLab remote, driven by two GitHub Actions secrets:

- `GITLAB_TOKEN` — GitLab PAT with repo write
- `GITLAB_REPO_URL` — bare host/path form, e.g. `web.git.mil/User/Project.git` (no scheme, no `oauth2:` prefix — the workflow adds those)

`SyncToGitLab.md` is the human-facing setup guide for the same workflow and inlines the YAML verbatim. If you change `mirror.yml`, update the inlined copy in `SyncToGitLab.md` to match.

The destination host `web.git.mil` is a DoD GitLab instance, which is why this mirror exists — public dev happens on GitHub, the authoritative copy lives on the `.mil` side.

## Linting

The repo's tools are PSScriptAnalyzer, gitleaks, actionlint, and markdownlint-cli2. There are two project-level config files at the repo root that PSScriptAnalyzer and markdownlint-cli2 auto-discover; both deliberately disable rules that fight the repo's chosen style:

- `PSScriptAnalyzerSettings.psd1` excludes `PSAvoidUsingWriteHost` — the colored section headers in the scripts are deliberate UI; they shouldn't appear in pipeline output, which is what the rule defends against.
- `.markdownlint-cli2.jsonc` disables `MD013` (line-length) — the repo's prose markdown is soft-wrapped by paragraph rather than hard-wrapped at 80.

If you suppress a new rule, leave a comment in the config file explaining *why* — same standard as in code.

## Commit / PR workflow

`main` is the default and working branch; recent history shows commits land directly on `main`. There is no CI beyond the mirror workflow, so "passing CI" just means the mirror push succeeded — it does not validate the scripts themselves. Before committing, run the four linters locally; the secret-scan gate is the non-negotiable one.
