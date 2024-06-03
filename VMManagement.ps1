# Filename: VMManagement.ps1

<#
.SYNOPSIS
    PowerShell module for managing VMs with Hyper-V.

.DESCRIPTION
    This module provides functions to manage VMs, including starting and stopping VMs,
    retrieving VM information, and initiating SSH connections to VMs.

.AUTHOR
    Your Name
#>


# Include the Run-AsAdministrator function
function Get-Run-AsAdministrator {
    <#
    .SYNOPSIS
        Ensures the script runs with administrator privileges.

    .DESCRIPTION
        This function checks if the current PowerShell session is running with administrator privileges.
        If not, it restarts the script with administrator privileges.

    .PARAMETER ScriptPath
        The path to the script that needs to be run as administrator.

    .EXAMPLE
        Run-AsAdministrator -ScriptPath "C:\Path\To\Script.ps1"
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    # Check if the current user has administrator privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Restarting script with administrator privileges..."
        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs
        exit
    }
    else {
        Write-Host "Script is running with administrator privileges."
    }
}

function Enable-HyperV {
    <#
    .SYNOPSIS
        Checks if Hyper-V is enabled on the system and enables it if not.
    
    .DESCRIPTION
        This function checks if Hyper-V is enabled on the current system. If Hyper-V is not enabled,
        it enables the feature. It requires administrative privileges to enable Hyper-V.
    
    .EXAMPLE
        Enable-HyperV
    #>
    
        # Check if Hyper-V is already enabled
        $hyperVStatus = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
        if ($hyperVStatus.State -eq "Enabled") {
            Write-Host "Hyper-V is already enabled."
        }
        else {
            # Enable Hyper-V feature
            Write-Host "Hyper-V is not enabled. Enabling now..."
            Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online -NoRestart
            Write-Host "Hyper-V has been enabled."
            Write-Host "Please restart your system to apply the changes and re-run this script."
            exit
        }
    }
    

# Function to check if PowerShell version is 7 or greater
function Test-PwshVersion {
    <#
  .SYNOPSIS
      Checks if the current PowerShell version is 7 or greater.

  .DESCRIPTION
      This function checks the current PowerShell version and exits if it is less than 7.

  .EXAMPLE
      Test-PwshVersion
  #>

    $url = "https://github.com/PowerShell/PowerShell"
    if ($Host.Version.Major -lt 7) {
        Write-Host "This script requires PowerShell v7+`nPlease install from: $url"
        exit
    }
}

# Function to get a list of VM names
function Get-VMList {
    <#
  .SYNOPSIS
      Retrieves a list of VM names.

  .DESCRIPTION
      This function gets the names of all VMs managed by Hyper-V.

  .EXAMPLE
      $vms = Get-VMList
  #>

    $vmobj = Get-VM
    $vmlist = $vmobj.VMName.Split("`n")
    return $vmlist
}

# Function to get the name of a VM from the user
function Get-VMName {
    <#
  .SYNOPSIS
      Prompts the user to select a VM from a list.

  .DESCRIPTION
      This function displays a list of VMs and prompts the user to select one by entering a corresponding number.

  .EXAMPLE
      $vmName = Get-VMName
  #>

    $vmlist = Get-VMList
    if ($vmlist.Length -ne 0) {
        Write-Host "Please enter the number corresponding to the VM name from the list below:`n"
        $vmlistType = $vmlist.GetType().ToString()
        if ($vmlistType -eq "System.String") {
            $vmlist = @($vmlist)
        }
        for ($i = 0; $i -lt $vmlist.Count; $i++) {
            Write-Host "`t$($i + 1) - $($vmlist[$i])" -ForegroundColor Cyan
        }

        $VM_Number = Read-Host -Prompt "Number"
        if ($VM_Number -gt 0 -and $VM_Number -le $vmlist.Length) {
            return $vmlist[$VM_Number - 1].ToString()
        }
        else {
            Write-Host "Invalid number entered. Please try again." -ForegroundColor Red
            return Get-VMName
        }
    }
    else {
        Write-Host "Please first create a VM in Hyper-V Manager" -ForegroundColor Red
        exit
    }
}

# Function to get the username for SSH from the user
function Get-UserName {
    <#
  .SYNOPSIS
      Prompts the user to enter a username for SSH.

  .DESCRIPTION
      This function prompts the user to enter a username for SSH and validates the input.

  .EXAMPLE
      $username = Get-UserName
  #>

    Write-Host "Please enter the username for SSH:`n"
    $user = Read-Host -Prompt "Username"
    if ($user.Length -eq 0) {
        Write-Host "Invalid username entered. Please try again." -ForegroundColor Red
        return Get-UserName
    }
    return $user.ToString()
}

