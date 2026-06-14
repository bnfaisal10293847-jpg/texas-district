# PowerShell Web Server for Texas District
# Run this script using PowerShell to serve the website locally without Node.js or Python.

$port = 3000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
} catch {
    Write-Error "Failed to start server. Make sure port $port is not in use, or run PowerShell as Administrator."
    exit
}

Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "   Texas District Web Server is Running!" -ForegroundColor Yellow
Write-Host "   Address: http://localhost:$port/" -ForegroundColor Green
Write-Host "   Press Ctrl+C in this terminal to stop." -ForegroundColor White
Write-Host "=============================================" -ForegroundColor Yellow

$publicDir = Join-Path $PSScriptRoot "public"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $url = $request.Url.LocalPath
        $rawUrl = $request.Url.PathAndQuery
        
        Write-Host "$($request.HttpMethod) $rawUrl" -ForegroundColor Cyan
        
        $filePath = ""
        $contentType = "text/html; charset=utf-8"
        
        if ($url -eq "/" -or $url -eq "") {
            $filePath = Join-Path $publicDir "index.html"
        }
        elseif ($url -eq "/rules") {
            $filePath = Join-Path $publicDir "rules.html"
        }
        elseif ($url -eq "/creators") {
            $filePath = Join-Path $publicDir "creators.html"
        }
        elseif ($url -eq "/jobs") {
            $filePath = Join-Path $publicDir "jobs.html"
        }
        elseif ($url -eq "/store") {
            $filePath = Join-Path $publicDir "store.html"
        }
        elseif ($url -eq "/admin-login") {
            $filePath = Join-Path $publicDir "admin-login.html"
        }
        elseif ($url -eq "/admin-check") {
            # Extract email from query
            $email = $null
            $query = $request.Url.Query
            if ($query -like "*email=*") {
                $params = $query.TrimStart('?').Split('&')
                foreach ($param in $params) {
                    $kv = $param.Split('=')
                    if ($kv[0] -eq "email" -and $kv.Length -gt 1) {
                        $email = [System.Uri]::UnescapeDataString($kv[1]).Trim().ToLower()
                    }
                }
            }
            
            $adminEmail = "bnfaisal10293847@gmail.com"
            if ($email -eq $adminEmail) {
                Write-Host "Admin logged in successfully: $email" -ForegroundColor Green
                $filePath = Join-Path $publicDir "admin-dashboard.html"
            } else {
                Write-Host "Unauthorized access attempt: $email" -ForegroundColor Red
                $filePath = Join-Path $publicDir "admin-check.html"
            }
        }
        else {
            # Serve static files
            $filePath = Join-Path $publicDir $url.TrimStart('/')
            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                switch ($ext) {
                    ".css" { $contentType = "text/css" }
                    ".js" { $contentType = "application/javascript" }
                    ".png" { $contentType = "image/png" }
                    ".jpg" { $contentType = "image/jpeg" }
                    ".jpeg" { $contentType = "image/jpeg" }
                    ".gif" { $contentType = "image/gif" }
                    ".svg" { $contentType = "image/svg+xml" }
                    ".ico" { $contentType = "image/x-icon" }
                    default { $contentType = "application/octet-stream" }
                }
            } else {
                # Fallback to index.html for clean routing
                $filePath = Join-Path $publicDir "index.html"
            }
        }
        
        $response.ContentType = $contentType
        $response.Headers.Add("Access-Control-Allow-Origin", "*")
        
        if (Test-Path $filePath -PathType Leaf) {
            $buffer = [System.IO.File]::ReadAllBytes($filePath)
        } else {
            $response.StatusCode = 404
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("File Not Found")
        }
        
        $response.ContentLength64 = $buffer.Length
        $output = $response.OutputStream
        try {
            if ($request.HttpMethod -ne "HEAD") {
                $output.Write($buffer, 0, $buffer.Length)
            }
        } finally {
            $output.Close()
        }
    }
}
finally {
    $listener.Stop()
}
