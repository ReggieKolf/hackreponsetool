# Configuratie variabelen
$VMNetworkName = "TestLabNetwork"
$ExternalSwitchName = "ExternalSwitch"
$ProxyVMName = "ProxyServer"
$DCVMName = "DMC_01"
$FileServerVMName = "FL_02"
$DesktopVMName = "Desk1"
$ISOPath = "E:\image\WindowsServerISO.iso"
$VHDPath = "E:\Hyper-V\VHD\"

# Maak de externe virtuele switch aan
if (!(Get-VMSwitch -Name $ExternalSwitchName -ErrorAction SilentlyContinue)) {
    $netAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    if ($netAdapter) {
        New-VMSwitch -Name $ExternalSwitchName -NetAdapterName $netAdapter.Name -AllowManagementOS $true
    } else {
        Write-Host "Geen beschikbare netwerkadapter gevonden om een externe switch aan te maken."
        exit
    }
}

# Maak een intern virtueel netwerk voor het testlab
if (!(Get-VMSwitch -Name $VMNetworkName -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name $VMNetworkName -SwitchType Internal
}

# Functie om een VM aan te maken
function Create-VM {
    param (
        [string]$VMName,
        [string]$ISOPath,
        [string]$VHDPath,
        [string]$SwitchName
    )

    $VMFullPath = "$VHDPath$VMName.vhdx"
    New-VM -Name $VMName -MemoryStartupBytes 2GB -VHDPath $VMFullPath -SwitchName $SwitchName
    Set-VMDvdDrive -VMName $VMName -Path $ISOPath
    Resize-VHD -Path $VMFullPath -SizeBytes 60GB
    Start-VM -Name $VMName
}

# Maak de ProxyServer VM aan
Create-VM -VMName $ProxyVMName -ISOPath $ISOPath -VHDPath $VHDPath -SwitchName $VMNetworkName

# Maak de DomainController VM aan
Create-VM -VMName $DCVMName -ISOPath $ISOPath -VHDPath $VHDPath -SwitchName $VMNetworkName

# Maak de FileServer VM aan
Create-VM -VMName $FileServerVMName -ISOPath $ISOPath -VHDPath $VHDPath -SwitchName $VMNetworkName

# Maak de DesktopClient VM aan
Create-VM -VMName $DesktopVMName -ISOPath $ISOPath -VHDPath $VHDPath -SwitchName $VMNetworkName
