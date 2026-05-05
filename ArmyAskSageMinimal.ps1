# This script sends a query to the Ask Sage API using PowerShell's Invoke-RestMethod.
# It includes a JSON body to specify the prompt and enable the "live+" web search feature.

# 1. Define the API endpoint URI.
$uri = "https://api.genai.army.mil/server/query"

# 2. IMPORTANT: Replace this placeholder with your actual API key or 24-hour token.
$apiKey = [System.Environment]::GetEnvironmentVariable("GENAI_API_TOKEN")

# 3. Set up the required headers in a hash table.
#    The 'x-access-tokens' header is used for authentication [1].
$headers = @{
    "Content-Type"    = "application/json"
    "x-access-tokens" = $apiKey
}

# 4. Construct the body of the request as a PowerShell hash table.
#    This object will be converted to a JSON string.
#    The 'web_search' key enables the real-time search functionality [2].
$SiteList ="haveibeenpwned.com,databreaches.net,$bleepingcomputer,krebsonsecurity.com"
$KeyWords="Breach,leak,Ransomware,Credential exposure,Vunerablity,Other Cyber Security notes"
$SearchText = "Linux"
$Days = 30
$body = @{
    message       = @" 
        Please search for $SearchText and $KeyWords in $SiteList in the last $Days. Provide a link to the article or site referenced. Format response as JSON. Use the following format for JSON.
     {
      "date_published":
      "source_site":
      "category":
      "title":
      "summary": 
      "link":
    }
"@
            persona          = 5 # can look these up using the GetArmyAskSageInfo.ps1 script in this repository
            model            = "google-gemini-2.5-pro" # can look these up using the GetArmyAskSageInfo.ps1 script in this repository
            temperature      = 0.7
            live = #2 Live = 0 is No Search, Live = 1 is basic search, Live = 2 is detailed search (called live 1+ in gui)
            # conversation_type = 'CUI' turns conversation CUI and disables search. not documented well online.
            # dataset = "all" You can look these up using the GetArmyAskSageInfo.ps1 script in this repository
            
            

}| ConvertTo-Json -Depth 3

# 5. Execute the API call.
#    -Method 'Post': Specifies the HTTP POST method.
#    -Header$env:ASK_SAGE_API_KEYs: Provides the authentication and content type headers.
#    -Body: Provides the main payload. Invoke-RestMethod automatically converts the $body hash table to JSON.
#    The response from the API is automatically parsed from JSON into a PowerShell object.
try {
    Write-Host "Sending query to Ask Sage..."
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 120

    # 6. Display the response from the API.
    #    The main content of the answer is typically in the 'response' property of the returned object.
    Write-Host "Response received:"
    Write-Output "$response.message" | ConvertTo-Json -Depth 5
}
catch {
    # Error handling for the web request.
    Write-Error "An error occurred during the API call: $_"
    # You can inspect the full error record for more details, including the HTTP status code.
    Write-Error $_.Exception.Response
}
