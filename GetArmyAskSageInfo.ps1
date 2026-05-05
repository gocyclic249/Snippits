<#
.SYNOPSIS
    Lists the models, personas, and datasets available on the Army GenAI ("Ask Sage") API.

.DESCRIPTION
    Calls /server/get-models, /server/get-personas, and /server/get-datasets and
    prints a labeled, formatted summary of each. Useful as a quick "what's
    available right now" check before authoring a prompt or wiring up a larger
    script.

    Authenticates with the bearer token in $env:GENAI_API_TOKEN via the
    x-access-tokens header. API reference:
    https://docs.genai.army.mil/api-docs/swagger.html

.EXAMPLE
    $env:GENAI_API_TOKEN = '<your-token>'
    .\GetArmyAskSageInfo.ps1

.NOTES
    All three endpoints are POST per the API's convention, even for read-only
    listings. Response envelopes: get-models returns { data: [...] };
    get-personas and get-datasets return { response: [...] }.
#>

$token = $env:GENAI_API_TOKEN
if (-not $token) {
    Write-Error "GENAI_API_TOKEN env var is not set. Set it to your Ask Sage API token and re-run."
    return
}
$headers = @{ 'x-access-tokens' = $token; 'Content-Type' = 'application/json' }
$base    = 'https://api.genai.army.mil/server'

Write-Host "`n== Models ==" -ForegroundColor Cyan
try {
    $r = Invoke-RestMethod -Uri "$base/get-models" -Method Post -Headers $headers
    $r.data | Select-Object name, context_window, description | Format-Table -AutoSize -Wrap
} catch {
    Write-Warning "Failed to fetch models: $($_.Exception.Message)"
}

Write-Host "`n== Personas ==" -ForegroundColor Cyan
try {
    $r = Invoke-RestMethod -Uri "$base/get-personas" -Method Post -Headers $headers
    $r.response | Select-Object name, id, description | Format-Table -AutoSize -Wrap
} catch {
    Write-Warning "Failed to fetch personas: $($_.Exception.Message)"
}

Write-Host "`n== Datasets ==" -ForegroundColor Cyan
try {
    $r = Invoke-RestMethod -Uri "$base/get-datasets" -Method Post -Headers $headers
    $r.response | Select-Object name, status, token_count, file_count, description | Format-Table -AutoSize -Wrap
} catch {
    Write-Warning "Failed to fetch datasets: $($_.Exception.Message)"
}
