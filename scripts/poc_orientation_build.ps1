# Construit l'app de démo du POC « Explorer les métiers » et l'installe sur l'émulateur.
# Les accès France Travail (recette) sont lus dans la configuration locale de l'API, passés au build par un
# fichier temporaire supprimé aussitôt, et ne sont jamais écrits dans ce dépôt.
# L'APK obtenu contient ces accès : il ne doit pas quitter l'émulateur de ce PC.
param([switch]$SansInstallation)

$ErrorActionPreference = 'Stop'
$app = Split-Path $PSScriptRoot -Parent
$environnementApi = Join-Path (Split-Path $app -Parent) 'pass-emploi-api\.environment'
$flutter = Join-Path $env:USERPROFILE 'dev\flutter\bin\flutter.bat'
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'

$variables = @{}
foreach ($ligne in Get-Content $environnementApi) {
  if ($ligne -match '^\s*(POLE_EMPLOI_[A-Z_]+)\s*=\s*(.*)$') {
    $variables[$Matches[1]] = $Matches[2].Trim().Trim('"').Trim("'")
  }
}
$defines = [ordered]@{
  POC_FT_CLIENT_ID     = $variables['POLE_EMPLOI_CLIENT_ID']
  POC_FT_CLIENT_SECRET = $variables['POLE_EMPLOI_CLIENT_SECRET']
  POC_FT_LOGIN_URL     = $variables['POLE_EMPLOI_LOGIN_URL']
  POC_FT_API_BASE_URL  = $variables['POLE_EMPLOI_API_BASE_URL']
}
foreach ($nom in $defines.Keys) {
  if ([string]::IsNullOrWhiteSpace($defines[$nom])) { throw "Accès France Travail introuvable ($nom) dans $environnementApi" }
}

$fichier = Join-Path ([IO.Path]::GetTempPath()) ('poc-orientation-' + [guid]::NewGuid() + '.json')
Push-Location $app
try {
  [IO.File]::WriteAllText($fichier, ($defines | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
  & $flutter build apk --debug --flavor cejStaging -t lib/cej_main.dart --target-platform android-x64 "--dart-define-from-file=$fichier"
  if ($LASTEXITCODE -ne 0) { throw 'La construction de l''app a échoué.' }
} finally {
  Remove-Item -Path $fichier -Force -ErrorAction SilentlyContinue
  Pop-Location
}

if (-not $SansInstallation) {
  & $adb install -r (Join-Path $app 'build\app\outputs\flutter-apk\app-cejstaging-debug.apk')
}
