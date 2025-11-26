param(
    [Parameter(Mandatory = $true)]
    [string]$BaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$WordlistPath,

    [string]$Cookie = "",
    [string]$OutTxt = "",
    [string]$OutCsv = "",
    [int[]]$IncludeStatus = @(200,301,302,401,403),
    [hashtable]$Headers = @{},
    [string]$Method = "GET",
    [int]$MinDelayMs = 0,
    [int]$MaxDelayMs = 0,
    [string]$BodyPath = ""
)

function Write-ColoredStatus {
    param(
        [string]$Endpoint,
        [string]$Prefix,
        [string]$StatusText       # "200" or "NoResponse"
    )

    $color = "White"

    if ($StatusText -eq "NoResponse") {
        $color = "Magenta"
    }
    else {
        $code = [int]$StatusText

        if     ($code -ge 200 -and $code -lt 300) { $color = "Green" }   # 2xx
        elseif ($code -ge 300 -and $code -lt 400) { $color = "Yellow" }  # 3xx
        elseif ($code -ge 400 -and $code -lt 500) { $color = "Red" }     # 4xx
        elseif ($code -ge 500 -and $code -lt 600) { $color = "DarkRed" } # 5xx
        else                                      { $color = "DarkGray" }
    }

    Write-Host "$Prefix $Endpoint --> $StatusText" -ForegroundColor $color
}

$ProgressPreference = "SilentlyContinue"

# Validate wordlist
if (-not (Test-Path $WordlistPath)) {
    Write-Host "[-] Wordlist not found: $WordlistPath"
    exit
}

# Optional body file (for POST/PUT etc.)
$BodyContent = $null
if ($BodyPath -ne "") {
    if (-not (Test-Path $BodyPath)) {
        Write-Host "[-] Body file not found: $BodyPath"
        exit
    }
    $BodyContent = Get-Content $BodyPath -Raw
}

# Build headers hashtable (Cookie + user headers)
$allHeaders = @{}

if ($Cookie -ne "") {
    $allHeaders["Cookie"] = $Cookie
}

foreach ($key in $Headers.Keys) {
    $allHeaders[$key] = $Headers[$key]
}

# Prepare CSV output (write header)  # NEW: add length column
if ($OutCsv -ne "") {
    "endpoint,status,length" | Out-File -FilePath $OutCsv -Encoding utf8
}

# Normalize base URL: remove ALL trailing slashes
$BaseUrl = $BaseUrl.TrimEnd('/')

$words = Get-Content $WordlistPath | Where-Object { $_.Trim() -ne "" }

Write-Host "[*] Fuzzing $($words.Count) endpoints against $BaseUrl using $Method"
Write-Host ""

# Stats
$stats = [ordered]@{
    Total      = 0
    Matched    = 0
    Success2xx = 0
    Redirect3xx= 0
    Client4xx  = 0
    Server5xx  = 0
    NoResponse = 0
}

# NEW: store results for length diffing
$results = @()

