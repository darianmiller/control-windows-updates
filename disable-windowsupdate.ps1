# disable-windowsupdate.ps1 
# https://github.com/darianmiller/control-windows-updates

Write-Host ""
Write-Host "Applying Windows Update policy restrictions via registry..." -ForegroundColor Cyan

$policyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Create key if it doesn't exist
if (-not (Test-Path $policyKey)) {
    New-Item -Path $policyKey -Force | Out-Null
}

# Set required policy values
Set-ItemProperty -Path $policyKey -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord
Set-ItemProperty -Path $policyKey -Name "NoAutoUpdate" -Value 1 -Type DWord
Set-ItemProperty -Path $policyKey -Name "AUOptions" -Value 2 -Type DWord
Set-ItemProperty -Path $policyKey -Name "ScheduledInstallEveryWeek" -Value 0 -Type DWord

Write-Host "Policy keys written under: $policyKey" -ForegroundColor Green


Write-Host "Disabling Windows Update services..." -ForegroundColor Cyan

$services = @(
    @{ Name = "WaaSMedicSvc"; Desc = "Windows Update Medic Service" },
    @{ Name = "wuauserv";     Desc = "Windows Update Service" },
    @{ Name = "UsoSvc";       Desc = "Update Orchestrator Service" }
)

foreach ($svc in $services) {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
    try {
        Set-ItemProperty -Path $path -Name "Start" -Value 4 -Force
        Write-Host "Disabled $($svc.Desc) ($($svc.Name))" -ForegroundColor Green
    } catch {
        Write-Host "Failed to disable $($svc.Desc). Run as Administrator." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

Write-Host ""
Write-Host "Adding firewall rules to block known Microsoft Update IP ranges..." -ForegroundColor Cyan

$ruleNamePrefix = "DM-ControlUpdates-Block-WindowsUpdateIP"
$knownRanges = @(
    "13.107.4.0/24",
    "13.107.8.0/24",
    "13.107.64.0/18",
    "20.190.128.0/18",
    "40.76.0.0/14",
    "40.92.0.0/15",
    "40.96.0.0/13",
    "40.104.0.0/15",
    "40.108.128.0/17",
    "52.96.0.0/14",
    "52.100.0.0/14",
    "52.104.0.0/14",
    "52.108.0.0/15",
    "52.112.0.0/14",
    "52.120.0.0/14"
)

foreach ($subnet in $knownRanges) {
    $ruleName = "$ruleNamePrefix-$subnet"
    try {
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Outbound `
            -Action Block `
            -RemoteAddress $subnet `
            -Description "Block Microsoft Update IP range $subnet" `
            -Protocol Any `
            -Profile Any `
            -Enabled True

        Write-Host "Rule added for subnet: $subnet" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add rule for subnet: $subnet" -ForegroundColor Red
    }
}


Write-Host ""
Write-Host "Done. Services disabled and firewall rules added by IP." -ForegroundColor Cyan

Write-Host ""
Write-Host "Script complete. Closing in 5 seconds...(or hit a key to end delay)" -ForegroundColor Cyan
for ($i = 0; $i -lt 50; $i++) {
    if ([System.Console]::KeyAvailable) {
        $null = [System.Console]::ReadKey($true)
        break
    }
    Start-Sleep -Milliseconds 100
}