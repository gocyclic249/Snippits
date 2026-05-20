# PowerShell Script to Fetch CVEs for Specified Companies from NIST NVD API

# List of companies

$now = Get-Date -Format 'yyyyMMdd-HHmm'
$ScripLocation = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$ScripLocation
$csvPath = "$ScripLocation\$now-cves.csv"
$csvPath
$companies = @("Cisco", "Dell", "Microsoft", "Delta" , "Rockwell" , "Palo", "VMWare")

# Array to hold the results
$results = @()

# Optional: Set your NVD API key for higher rate limits (request at https://nvd.nist.gov/developers/request-an-api-key)
$apiKey = ""  # Replace with your API key if available

# Base URL for NVD CVE API v2.0
$baseUrl = "https://services.nvd.nist.gov/rest/json/cves/2.0"

# Rate limit delay: Without API key ~6 seconds (5 req/30s), with key ~0.6 seconds (50 req/30s)
$delaySeconds = if ([string]::IsNullOrEmpty($apiKey)) { 7 } else { 0.8 }

# Optional: Limit to CVEs published in the last year to reduce results
$pubStartDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddT00:00:00.000")
$pubEndDate = (Get-Date).ToString("yyyy-MM-ddT23:59:59.000")

# Log file for debugging
$logFile = "nvd_api_log.txt"
function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Output $logMessage
}

Write-Log "Starting CVE fetch process for companies: $($companies -join ', ')"

foreach ($company in $companies) {
    $startIndex = 1
    $totalResults = 0
    Write-Log "Fetching CVEs for $company"
    
    do {
        # Build query parameters
        $params = @{
            keywordSearch = $company
            resultsPerPage = 100  # Maximum allowed per page
            pubStartDate = $pubStartDate
            pubEndDate = $pubEndDate
        }

        # Construct the URI with query string
        $queryString = ($params.GetEnumerator() | ForEach-Object {
            if ($_.Key -in @("pubStartDate", "pubEndDate")) {
                # Do not encode date parameters to keep colons intact
                "$($_.Key)=$($_.Value)"
            } else {
                # Encode other parameters
                "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))"
            }
        }) -join '&'
        $headers = @{
        'apiKey' = [System.Environment]::GetEnvironmentVariable($apiKey)
        'Content-Type' = 'application/json'
    }
        $uri = $baseUrl+"?"+$queryString
        $uri
        Write-Log "Querying API: $uri"

        # Make the API request
        try {
            $response = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers $headers
        } catch {
            $errorMessage = "Error fetching data for $company at startIndex $startIndex - $($_.Exception.Message)"
            Write-Log $errorMessage
            Write-Error $errorMessage
            break
        }

        # Update totalResults on first call
        if ($startIndex -eq 0) {
            $totalResults = $response.totalResults
            Write-Log "Total results for ${$company: $totalResults}"
        }

        # Process vulnerabilities
        foreach ($vuln in $response.vulnerabilities) {
            $cveId = $vuln.cve.id
            $link = "https://nvd.nist.gov/vuln/detail/$cveId"
            $description = ($vuln.cve.descriptions | Where-Object { $_.lang -eq "en" }).value
            $results += [PSCustomObject]@{
                Company = $company
                CVE = $cveId
                Description = $description
                Link = $link
            }
        }

        # Update startIndex for next page
        $startIndex += $response.vulnerabilities.Count
        Write-Log "Processed $startIndex of $totalResults CVEs for $company"

        # Respect rate limit
        Start-Sleep -Seconds $delaySeconds

    } while ($startIndex -lt $totalResults)
}

# Export results to CSV
$results | Format-Table -AutoSize
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Force
Write-Log "CSV file '$csvPath' created with $($results.Count) entries."
Write-Output "CSV file '$csvPath' created with $($results.Count) entries."
