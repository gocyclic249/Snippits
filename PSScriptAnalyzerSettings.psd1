@{
    # PSScriptAnalyzer auto-discovers this file at the repo root.
    # Excluded rules are listed below with reasoning so a future contributor
    # can decide whether the rationale still holds.

    ExcludeRules = @(
        # PSAvoidUsingWriteHost: the scripts in this repo use colored
        # Write-Host calls as visual section headers (e.g. "== Models =="
        # in cyan). The rule's concern is that Write-Host bypasses the
        # success stream and so can't be redirected/captured -- but for UI
        # headers that's exactly the point: piping to Out-File should
        # capture data, not decorative headers.
        'PSAvoidUsingWriteHost'
    )
}
