param(
    [string[]]$Targets = @("Android", "Web", "Windows Desktop", "Linux")
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Godot = Get-Command godot -ErrorAction SilentlyContinue
if (-not $Godot) { $Godot = Get-Command godot4 -ErrorAction SilentlyContinue }
if (-not $Godot) { throw "No se encontro Godot 4 en PATH." }

$Outputs = @{
    "Android" = "build/android/TitanesDelPacifico-debug.apk"
    "Web" = "build/web/index.html"
    "Windows Desktop" = "build/windows/TitanesDelPacifico.exe"
    "Linux" = "build/linux/TitanesDelPacifico.x86_64"
}

& $Godot.Source --headless --editor --path $ProjectRoot --quit
if ($LASTEXITCODE -ne 0) { throw "La importacion del proyecto fallo." }

foreach ($Target in $Targets) {
    if (-not $Outputs.ContainsKey($Target)) {
        Write-Warning "Destino no reconocido: $Target. Se omite."
        continue
    }
    $RelativeOutput = $Outputs[$Target]
    $AbsoluteOutput = Join-Path $ProjectRoot $RelativeOutput
    $OutputFolder = Split-Path -Parent $AbsoluteOutput
    New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
    Write-Host "Exportando $Target -> $RelativeOutput"
    & $Godot.Source --headless --path $ProjectRoot --export-debug $Target $AbsoluteOutput
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la exportacion de $Target. Revisa las plantillas y SDK correspondientes."
    }
    if (-not (Test-Path $AbsoluteOutput)) {
        throw "No se encontro el archivo exportado: $AbsoluteOutput"
    }
}
Write-Host "Exportaciones solicitadas terminadas." -ForegroundColor Green
