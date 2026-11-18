# Diagnostico no invasivo para preparar Godot en Windows 11
# Ejecutar en PowerShell normal. Solo consulta informacion del equipo.
$ErrorActionPreference = "Stop"
Write-Host "=== DIAGNOSTICO PC PARA GODOT ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$drive = Get-PSDrive -Name C
$freeDiskGB = [math]::Round($drive.Free / 1GB, 1)
Write-Host "Sistema: $($os.Caption) $($os.OSArchitecture)"
Write-Host "Procesador: $($cpu.Name)"
Write-Host "RAM total aprox.: $ramGB GB"
Write-Host "RAM disponible ahora: $freeRamGB GB"
Write-Host "Espacio libre en C: $freeDiskGB GB"
if ($ramGB -lt 4) { Write-Host "Aviso: poca RAM para editor nativo; cierra apps y usa escenas simples." -ForegroundColor Yellow }
elseif ($ramGB -lt 8) { Write-Host "RAM basica: cierra apps y considera Compatibility renderer." -ForegroundColor Yellow }
else { Write-Host "RAM: nivel adecuado para empezar; rendimiento tambien depende CPU/GPU." -ForegroundColor Green }
if ($freeDiskGB -lt 5) { Write-Host "Aviso: libera espacio antes de descargar." -ForegroundColor Yellow }
Write-Host "Solo lectura: no instala, cambia ni elimina nada." -ForegroundColor Gray
