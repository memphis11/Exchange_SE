#
#           Schritt 1.0: Voraussetzungen
#
#
#
#            geschrieben von Lars'i
#


Write-Host "`n--- System wird geprueft - gestartet ---" -ForegroundColor Cyan

# 1. Betriebssystemversion prüfen
$osVersion = (Get-CimInstance Win32_OperatingSystem).Caption
if ($osVersion -match "Windows Server 2016") {
    Write-Host "Windows Server 2016 erkannt" -ForegroundColor Green
} elseif ($osVersion -match "Windows Server 2019") {
    Write-Host "Windows Server 2019 erkannt" -ForegroundColor Green
} else {
    Write-Host "Nicht unterstütztes Betriebssystem: $osVersion" -ForegroundColor Red
}

# 2. Domänenmitgliedschaft prüfen
$domainInfo = Get-WmiObject Win32_ComputerSystem
if ($domainInfo.PartOfDomain) {
    Write-Host "Server ist Mitglied der Domäne: $($domainInfo.Domain)" -ForegroundColor Green
} else {
    Write-Host "Server ist nicht Mitglied einer Domäne" -ForegroundColor Red
}

# 3. Forest Functional Level prüfen
try {
    Import-Module ActiveDirectory
    $forest = Get-ADForest
    $level = $forest.ForestMode
    if ($level -ge "Windows2012R2Forest") {
        Write-Host "Forest Functional Level ist mindestens 2012 R2 ($level)" -ForegroundColor Green
    } else {
        Write-Host "Forest Functional Level ist zu niedrig: $level" -ForegroundColor Red
    }
} catch {
    Write-Host "Active Directory-Modul konnte nicht geladen werden oder keine Berechtigung" -ForegroundColor Red
}

# 4. .NET Framework 4.8 prüfen
try {
    $regKey = Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full' -ErrorAction Stop
    $release = $regKey.Release
    if ($release -ge 528040) {
        Write-Host ".NET Framework 4.8 oder höher ist installiert (Release: $release)" -ForegroundColor Green
    } else {
        Write-Host ".NET Framework 4.8 ist nicht installiert (Release: $release)" -ForegroundColor Red
    }
} catch {
    Write-Host ".NET Framework 4.8 konnte nicht geprüft werden" -ForegroundColor Red
}

Write-Host "`n--- Systemprüfung abgeschlossen ---" -ForegroundColor Cyan
