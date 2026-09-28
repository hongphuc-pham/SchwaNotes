# Checks store/listing.md against Google Play's character limits.
# https://support.google.com/googleplay/android-developer/answer/9859152
# Usage (from the repo root):  powershell -File store/check_listing.ps1
$ErrorActionPreference = 'Stop'
$text = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'listing.md')

# The first fenced block under each heading.
function Block([string] $heading) {
  $pattern = '(?ms)^## ' + [regex]::Escape($heading) + '.*?^```\r?\n(.*?)\r?\n```'
  $m = [regex]::Match($text, $pattern)
  if (-not $m.Success) { throw "No fenced block under '## $heading'" }
  # Play counts characters as the user sees them; normalise line endings to one char.
  return $m.Groups[1].Value -replace "`r`n", "`n"
}

$limits = [ordered]@{
  'App name'          = 30
  'Short description' = 80
  'Full description'  = 4000
  'Release notes'     = 500
}

$failed = $false
foreach ($name in $limits.Keys) {
  $value = Block $name
  # Count text elements, not UTF-16 units, so ə and • count as one each.
  $length = (New-Object System.Globalization.StringInfo $value).LengthInTextElements
  $limit = $limits[$name]
  $ok = $length -le $limit
  if (-not $ok) { $failed = $true }
  '{0,-18} {1,5} / {2,-5} {3}' -f $name, $length, $limit, ($(if ($ok) { 'ok' } else { 'TOO LONG' }))
}
if ($failed) { exit 1 }