# Function to start a VM
function Start-VMInstance {
    <#
  .SYNOPSIS
      Starts a specified VM.

  .DESCRIPTION
      This function starts the specified VM and returns the VM object.

  .PARAMETER vmName
      The name of the VM to start.

  .EXAMPLE
      $vm = Start-VMInstance -vmName "MyVM"
  #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$vmName
    )

    try {
        Start-VM -Name $vmName -ErrorAction Stop
        $uvm = Get-VM -VMName $vmName
        return $uvm
    }
    catch {
        Write-Error "Something went wrong...`n"
        Write-Error $_
        return $null
    }
}

# Function to add dashes to a string every two characters
function Add-Dash {
    <#
  .SYNOPSIS
      Adds dashes to a string every two characters.

  .DESCRIPTION
      This function splits a string every two characters and joins the parts with dashes.

  .PARAMETER str
      The string to which dashes will be added.

  .EXAMPLE
      $dashedString = Add-Dash -str "A1B2C3D4"
  #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$str
    )

    $splitStr = $str -split '(.{2})' | Where-Object { $_ }
    $newStr = $splitStr -join '-'
    $strLen = $newStr.LastIndexOf("-")
    $newStr = $newStr.Substring(0, $strLen)
    return $newStr.ToLower()
}

# Function to get the IP address of a VM
function Get-VMIP {
    <#
  .SYNOPSIS
      Retrieves the IP address of a specified VM.

  .DESCRIPTION
      This function gets the IP address of a VM by searching the ARP table for the VM's MAC address.

  .PARAMETER vmObject
      The VM object for which the IP address is to be retrieved.

  .EXAMPLE
      $ipAddress = Get-VMIP -vmObject $vm
  #>

    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$vmObject
    )

    $vmNetMac = Out-String -InputObject $vmObject.NetworkAdapters.MacAddress
    $temp = Add-Dash -str $vmNetMac
    $arpRes = arp -a
    $search = $arpRes | Select-String $temp
    $ipAddr = $search.ToString().Trim().Split()[0]
    return $ipAddr
}

# Function to stop a VM
function Stop-VMInstance {
    <#
  .SYNOPSIS
      Stops a specified VM.

  .DESCRIPTION
      This function stops the specified VM after prompting the user for confirmation.

  .PARAMETER vmName
      The name of the VM to stop.

  .EXAMPLE
      Stop-VMInstance -vmName "MyVM"
  #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$vmName
    )

    Write-Host "`nDo you want to terminate $vmName?"
    Write-Host "yes [y]" -ForegroundColor Red -NoNewline
    Write-Host ", No [n], default [n]`n" -ForegroundColor Green
    $userChoice = Read-Host -Prompt "Choice"
    if ($userChoice -eq "y") {
        Stop-VM -Name $vmName -TurnOff
        Write-Output "$vmName terminated."
    }
}

# Function to initiate an SSH connection to a VM
function Invoke-SSHConnection {
    <#
  .SYNOPSIS
      Initiates an SSH connection to a specified VM.

  .DESCRIPTION
      This function initiates an SSH connection to a VM using the specified username and VM IP address.

  .PARAMETER user
      The username for the SSH connection.

  .PARAMETER vmIP
      The IP address of the VM.

  .EXAMPLE
      Invoke-SSHConnection -user "username" -vmIP "192.168.1.100"
  #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$user,
        [Parameter(Mandatory = $true)]
        [string]$vmIP
    )

    $sshAddr = "$user@$vmIP"
    Clear-Host
    ssh $sshAddr
}

# Function to check the heartbeat of a VM
function Get-VMHeartbeat {
    <#
  .SYNOPSIS
      Checks the heartbeat status of a specified VM.

  .DESCRIPTION
      This function checks the heartbeat status of a VM for 100 seconds and returns true if the heartbeat is detected.

  .PARAMETER vmObject
      The VM object for which the heartbeat status is to be checked.

  .EXAMPLE
      $heartbeat = Get-VMHeartbeat -vmObject $vm
  #>

    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$vmObject
    )

    for ($i = 1; $i -lt 100; $i++) {
        if ($vmObject.Heartbeat -eq "OkApplicationsUnknown") {
            return $true
        }
        Start-Sleep -Seconds 1
    }
    return $false
}

# Main script execution
Get-Run-AsAdministrator -ScriptPath $PSCommandPath
Enable-HyperV
Test-PwshVersion
$vname = Get-VMName
$uvm = Start-VMInstance -vmName $vname

if ($null -ne $uvm) {
    Write-Output "Please wait..."
    if (Get-VMHeartbeat -vmObject $uvm) {
        Start-Sleep -Seconds 2
        $VMip = Get-VMIP -vmObject $uvm
        Write-Output "Loading..."
        while ($true) {
            if (Test-Connection -ComputerName $VMip -TcpPort 22) {
                $uname = Get-UserName
                Invoke-SSHConnection -user $uname -vmIP $VMip
                Stop-VMInstance -vmName $vname
                break
            }
            Start-Sleep -Seconds 1
        }
    }
    else {
        Write-Output "Failed to load OS"
    }
}
