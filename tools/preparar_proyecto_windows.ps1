# Preparador del proyecto para Windows PowerShell 5.1+
# No requiere permisos de administrador. No instala software del sistema.
$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-.git"
$ZipUrl = "https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/archive/refs/heads/main.zip"
$Target = Join-Path $env:USERPROFILE "Documents\titanes-del-pacifico"
$Parent = Split-Path $Target -Parent

Write-Host ""
Write-Host "=== PREPARADOR DEL PROYECTO ===" -ForegroundColor Cyan
Write-Host "Destino: $Target"
New-Item -ItemType Directory -Force -Path $Parent | Out-Null

if (Test-Path (Join-Path $Target ".git")) {
    Write-Host "Repositorio Git existente. Intentando actualizar..." -ForegroundColor Yellow
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        Write-Host "Git no esta disponible. Se conserva la copia local sin modificar." -ForegroundColor Yellow
    } else {
        Push-Location $Target
        try {
            git pull --ff-only
            if ($LASTEXITCODE -ne 0) {
                Write-Host "No se pudo actualizar automaticamente. No se forzaron cambios." -ForegroundColor Yellow
            }
        } finally { Pop-Location }
    }
}
elseif (Test-Path $Target) {
    Write-Host "Ya existe una carpeta en el destino y no parece un clon Git." -ForegroundColor Yellow
    Write-Host "Para proteger tus archivos, NO la sobrescribire."
    $Target = Join-Path $Parent ("titanes-del-pacifico-copia-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
    Write-Host "Se usara una carpeta nueva: $Target"
    $UseNewFolder = $true
} else {
    $UseNewFolder = $true
}

if ($UseNewFolder) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        Write-Host "Git encontrado. Clonando repositorio..." -ForegroundColor Cyan
        git clone $RepoUrl $Target
        if ($LASTEXITCODE -ne 0) { throw "Git clone fallo. Prueba el metodo Download ZIP de la guia." }
    } else {
        Write-Host "Git no encontrado. Descargando ZIP oficial de GitHub..." -ForegroundColor Cyan
        $tempZip = Join-Path $env:TEMP ("titanes-" + [guid]::NewGuid().ToString("N") + ".zip")
        $tempDir = Join-Path $env:TEMP ("titanes-" + [guid]::NewGuid().ToString("N"))
        try {
            Invoke-WebRequest -Uri $ZipUrl -OutFile $tempZip -UseBasicParsing
            Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
            $extracted = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
            if (-not $extracted) { throw "El ZIP no contiene la carpeta del proyecto." }
            Move-Item -Path $extracted.FullName -Destination $Target
        } finally {
            if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
            if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
        }
    }
}

$ProjectFile = Join-Path $Target "project.godot"
if (-not (Test-Path $ProjectFile)) {
    throw "No se encontro project.godot en $Target. Revisa la carpeta descargada."
}
Write-Host ""
Write-Host "Proyecto preparado correctamente: $Target" -ForegroundColor Green

$GodotCandidates = @()
$cmd = Get-Command godot -ErrorAction SilentlyContinue
if ($cmd) { $GodotCandidates += $cmd.Source }
$GodotCandidates += @(
    "C:\Godot43\Godot_v4.3-stable_win64.exe",
    "C:\Godot\Godot_v4.3-stable_win64.exe",
    (Join-Path $env:USERPROFILE "Downloads\Godot_v4.3-stable_win64.exe"),
    (Join-Path $env:USERPROFILE "Downloads\Godot_v4.3-stable_win64_console.exe")
)
$GodotExe = $GodotCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if ($GodotExe) {
    Write-Host "Godot detectado: $GodotExe" -ForegroundColor Green
    $answer = Read-Host "Quieres abrir el proyecto ahora? (S/N)"
    if ($answer -match "^(S|s|SI|si)$") {
        Start-Process -FilePath $GodotExe -ArgumentList @("--editor", "--path", $Target)
    }
} else {
    Write-Host "Godot 4.3 aun no esta instalado o no se encontro." -ForegroundColor Yellow
    Write-Host "Descarga Godot 4.3 Standard para Windows x86_64:"
    Write-Host "https://godotengine.org/download/archive/4.3-stable/"
    Write-Host "Extrae el ejecutable en C:\Godot43\ y vuelve a ejecutar este script."
}
Write-Host ""
Write-Host "No se ha generado una APK ni se ha modificado la configuracion de Windows."
