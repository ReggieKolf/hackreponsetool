# Define the IP address to test
$ipAddress = "192.168.1.1"  # Replace with the IP address you want to test

# Define the range of ports to scan
$startPort = 1
$endPort = 1024

# List of weak passwords for dictionary attack
$weakPasswords = @("password", "123456", "admin", "root", "letmein")

# Function to scan a single port
function Test-Port {
    param (
        [string]$ipAddress,
        [int]$port
    )

    $tcpClient = New-Object System.Net.Sockets.TcpClient
    try {
        $tcpClient.Connect($ipAddress, $port)
        $tcpClient.Close()
        return $true
    } catch {
        return $false
    }
}

# Function to check for outdated software (Example: Check for specific Windows service version)
function Check-OutdatedSoftware {
    param (
        [string]$service
    )

    $version = (Get-Service -Name $service).DisplayName -match "\d+.\d+.\d+.\d+" | Out-Null
    if ($version -lt "10.0.0.0") {
        return $true
    } else {
        return $false
    }
}

# Function to perform dictionary attack on a service (Example: RDP)
function Test-WeakPassword {
    param (
        [string]$ipAddress,
        [string]$username,
        [array]$passwords
    )

    foreach ($password in $passwords) {
        try {
            $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
            $session = New-PSSession -ComputerName $ipAddress -Credential $credential -ErrorAction Stop
            Remove-PSSession $session
            return $password
        } catch {
            continue
        }
    }
    return $null
}

# Perform the port scan
Write-Host "Scanning IP address $ipAddress for open ports..."
for ($port = $startPort; $port -le $endPort; $port++) {
    if (Test-Port -ipAddress $ipAddress -port $port) {
        Write-Host "Port $port is open on $ipAddress"
    }
}

# Check for outdated software
Write-Host "Checking for outdated software on $ipAddress..."
$service = "wuauserv"  # Example service
if (Check-OutdatedSoftware -service $service) {
    Write-Host "$service is outdated on $ipAddress"
} else {
    Write-Host "$service is up-to-date on $ipAddress"
}

# Perform dictionary attack for weak passwords
Write-Host "Testing for weak passwords on $ipAddress..."
$username = "administrator"  # Example username
$weakPassword = Test-WeakPassword -ipAddress $ipAddress -username $username -passwords $weakPasswords
if ($weakPassword) {
    Write-Host "Weak password found for $username: $weakPassword"
} else {
    Write-Host "No weak passwords found for $username"
}

Write-Host "Vulnerability scan complete."
