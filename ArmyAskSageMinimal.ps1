<#
.SYNOPSIS
    Sends a single prompt to the Army GenAI ("Ask Sage") /server/query endpoint and prints the response.

.DESCRIPTION
    Minimal example of issuing one query against the Ask Sage API. Useful as a
    starting point for larger automations or as a sanity check that your
    GENAI_API_TOKEN works.

    Authenticates with the bearer token in $env:GENAI_API_TOKEN via the
    x-access-tokens header. API reference:
    https://docs.genai.army.mil/api-docs/swagger.html

.EXAMPLE
    $env:GENAI_API_TOKEN = '<your-token>'
    .\ArmyAskSageMinimal.ps1

.NOTES
    Compatible with Windows PowerShell 5.1 and PowerShell 7+.

    The 'live' parameter controls web search:
        0 = no search    1 = basic search    2 = detailed search ("live+" in the GUI)

    Personas, models, and datasets can be enumerated with GetArmyAskSageInfo.ps1
    in this repository.
#>

$token = $env:GENAI_API_TOKEN
if (-not $token) {
    Write-Error "GENAI_API_TOKEN env var is not set. Set it to your Ask Sage API token and re-run."
    return
}

$uri = 'https://api.genai.army.mil/server/query'
$headers = @{
    'Content-Type'    = 'application/json'
    'x-access-tokens' = $token
}

$body = @{
    message     = 'Summarize the top three cybersecurity news stories from the last 24 hours. For each, include the publication date, source site, headline, a one-sentence summary, and the URL.'
    persona     = 5                            # look up valid IDs with GetArmyAskSageInfo.ps1
    model       = 'google-gemini-2.5-pro'      # look up valid names with GetArmyAskSageInfo.ps1
    temperature = 0.7
    live        = 2                            # 0 = no search, 1 = basic, 2 = detailed (called "live+" in the GUI)
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending query to Ask Sage..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 120
    $response.message
}
catch {
    Write-Error "Ask Sage query failed: $($_.Exception.Message)"
}
