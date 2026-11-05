param(
  [string]$OutputPath = "build\windows\ktech_project_004-windows-x64.zip"
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$bundlePath = Join-Path $repositoryRoot 'build\windows\x64\runner\Release'
$requiredPlugins = @(
  'flutter_windows.dll',
  'pdfium.dll',
  'screen_retriever_plugin.dll',
  'window_manager_plugin.dll',
  'printing_plugin.dll',
  'url_launcher_windows_plugin.dll'
)

Push-Location $repositoryRoot
try {
  flutter pub get
  if ($LASTEXITCODE -ne 0) {
    throw 'flutter pub get failed.'
  }

  flutter build windows --release
  if ($LASTEXITCODE -ne 0) {
    throw 'flutter build windows --release failed.'
  }

  if (-not (Test-Path (Join-Path $bundlePath 'ktech_project_004.exe'))) {
    throw "Windows release executable not found in '$bundlePath'."
  }

  $missingPlugins = @(
    $requiredPlugins | Where-Object {
      -not (Test-Path (Join-Path $bundlePath $_))
    }
  )
  if ($missingPlugins.Count -gt 0) {
    throw "Windows bundle is missing plugin DLLs: $($missingPlugins -join ', '). Do not distribute the executable by itself."
  }
  if (-not (Test-Path (Join-Path $bundlePath 'data\flutter_assets'))) {
    throw "Flutter app assets not found in '$bundlePath\data\flutter_assets'."
  }

  if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $archivePath = $OutputPath
  } else {
    $archivePath = Join-Path $repositoryRoot $OutputPath
  }
  $archiveDirectory = Split-Path -Parent $archivePath
  New-Item -ItemType Directory -Force -Path $archiveDirectory | Out-Null

  Compress-Archive `
    -Path (Join-Path $bundlePath '*') `
    -DestinationPath $archivePath `
    -CompressionLevel Optimal `
    -Force

  Write-Host "Packaged complete Windows app bundle: $archivePath"
} finally {
  Pop-Location
}