$headers = @{'x-access-tokens' = [System.Environment]::GetEnvironmentVariable("GENAI_API_TOKEN"); 'Content-Type' = 'application/json'}
$response = Invoke-RestMethod -Uri 'https://api.genai.army.mil/server/get-models' -Method Post -Headers $headers
$response.data.name  # or $response.message depending on actual response
$response = Invoke-RestMethod -Uri 'https://api.genai.army.mil/server/get-personas' -Method Post -Headers $headers
$persona = $response.response | Select-Object name, id # or $response.message depending on actual response
$persona
$dataset = Invoke-RestMethod -Uri 'https://api.genai.army.mil/server/get-datasets' -Method Post -Headers $headers
$dataset.response 
