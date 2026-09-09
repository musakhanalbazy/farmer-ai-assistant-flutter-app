$usersJsonPath = "$PSScriptRoot\..\assets\data\login_users.json"
$usersJsonPath = Resolve-Path $usersJsonPath

$profilesJsonPath = "$PSScriptRoot\..\assets\data\business_profiles.json"
$profilesJsonPath = Resolve-Path $profilesJsonPath

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:4040/")
try {
    $listener.Start()
    Write-Host "VisaBot dev server running at http://localhost:4040/"
    Write-Host "Users JSON:    $usersJsonPath"
    Write-Host "Profiles JSON: $profilesJsonPath"
} catch {
    Write-Host "Could not start server on port 4040. It is likely that another instance of the VisaBot server is already running." -ForegroundColor Yellow
    Write-Host "If you want to restart the server, please find and close the existing 'VisaBot Dev Server' command prompt window." -ForegroundColor Yellow
    Exit 0
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    # CORS headers
    $response.Headers.Add("Access-Control-Allow-Origin", "*")
    $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
    $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $response.ContentType = "application/json"

    if ($request.HttpMethod -eq "OPTIONS") {
        $response.StatusCode = 200
        $response.Close()
        continue
    }

    $path = $request.Url.AbsolutePath

    # ── /users endpoint ───────────────────────────────────────────────────
    if ($path -eq "/users") {
        if ($request.HttpMethod -eq "GET") {
            $content = Get-Content $usersJsonPath -Raw
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.StatusCode = 200
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.Close()
        }
        elseif ($request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream)
            $body = $reader.ReadToEnd()
            $reader.Close()

            $newUser = $body | ConvertFrom-Json
            $data = Get-Content $usersJsonPath -Raw | ConvertFrom-Json

            $email = $newUser.email.ToLower().Trim()
            $exists = ($data.users | Where-Object { $_.email.ToLower().Trim() -eq $email }).Count -gt 0

            if ($exists) {
                $resp = '{"error":"Email already registered"}'
                $response.StatusCode = 409
            } else {
                $data.users += $newUser
                $data | ConvertTo-Json -Depth 10 | Set-Content $usersJsonPath -Encoding UTF8
                Write-Host "Added user: $email to login_users.json"
                $resp = '{"success":true}'
                $response.StatusCode = 201
            }

            $bytes = [System.Text.Encoding]::UTF8.GetBytes($resp)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.Close()
        }
        else {
            $response.StatusCode = 405
            $response.Close()
        }
    }

    # ── /business-profiles endpoint ───────────────────────────────────────
    elseif ($path -eq "/business-profiles") {
        if ($request.HttpMethod -eq "GET") {
            $content = Get-Content $profilesJsonPath -Raw
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.StatusCode = 200
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.Close()
        }
        elseif ($request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream)
            $body = $reader.ReadToEnd()
            $reader.Close()

            $newProfile = $body | ConvertFrom-Json
            $data = Get-Content $profilesJsonPath -Raw | ConvertFrom-Json

            # Ensure profiles array exists
            if ($null -eq $data.profiles) {
                $data | Add-Member -NotePropertyName "profiles" -NotePropertyValue @()
            }

            # Add timestamp
            $newProfile | Add-Member -NotePropertyName "createdAt" -NotePropertyValue (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") -Force

            $data.profiles += $newProfile
            $data.lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
            $data | ConvertTo-Json -Depth 10 | Set-Content $profilesJsonPath -Encoding UTF8

            $orgName = $newProfile.organizationName
            Write-Host "Added business profile: $orgName to business_profiles.json"

            $resp = '{"success":true}'
            $response.StatusCode = 201

            $bytes = [System.Text.Encoding]::UTF8.GetBytes($resp)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.Close()
        }
        else {
            $response.StatusCode = 405
            $response.Close()
        }
    }

    # ── 404 fallback ──────────────────────────────────────────────────────
    else {
        $response.StatusCode = 404
        $response.Close()
    }
}
