$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Godot = Get-Command godot -ErrorAction SilentlyContinue
if (-not $Godot) {
    $Godot = Get-Command godot4 -ErrorAction SilentlyContinue
}
if (-not $Godot) {
    throw "No se encontro Godot 4 en PATH. Instala Godot 4.3 o posterior."
}

$ExportPreset = "Android"
$OutputDirectory = Join-Path $ProjectRoot "build/android"
$OutputApk = Join-Path $OutputDirectory "TitanesDelPacifico-debug.apk"
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

Write-Host "Validando e importando el proyecto..."
& $Godot.Source --headless --editor --path $ProjectRoot --quit
if ($LASTEXITCODE -ne 0) {
    throw "Godot no pudo importar el proyecto. Revisa los errores anteriores."
}

Write-Host "Exportando APK Android de depuracion (ARMv7 + ARM64)..."
& $Godot.Source --headless --path $ProjectRoot --export-debug $ExportPreset $OutputApk
if ($LASTEXITCODE -ne 0) {
    throw "La exportacion fallo. Comprueba las plantillas de exportacion y Android SDK/JDK."
}

if (-not (Test-Path $OutputApk)) {
    throw "Godot termino sin error, pero no se encontro el APK esperado: $OutputApk"
}
Write-Host "APK creado: $OutputApk" -ForegroundColor Green
