# control-windows-updates

A simple Batch script and two PowerShell scripts that provides more control over **Windows Update behavior** on Windows 10 and Windows 11 machines.

![control updates graphic](bin/control-windows-updates.png)

## Features

- Disable or re-enable all core Windows Update services:
  - Windows Update (`wuauserv`)
  - Update Orchestrator (`UsoSvc`)
  - Windows Update Medic Service (`WaaSMedicSvc`)
- Add or remove firewall rules blocking known Microsoft update IP ranges
- Apply or remove registry settings to prevent auto-updates


## Included Files

| File | Description |
|------|-------------|
| `setupdates.bat` | Launch script. Takes one argument: `enable` or `disable`. The script automatically elevates to admin if needed. |
| `disable-windowsupdate.ps1` | Disables services, applies update-blocking firewall and registry rules |
| `enable-windowsupdate.ps1` | Re-enables services and removes all blocking rules |

---

## Usage

### Disable Windows Update:
```cmd
setupdates.bat disable
````

### Enable Windows Update:
```cmd
setupdates.bat enable
````

Note: No external dependencies / script-only solution