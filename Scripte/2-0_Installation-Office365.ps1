#
#           Schritt 2.0: Installation Office365
#
#
#
#               geschrieben von Lars'i
#


# Variablen
$odtUrl = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19029-20136.exe"
$odtInstaller = "$env:TEMP\OfficeDeploymentTool.exe"
$odtExtractPath = "$env:TEMP\ODT"
$configXmlPath = "$odtExtractPath\configuration.xml"

# Funktion: Office Deployment Tool herunterladen und entpacken
function Download-ODT {
    Write-Host "Lade Office Deployment Tool herunter..."
    Invoke-WebRequest -Uri $odtUrl -OutFile $odtInstaller
    Write-Host "Entpacke Office Deployment Tool..."
    Start-Process -FilePath $odtInstaller -ArgumentList "/quiet /extract:$odtExtractPath" -Wait
}

# Funktion: Konfigurationsdatei erstellen
function Create-ConfigurationXml {
    Write-Host "Erstelle configuration.xml..."
    $xmlContent = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="de-de" />
    </Product>
  </Add>
  <RemoveMSI />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
    $xmlContent | Out-File -FilePath $configXmlPath -Encoding UTF8
}

# Funktion: Alte Office-Versionen deinstallieren
function Uninstall-OldOffice {
    Write-Host "Suche nach alten Office-Versionen..."
    $officeProducts = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Microsoft Office%'" | Where-Object {
        $_.Name -notlike "*365*" -and $_.Name -notlike "*Click-to-Run*"
    }

    foreach ($product in $officeProducts) {
        Write-Host "Deinstalliere: $($product.Name)"
        $product.Uninstall()
    }
}

# Funktion: Office 365 installieren
function Install-Office365 {
    Write-Host "Starte Installation von Office 365..."
    Start-Process -FilePath "$odtExtractPath\setup.exe" -ArgumentList "/configure $configXmlPath" -Wait
    Write-Host "Installation abgeschlossen."
}

# Hauptablauf
Download-ODT
Create-ConfigurationXml
Uninstall-OldOffice
Install-Office365


