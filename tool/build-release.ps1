# Build a release APK with private values that must not be committed.
#
# Copy build.local.example.json to build.local.json, fill in the real values,
# then run from the repository root:
#
#   powershell -ExecutionPolicy Bypass -File tool/build-release.ps1
#
# build.local.json is gitignored. Never put a real owner email, creator code or
# feedback alias in README.md, a public issue or a screenshot.

param(
    [string]$Config = "build.local.json"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Config)) {
    throw "Missing $Config. Copy build.local.example.json and fill it in."
}

$settings = Get-Content $Config -Raw | ConvertFrom-Json
$flutterArgs = @(
    "build", "apk", "--release",
    "--obfuscate",
    "--split-debug-info=build/symbols"
)

function Add-Define([string]$name, [string]$value) {
    if (-not [string]::IsNullOrWhiteSpace($value)) {
        $script:flutterArgs += "--dart-define=$name=$value"
    }
}

Add-Define "ADVISOR_PROXY_URL" $settings.advisorProxyUrl
Add-Define "OWNER_EMAIL" $settings.ownerEmail
Add-Define "OWNER_ACCESS_CODE" $settings.ownerAccessCode
Add-Define "FEEDBACK_EMAIL" $settings.feedbackEmail

Write-Host "Building with private defines from $Config (values not printed)."
& flutter @flutterArgs
if ($LASTEXITCODE -ne 0) {
    throw "flutter build failed with exit code $LASTEXITCODE"
}

$apk = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $apk)) {
    throw "Build finished but $apk is missing."
}

$hash = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLower()
Write-Host "APK: $apk"
Write-Host "SHA256: $hash"
