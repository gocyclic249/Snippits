# Snippits

Scripts and Notes too small for their own project.

## Scripts

- [`DVRInfoForDLP.ps1`](DVRInfoForDLP.ps1) — Gathers the device, AD profile, and host hardware info required for an Air Force / Space Force DLP (Data Loss Prevention) waiver. Windows + domain-joined.
- [`GetArmyAskSageInfo.ps1`](GetArmyAskSageInfo.ps1) — Lists the models, personas, and datasets available on the Army GenAI ("Ask Sage") API. Requires `$env:GENAI_API_TOKEN`.
- [`ArmyAskSageMinimal.ps1`](ArmyAskSageMinimal.ps1) — Minimal one-shot example of querying the Ask Sage API. Requires `$env:GENAI_API_TOKEN`.

## Notes

- [`SyncToGitLab.md`](SyncToGitLab.md) — Setting up a GitHub Actions workflow that mirrors this repo (or any repo) to a GitLab remote, including prerequisites and common errors.

## Compatibility

PowerShell scripts target both Windows PowerShell 5.1 and PowerShell 7+. The DLP script needs a domain-joined Windows host; the Ask Sage scripts run anywhere PowerShell runs.

## Linting

Project configs (`PSScriptAnalyzerSettings.psd1`, `.markdownlint-cli2.jsonc`) are auto-discovered by their respective tools. Recommended local checks before commit: `pwsh -c "Invoke-ScriptAnalyzer -Path . -Recurse"`, `markdownlint-cli2 "*.md"`, `actionlint`, and `gitleaks detect`.
