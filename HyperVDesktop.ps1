<#
Open PowerShell als Administrator:

Klik met de rechtermuisknop op het Start-menu en selecteer "Windows PowerShell (Admin)" of "PowerShell (Administrator)".
Voer het script uit:

Kopieer en plak het script in de PowerShell-console of sla het op in een .ps1-bestand en voer het bestand uit.
Herstart de computer:

Het script zal de computer opnieuw opstarten nadat Hyper-V is geïnstalleerd.
Zorg ervoor dat u uw werk opslaat voordat u het script uitvoert.


#>


# Functie om Hyper-V te installeren
function Install-HyperV {
    # Controleer of Hyper-V al is geïnstalleerd
    $hypervInstalled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

    if ($hypervInstalled.State -eq "Enabled") {
        Write-Host "Hyper-V is al geïnstalleerd."
    } else {
        # Installeer Hyper-V
        Write-Host "Hyper-V wordt geïnstalleerd..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart

        # Herstart de computer om de installatie te voltooien
        Write-Host "Herstart de computer om de installatie van Hyper-V te voltooien."
        Restart-Computer -Force
    }
}

# Controleer of het script wordt uitgevoerd met administratieve rechten
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Dit script moet worden uitgevoerd met administratieve rechten."
    exit
}

# Installeer Hyper-V
Install-HyperV