foreach ($word in $words) {

    $stats.Total++

    # Clean endpoint: remove whitespace + leading slashes
    $cleanWord = $word.Trim().TrimStart('/')

    # Force EXACTLY one slash between base + endpoint
    $endpoint = "$BaseUrl/$cleanWord"

    try {
        # Build base request arguments
        $invokeArgs = @{
            Uri         = $endpoint
            Method      = $Method
            TimeoutSec  = 10
            ErrorAction = 'Stop'
        }

        if ($allHeaders.Count -gt 0) {
            $invokeArgs["Headers"] = $allHeaders
        }
        if ($BodyContent) {
            $invokeArgs["Body"] = $BodyContent
        }

        $response = Invoke-WebRequest @invokeArgs

        $code   = [int]$response.StatusCode
        $length = $response.RawContentLength   # NEW

        # Stats by range
        if     ($code -ge 200 -and $code -lt 300) { $stats.Success2xx++ }
        elseif ($code -ge 300 -and $code -lt 400) { $stats.Redirect3xx++ }
        elseif ($code -ge 400 -and $code -lt 500) { $stats.Client4xx++ }
        elseif ($code -ge 500 -and $code -lt 600) { $stats.Server5xx++ }

        # Save result for length diffing   # NEW
        $results += [PSCustomObject]@{
            Endpoint = $endpoint
            Status   = $code
            Length   = $length
        }

        # Filter by IncludeStatus (empty array = no filter)
        if ($IncludeStatus.Count -eq 0 -or $IncludeStatus -contains $code) {
            $stats.Matched++
            Write-ColoredStatus -Endpoint $endpoint -Prefix "[+]" -StatusText $code

            if ($OutTxt -ne "") {
                "$endpoint -- $code -- $length bytes" | Add-Content -Path $OutTxt
            }

            if ($OutCsv -ne "") {
                "$endpoint,$code,$length" | Add-Content -Path $OutCsv
            }
        }

    }
    catch {
        if ($_.Exception.Response) {
            $resp = $_.Exception.Response
            $code = $resp.StatusCode.value__

            # try to get length if available        # NEW
            $length = $null
            if ($resp.ContentLength -ne $null) {
                $length = $resp.ContentLength
            }

            if     ($code -ge 200 -and $code -lt 300) { $stats.Success2xx++ }
            elseif ($code -ge 300 -and $code -lt 400) { $stats.Redirect3xx++ }
            elseif ($code -ge 400 -and $code -lt 500) { $stats.Client4xx++ }
            elseif ($code -ge 500 -and $code -lt 600) { $stats.Server5xx++ }

            # Save result for length diffing (if we got a length)  # NEW
            $results += [PSCustomObject]@{
                Endpoint = $endpoint
                Status   = $code
                Length   = $length
            }

            if ($IncludeStatus.Count -eq 0 -or $IncludeStatus -contains $code) {
                $stats.Matched++
                Write-ColoredStatus -Endpoint $endpoint -Prefix "[-]" -StatusText $code

                if ($OutTxt -ne "") {
                    "$endpoint -- $code -- $length bytes" | Add-Content -Path $OutTxt
                }

                if ($OutCsv -ne "") {
                    "$endpoint,$code,$length" | Add-Content -Path $OutCsv
                }
            }
        }
        else {
            $stats.NoResponse++
            Write-ColoredStatus -Endpoint $endpoint -Prefix "[!]" -StatusText "NoResponse"

            if ($OutTxt -ne "") {
                "$endpoint -- NoResponse" | Add-Content -Path $OutTxt
            }

            if ($OutCsv -ne "") {
                "$endpoint,NoResponse," | Add-Content -Path $OutCsv
            }
        }
    }

    # Optional random delay to reduce rate limiting
    if ($MaxDelayMs -gt 0) {
        $min   = [Math]::Max(0, $MinDelayMs)
        $delay = Get-Random -Minimum $min -Maximum $MaxDelayMs
        Start-Sleep -Milliseconds $delay
    }
}

Write-Host ""
Write-Host "===== Summary ====="
$stats.GetEnumerator() | ForEach-Object {
    Write-Host ("{0,-12}: {1}" -f $_.Key, $_.Value)
}

# NEW: Content-length diffing summary
if ($results.Count -gt 0) {
    Write-Host ""
    Write-Host "===== Content-Length Analysis ====="

    $groups = $results |
        Where-Object { $_.Length -ne $null } |
        Group-Object Length |
        Sort-Object Count -Descending

    if ($groups.Count -gt 0) {
        $baselineLength = $groups[0].Name
        Write-Host ("Most common length: {0} bytes (baseline)" -f $baselineLength)

        Write-Host ""
        Write-Host "Endpoints with unusual lengths:"
        $results |
            Where-Object { $_.Length -ne $null -and $_.Length -ne $baselineLength } |
            Sort-Object Length, Status |
            ForEach-Object {
                Write-Host ("{0,8}  {1,3}  {2}" -f $_.Length, $_.Status, $_.Endpoint)
            }
    }
}
