#
#           Schritt 1.2: Erstellung der APP
#
#
#
#            geschrieben von Lars'i
#


# Abfrage nach Tenant-Domain (z.b. contoso.onmicrosoft.com)
Write-Host "`n--- Erstellung der APP Registrierung ---" -ForegroundColor Cyan
$TenantDomain = Read-Host "Bitte den Tenant-Domainnamen eingeben (z.B. contoso.onmicrosoft.com)"

# Verbindung zu Microsoft Graph mit dem angegebenen Tenant
Connect-MgGraph -TenantId $TenantDomain -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

# Benutzerabfrage für App-Namen und Tenant-ID
$AppName = Read-Host "Bitte den Namen der Exchange SE App eingeben"
$TenantId = Read-Host "Bitte die Tenant-ID eingeben"

# App-Registrierung erstellen
$App = New-MgApplication -DisplayName $AppName -Web @{ RedirectUris = @("https://localhost") }
$SP = New-MgServicePrincipal -AppId $App.AppId

# Berechtigung für Exchange hinzufügen
$ExchangeResourceId = "00000002-0000-0ff1-ce00-000000000000"
$PermissionId = "dc50a0fb-168b-4c99-8f7e-0a1d22288f85"  # full_access_as_app
$AppPermission = @{
    ResourceAppId = $ExchangeResourceId
    ResourceAccess = @(@{ Id = $PermissionId; Type = "Role" })
}
Update-MgApplication -ApplicationId $App.Id -RequiredResourceAccess @($AppPermission)

# Abfrage zur Erstellung eines Client-Secrets
$SecretErstellen = Read-Host "Soll ein Client-Secret erstellt werden? (ja/nein)"
$Secret = $null
if ($SecretErstellen -eq "ja") {
    $Secret = Add-MgApplicationPassword -ApplicationId $App.Id -PasswordCredential @{ DisplayName = "ExchangeSE-Secret" }
}

# Admin-Konsent-Link ausgeben
Write-Host "`n--- Admin-Konsent erforderlich ---"
Write-Host "Bitte folgenden Link im Browser öffnen und die Berechtigungen bestätigen:"
Write-Host "https://login.microsoftonline.com/$TenantId/adminconsent?client_id=$($App.AppId)"

# Ausgabe der App-Registrierung
Write-Host "`n--- Ausgabe der APP Registrierung ---"
Write-Host "App-Registrierung erfolgreich abgeschlossen!"
Write-Host "App-Name: $AppName"
Write-Host "App-ID: $($App.AppId)"
Write-Host "Service Principal-ID: $($SP.Id)"
if ($Secret -ne $null) {
    Write-Host "Client-Secret: $($Secret.SecretText)"
}

# Hinweis zur Exchange SE Autorisierung
Write-Host "`n--- Exchange SE Autorisierung ---"
Write-Host "Führen Sie folgenden Befehl in Exchange SE aus, um die App zu autorisieren:"
Write-Host "New-ServicePrincipal -AppId $($App.AppId) -DisplayName '$AppName' -ServiceId $($SP.Id)"
