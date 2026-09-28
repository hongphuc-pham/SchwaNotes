<#
.SYNOPSIS
  The PowerShell twin of the Makefile, for a machine with no `make` installed.

.DESCRIPTION
  Windows has no `make` out of the box. This runs the same tasks with nothing
  to install:

      .\make.ps1 ci          # everything CI runs, in order
      .\make.ps1 test-unit
      .\make.ps1 run-emulator

  If you would rather use the Makefile: winget install ezwinports.make

  The two files must stay in step. Change a recipe in one, change it in both.

.PARAMETER Task
  The task to run. Omit it to list them.

.PARAMETER Emulator
  Which AVD `emulator` and `run-emulator` should boot.
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string] $Task = 'help',

  [string] $Emulator = 'Pixel_9_Pro'
)

$ErrorActionPreference = 'Stop'

$repoRoot = $PSScriptRoot
$appDir = Join-Path $repoRoot 'app'

# Flutter is not on PATH in every shell (docs/PROGRESS.md §2). Fall back to the
# known-good install rather than failing with "command not found".
$flutter = if (Get-Command flutter -ErrorAction SilentlyContinue) {
  'flutter'
} else {
  'C:\src\flutter\bin\flutter.bat'
}
$dart = if (Get-Command dart -ErrorAction SilentlyContinue) {
  'dart'
} else {
  'C:\src\flutter\bin\dart.bat'
}

# Runs a command in app/ and stops the script if it fails, so `ci` cannot
# report success after a step has already gone wrong.
#
# Failure is judged by **exit code only**. Windows PowerShell 5.1 wraps every
# line a native program writes to stderr in an ErrorRecord, which under
# `$ErrorActionPreference = 'Stop'` kills the script even when the program
# succeeded - and several of these tools log progress to stderr. So the
# preference is relaxed for the duration of the call and the exit code is
# checked afterwards.
function Invoke-InApp {
  param([string] $Exe, [string[]] $Arguments)

  Write-Host "==> $Exe $($Arguments -join ' ')" -ForegroundColor Cyan
  Push-Location $appDir
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) {
      throw "$Exe $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
  } finally {
    $ErrorActionPreference = $previous
    Pop-Location
  }
}

$tasks = [ordered]@{
  'setup'            = 'Fetch packages and run every generator'
  'gen'              = 'Run build_runner (riverpod, freezed, json, drift)'
  'l10n'             = 'Regenerate lib/core/l10n/gen/ from app_en.arb'
  'fmt'              = 'Format the code in place'
  'fmt-check'        = 'Fail if anything is unformatted (what CI runs)'
  'analyze'          = 'Static analysis, warnings and infos fatal'
  'licences'         = 'Fail on any non-permissive dependency licence (RULES 15)'
  'migration-safety' = 'Fail on destructive migration patterns (RULES 7)'
  'test'             = 'Run every test'
  'test-unit'        = 'Unit tests only - domain, application, data, core'
  'test-widget'      = 'Widget tests only'
  'test-migration'   = 'Migration tests - blocking, never skip (RULES 29)'
  'test-arch'        = 'The layer-boundary and grapheme rules (RULES 20, 21)'
  'ci'               = 'Everything CI runs, in order'
  'doctor'           = "Flutter's own environment check"
  'devices'          = 'List attached devices and running emulators'
  'emulator'         = 'Boot the Android emulator and wait for it'
  'run'              = 'Run on whatever device is already attached'
  'run-emulator'     = 'Boot the emulator, then run the app on it'
  'apk'              = 'Release APK'
  'aab'              = 'Release App Bundle, for Play'
  'clean'            = 'Remove build output'
}

function Show-Help {
  Write-Host ''
  Write-Host 'Schwa Notes tasks:' -ForegroundColor Green
  foreach ($name in $tasks.Keys) {
    Write-Host ('  {0,-18} {1}' -f $name, $tasks[$name])
  }
  Write-Host ''
  Write-Host 'Example: .\make.ps1 ci'
}

# Boots the AVD and blocks until Android reports it has finished booting.
# `flutter run` against a half-booted emulator fails in confusing ways.
function Start-Emulator {
  Write-Host "==> booting $Emulator" -ForegroundColor Cyan
  & $flutter emulators --launch $Emulator
  Write-Host 'Waiting for the emulator to finish booting...'
  & adb wait-for-device
  while ((& adb shell getprop sys.boot_completed 2>$null) -notmatch '1') {
    Start-Sleep -Seconds 2
  }
  Write-Host 'Emulator ready.' -ForegroundColor Green
}

switch ($Task) {
  'help' { Show-Help }

  'setup' {
    Invoke-InApp $flutter @('pub', 'get')
    Invoke-InApp $dart @('run', 'build_runner', 'build')
    Invoke-InApp $flutter @('gen-l10n')
  }
  # NOT --delete-conflicting-outputs: removed in build_runner 2.16.
  'gen'   { Invoke-InApp $dart @('run', 'build_runner', 'build') }
  'l10n'  { Invoke-InApp $flutter @('gen-l10n') }

  'fmt'       { Invoke-InApp $dart @('format', '.') }
  'fmt-check' {
    Invoke-InApp $dart @('format', '--output=none', '--set-exit-if-changed', '.')
  }
  'analyze' {
    Invoke-InApp $flutter @('analyze', '--fatal-infos', '--fatal-warnings')
  }
  'licences' {
    Invoke-InApp $dart @('run', 'tool/check_licences.dart')
  }
  'migration-safety' {
    Invoke-InApp $dart @('run', 'tool/check_migration_safety.dart')
  }

  'test'           { Invoke-InApp $flutter @('test') }
  'test-unit'      { Invoke-InApp $flutter @('test', 'test/unit') }
  'test-widget'    { Invoke-InApp $flutter @('test', 'test/widget') }
  'test-migration' { Invoke-InApp $flutter @('test', 'test/migration') }
  'test-arch'      { Invoke-InApp $flutter @('test', 'test/architecture') }

  'ci' {
    # CI's exact order: cheapest and most-likely-to-fail first, with the
    # blocking migration tests ahead of anything that takes minutes.
    #
    # Each step runs through Invoke-InApp, which throws on a non-zero exit, so
    # the first failure ends the run - `ci` can never print success over a
    # step that did not pass.
    Invoke-InApp $dart @('format', '--output=none', '--set-exit-if-changed', '.')
    Invoke-InApp $dart @('run', 'tool/check_licences.dart')
    Invoke-InApp $dart @('run', 'tool/check_migration_safety.dart')
    Invoke-InApp $flutter @('test', 'test/migration')
    Invoke-InApp $flutter @('analyze', '--fatal-infos', '--fatal-warnings')
    Invoke-InApp $flutter @('test')
    Write-Host 'All checks passed.' -ForegroundColor Green
  }

  'doctor'  { & $flutter doctor -v }
  'devices' { & $flutter devices }

  'emulator' { Start-Emulator }
  'run'      { Invoke-InApp $flutter @('run') }
  'run-emulator' {
    Start-Emulator
    Invoke-InApp $flutter @('run')
  }

  'apk'   { Invoke-InApp $flutter @('build', 'apk', '--release') }
  'aab'   { Invoke-InApp $flutter @('build', 'appbundle', '--release') }
  'clean' { Invoke-InApp $flutter @('clean') }

  default {
    Write-Host "Unknown task '$Task'." -ForegroundColor Red
    Show-Help
    exit 1
  }
}
