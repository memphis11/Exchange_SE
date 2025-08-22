#
#           Schritt 1.1: Vorbereitungen prüfen
#
#
#
#            geschrieben von Lars'i
#


Write-Host "`n--- Vorbereitung der Active Directory gestartet ---" -ForegroundColor Cyan

# Pfad zur Exchange Setup.exe (anpassen falls erforderlich)
$setupPath = Read-Host "Bitte den Pfad zur Exchange Setup.exe Datei eingeben"


# Prüfen ob Setup.exe existiert
if (Test-Path $setupPath) {
    Write-Host "Setup.exe gefunden unter: $setupPath" -ForegroundColor Green

    # AD-Schema erweitern
    Write-Host "`n--- Erweiterung des AD-Schemas ---" -ForegroundColor Yellow
    Start-Process -FilePath $setupPath -ArgumentList "/PrepareSchema", "/IAcceptExchangeServerLicenseTerms_diagnosticdataoff" -Wait

    # Domäne vorbereiten
    Write-Host "`n--- Vorbereitung der Domäne ---" -ForegroundColor Yellow
    Start-Process -FilePath $setupPath -ArgumentList "/PrepareAD", "/IAcceptExchangeServerLicenseTerms_diagnosticdataoff" -Wait

    Write-Host "`nActive Directory Vorbereitung abgeschlossen." -ForegroundColor Green
} else {
    Write-Host "Setup.exe wurde nicht gefunden unter: $setupPath" -ForegroundColor Red
    Write-Host "Bitte den Pfad zur Setup.exe prüfen und erneut ausführen." -ForegroundColor Red
}

Write-Host "`n--- Vorgang beendet ---" -ForegroundColor Cyan