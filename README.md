🛠️ PowerShell Endpoint Fuzzer

A fast, customizable endpoint fuzzer built entirely in PowerShell — designed for bug bounty hunters, pentesters, and AppSec engineers.
Supports custom headers, cookies, HTTP methods, POST bodies, colored output, content-length diffing, CSV/TXT logging, and more.

🔥 Features

🚀 Fast + lightweight

🎨 Color-coded output (2xx green, 3xx yellow, 4xx red, 5xx dark red)

🧪 Supports GET / POST / PUT / DELETE / HEAD

🍪 Cookie support

🧩 Custom headers (-Headers @{ "Key" = "Value" })

📄 POST/PUT request bodies via file (-BodyPath)

📊 Smart content-length diffing

📝 Output to TXT & CSV

⏱️ Random delay options to avoid rate-limiting

🧮 Detailed summary & stats

🪟 Windows PowerShell + PowerShell 7 compatible

📦 Installation

Clone the repo:

git clone https://github.com/logan-sec/PowerShell-EndpointFuzzer


Or download the .ps1 file directly from GitHub.

⚡ Quick Start
 Basic fuzz:
- .\EndpointFuzzer.ps1 -BaseUrl "https://example.com" -WordlistPath ".\wordlists\common.txt"

Cookie + Custom Header:
- .\EndpointFuzzer.ps1 `
  -BaseUrl "https://example.com" `
  -WordlistPath ".\wordlists\common.txt" `
  -Cookie "auth_session=ABC123" `
  -Headers @{ "User-Agent" = "LoganFuzzer/1.0" }

POST fuzz with JSON body:
- .\EndpointFuzzer.ps1 `
  -BaseUrl "https://example.com/api" `
  -WordlistPath ".\wordlists\api.txt" `
  -Method POST `
  -BodyPath ".\body.json"

Save results (CSV + TXT):
- .\EndpointFuzzer.ps1 `
  -BaseUrl "https://example.com" `
  -WordlistPath ".\wordlists\common.txt" `
  -OutTxt results.txt `
  -OutCsv results.csv

🎨 Color Output Example
[+] https://example.com/admin      --> 200   (Green)
[-] https://example.com/login      --> 403   (Red)
[!] https://example.com/unknown    --> NoResponse  (Magenta)

📊 Content-Length Diffing

The fuzzer automatically analyzes response sizes and highlights endpoints whose response length is unusual, helping you spot:

Hidden panels

Misconfigured endpoints

Erroring APIs

Interesting admin routes

Example:

===== Content-Length Analysis =====
Most common length: 1024 bytes (baseline)

Endpoints with unusual lengths:

502   200   https://example.com/api/debug
630   403   https://example.com/private

📐 Parameters

Parameter	Description
- BaseUrl	Target base URL (required)
- WordlistPath	Path to endpoint wordlist (required)
- Cookie	Sends a cookie with the request
- Headers	Custom headers (PowerShell hashtable)
- Method	HTTP method: GET, POST, PUT, DELETE, HEAD
- BodyPath	Loads request body from a file
- IncludeStatus	Only show/log selected HTTP codes
- OutTxt	Save results to a .txt file
- OutCsv	Save results to a .csv file
- MinDelayMs	Minimum random delay (ms)
- MaxDelayMs	Maximum random delay (ms)

⚖️ License

Distributed under the MIT License.

⭐ If you find this useful, give the repo a star!

It helps others discover the tool.
