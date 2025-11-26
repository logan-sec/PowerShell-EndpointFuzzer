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
.\EndpointFuzzer.ps1 -BaseUrl "https://example.com" -WordlistPath ".\wordlists\common.txt"

Cookie + Custom Header:
.\EndpointFuzzer.ps1 `
  -BaseUrl "https://example.com" `
  -WordlistPath ".\wordlists\common.txt" `
  -Cookie "auth_session=ABC123" `
  -Headers @{ "User-Agent" = "LoganFuzzer/1.0" }

POST fuzz with JSON body:
.\EndpointFuzzer.ps1 `
  -BaseUrl "https://example.com/api" `
  -WordlistPath ".\wordlists\api.txt" `
  -Method POST `
  -BodyPath ".\body.json"

Save results (CSV + TXT):
.\EndpointFuzzer.ps1 `
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
   502   200  https://example.com/api/debug
   630   403  https://example.com/private

🗂️ Folder Structure
PowerShell-EndpointFuzzer/
│
├── EndpointFuzzer.ps1
├── README.md
├── LICENSE
│
├── wordlists/
│   ├── common_endpoints.txt
│   ├── api.txt
│   └── admin.txt
│
├── examples/
│   └── sample_output.csv
│
└── docs/
    └── screenshot.png

📄 Parameters
Parameter	Description
BaseUrl	Base target URL (required)
WordlistPath	Wordlist of endpoints (required)
Cookie	Send a cookie
Headers	Custom headers (hashtable)
Method	GET, POST, PUT, DELETE, HEAD
BodyPath	Load request body from file
IncludeStatus	Only show/log selected codes
OutTxt	Save results to TXT
OutCsv	Save results to CSV
MinDelayMs	Minimum random delay
MaxDelayMs	Maximum random delay
📸 Screenshot

(Place your screenshot inside docs/screenshot.png)
Then embed it:

![Screenshot](docs/screenshot.png)

⚖️ License

Distributed under the MIT License.

⭐ If you find this useful, give the repo a star!

It helps others discover the tool.
