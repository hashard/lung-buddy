# Creates android/upload-keystore.jks + android/key.properties (gitignored).
# Run once from repo root. Keep the .jks + passwords somewhere safe.

$ErrorActionPreference = "Stop"
$androidDir = Join-Path $PSScriptRoot "..\android" | Resolve-Path
$jks = Join-Path $androidDir "upload-keystore.jks"
$props = Join-Path $androidDir "key.properties"

if (Test-Path $jks) {
    Write-Host "Keystore already exists at $jks - not overwriting."
    exit 0
}

$password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
$alias = "lungbuddy"

keytool -genkey -v `
  -keystore $jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias $alias `
  -storepass $password `
  -keypass $password `
  -dname "CN=Lung Buddy, OU=Mobile, O=LungBuddy, L=Sydney, ST=NSW, C=AU"

$lines = @(
    "storePassword=$password"
    "keyPassword=$password"
    "keyAlias=$alias"
    "storeFile=../upload-keystore.jks"
)
$lines | Set-Content -Path $props -Encoding ascii

Write-Host "Created keystore and key.properties under android/"
Write-Host "Store the password somewhere safe. Do NOT commit these files."
