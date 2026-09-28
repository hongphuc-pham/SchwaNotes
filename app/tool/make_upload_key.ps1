# Creates the Google Play *upload* key for Schwa Notes, once, and wires it into the build.
#
#   powershell -ExecutionPolicy Bypass -File app/tool/make_upload_key.ps1
#
# Run it yourself: it asks for a password, and nobody else should ever see that password or
# the keystore. What it does:
#
#   1. Creates a PKCS12 keystore OUTSIDE the repository (default:
#      %USERPROFILE%\keys\schwanotes-upload.jks), alias "upload", RSA 2048, valid 10,000 days.
#   2. Writes app/android/key.properties pointing at it. That file is git-ignored
#      (app/android/.gitignore), and so is any *.jks.
#   3. Prints the four GitHub secrets the Release workflow needs, and how to set them.
#
# With Play App Signing, Google holds the key that signs what users install; this is only the
# key that proves an upload came from you. If it is ever lost, Play support can reset it — but
# that takes days. Back up the keystore file and the password somewhere other than this PC.
#
# Flutter's guide: https://docs.flutter.dev/deployment/android#sign-the-app

param(
  [string] $Keystore = (Join-Path $env:USERPROFILE 'keys\schwanotes-upload.jks'),
  [string] $Alias = 'upload'
)
$ErrorActionPreference = 'Stop'

$repoApp = Split-Path -Parent $PSScriptRoot
$properties = Join-Path $repoApp 'android\key.properties'

if (Test-Path $Keystore) { throw "A keystore already exists at $Keystore. Refusing to overwrite it." }
if (Test-Path $properties) { throw "$properties already exists. Delete it first if you really mean to replace the key." }

# keytool: from JAVA_HOME, Android Studio's bundled JDK, or PATH.
$candidates = @()
if ($env:JAVA_HOME) { $candidates += Join-Path $env:JAVA_HOME 'bin\keytool.exe' }
$candidates += 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
$onPath = Get-Command keytool -ErrorAction SilentlyContinue
if ($onPath) { $candidates += $onPath.Source }
$keytool = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $keytool) { throw 'keytool not found. Install a JDK 17 or set JAVA_HOME.' }

Write-Host "Using $keytool"
Write-Host "The keystore will be created at: $Keystore"
Write-Host ''

$first = Read-Host 'Choose a keystore password (at least 8 characters)' -AsSecureString
$again = Read-Host 'Type it again' -AsSecureString
$plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($first))
$check = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($again))
if ($plain -ne $check) { throw 'The passwords did not match. Nothing was created.' }
if ($plain.Length -lt 8) { throw 'The password must be at least 8 characters. Nothing was created.' }

$name = Read-Host 'Your name, as it should appear in the certificate (e.g. Hong Phuc Pham)'
if ([string]::IsNullOrWhiteSpace($name)) { $name = 'Schwa Notes' }

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Keystore) | Out-Null

# Passwords go to keytool through environment variables of this process only, never on a
# command line that other processes could read.
$env:SCHWA_UPLOAD_PASS = $plain
try {
  & $keytool -genkeypair -v `
    -keystore $Keystore -storetype PKCS12 `
    -alias $Alias -keyalg RSA -keysize 2048 -validity 10000 `
    -dname "CN=$name, O=Schwa Notes" `
    -storepass:env SCHWA_UPLOAD_PASS -keypass:env SCHWA_UPLOAD_PASS
  if ($LASTEXITCODE -ne 0) { throw "keytool failed with exit code $LASTEXITCODE" }
} finally {
  Remove-Item Env:\SCHWA_UPLOAD_PASS -ErrorAction SilentlyContinue
}

# PKCS12 uses one password for the store and the key.
$storeFile = $Keystore -replace '\\', '/'
@"
storePassword=$plain
keyPassword=$plain
keyAlias=$Alias
storeFile=$storeFile
"@ | Set-Content -Path $properties -Encoding ascii
$plain = $null; $check = $null

Write-Host ''
Write-Host "Created $Keystore"
Write-Host "Wrote   $properties (git-ignored)"
Write-Host ''
Write-Host 'Check that git does not see either file:'
Write-Host '  git status --short --ignored app/android/key.properties'
Write-Host ''
Write-Host 'For the Release workflow, add four repository secrets'
Write-Host '(GitHub -> Settings -> Secrets and variables -> Actions, or with gh):'
Write-Host ''
Write-Host "  UPLOAD_KEYSTORE_BASE64   the keystore, base64-encoded:"
Write-Host "      [Convert]::ToBase64String([IO.File]::ReadAllBytes('$Keystore')) | Set-Clipboard"
Write-Host '  UPLOAD_KEYSTORE_PASSWORD the password you just chose'
Write-Host "  UPLOAD_KEY_ALIAS         $Alias"
Write-Host '  UPLOAD_KEY_PASSWORD      the same password'
Write-Host ''
Write-Host 'Now back up the keystore and the password somewhere safe.'
