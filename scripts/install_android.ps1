param(
    [string]$ApkPath = "build/android/TitanesDelPacifico-debug.apk"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$AbsoluteApk = Join-Path $ProjectRoot $ApkPath
if (-not (Test-Path $AbsoluteApk)) {
    throw "No existe el APK: $AbsoluteApk. Ejecuta primero .\scripts\build_android.ps1"
}

$Adb = Get-Command adb -ErrorAction SilentlyContinue
if (-not $Adb) { throw "No se encontro adb. Instala Android SDK Platform-Tools y configura PATH." }

$Devices = & $Adb.Source devices
if ($LASTEXITCODE -ne 0) { throw "No se pudo consultar adb." }
$ReadyDevices = @($Devices | Where-Object { $_ -match "\tdevice$" })
if ($ReadyDevices.Count -eq 0) {
    throw "No hay un dispositivo autorizado. Conecta el dispositivo, activa depuracion USB y acepta el dialogo de autorizacion."
}

& $Adb.Source install -r $AbsoluteApk
if ($LASTEXITCODE -ne 0) { throw "La instalacion fallo. Revisa el dispositivo y la firma de la app anterior." }
Write-Host "Instalacion completada en el dispositivo conectado." -ForegroundColor Green
