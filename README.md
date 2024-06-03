# hyper-v-direct-ssh

## Project Overview

`hyper-v-direct-ssh` is a PowerShell module designed to manage Hyper-V virtual machines (VMs) and establish direct SSH connections to them. This module provides functions for starting and stopping VMs, retrieving VM information, and ensuring the script runs with administrator privileges.

## Features

- Ensure script runs with administrator privileges.
- Check and enable Hyper-V on the system.
- Verify PowerShell version is 7 or greater.
- Retrieve and manage VM names.
- Start and stop VMs.
- Retrieve VM IP addresses.
- Initiate SSH connections to VMs.
- Check VM heartbeat status.

## Usage

## Prerequisites

<details>
<summary>Verify Administrative Privileges</summary>

Ensure you have administrative privileges on your system. The script requires elevated permissions to manage Hyper-V and execute certain commands.

</details>

<details>
<summary>Enable Hyper-V</summary>

Make sure Hyper-V is enabled on your system. You can enable Hyper-V using the following steps:

1. Open PowerShell as an administrator.
2. Run the following command to enable Hyper-V:
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
   ```
3. Restart your system to apply the changes.

</details>

<details>
<summary>Install PowerShell 7 or Greater</summary>

The script requires PowerShell version 7 or greater. Follow these steps to install or update PowerShell:

1. Go to the [PowerShell GitHub releases page](https://github.com/PowerShell/PowerShell/releases).
2. Download the latest release for your operating system.
3. Follow the installation instructions provided on the release page.

</details>

<details>
<summary>Install SSH Client</summary>

Ensure that the SSH client is installed on your system. You can install the OpenSSH client by following these steps:

#### On Windows:

1. Open PowerShell as an administrator.
2. Run the following command:
   ```powershell
   Add-WindowsCapability -Online -Name OpenSSH.Client*
   ```

#### On macOS:

1. Open Terminal.
2. Run the following command to check if SSH is already installed:
   ```sh
   ssh -V
   ```
3. If SSH is not installed, use Homebrew to install it:
   ```sh
   brew install openssh
   ```

#### On Linux:

1. Open Terminal.
2. Run the following command:

   ```sh
   sudo apt-get install openssh-client
   ```

   or for RPM-based distributions:

   ```sh
   sudo yum install openssh-clients
   ```

</details>

<details>
<summary>Configure Network for VMs</summary>

Ensure that your VMs are configured to obtain an IP address and that they are accessible via SSH. Verify the network settings and connectivity before running the script.

</details>

<details>
<summary>Download the Script</summary>

Save the script as `VMManagement.ps1` on your local machine. Make sure the file path is accessible and note down the path for running the script.

</details>

<details>
<summary>Run the Script</summary>

1. Open PowerShell as an administrator.
2. Navigate to the directory where the `VMManagement.ps1` script is saved.
3. Run the script using the following command:
   ```powershell
   .\VMManagement.ps1
   ```

</details>


### Running the Script

To use the module, save the script as `VMManagement.ps1` and run it using PowerShell. Make sure you have the necessary administrative privileges and that Hyper-V is enabled on your system.

```powershell
.\VMManagement.ps1
```

### Functions

#### `Get-Run-AsAdministrator`

Ensures the script runs with administrator privileges.

**Parameters:**

- `ScriptPath`: The path to the script that needs to be run as administrator.

**Example:**

```powershell
Get-Run-AsAdministrator -ScriptPath "C:\Path\To\Script.ps1"
```

#### `Enable-HyperV`

Checks if Hyper-V is enabled on the system and enables it if not.

**Example:**

```powershell
Enable-HyperV
```

#### `Test-PwshVersion`

Checks if the current PowerShell version is 7 or greater.

**Example:**

```powershell
Test-PwshVersion
```

#### `Get-VMList`

Retrieves a list of VM names.

**Example:**

```powershell
$vms = Get-VMList
```

#### `Get-VMName`

Prompts the user to select a VM from a list.

**Example:**

```powershell
$vmName = Get-VMName
```

#### `Get-UserName`

Prompts the user to enter a username for SSH.

**Example:**

```powershell
$username = Get-UserName
```

#### `Start-VMInstance`

Starts a specified VM.

**Parameters:**

- `vmName`: The name of the VM to start.

**Example:**

```powershell
$vm = Start-VMInstance -vmName "MyVM"
```

#### `Add-Dash`

Adds dashes to a string every two characters.

**Parameters:**

- `str`: The string to which dashes will be added.

**Example:**

```powershell
$dashedString = Add-Dash -str "A1B2C3D4"
```

#### `Get-VMIP`

Retrieves the IP address of a specified VM.

**Parameters:**

- `vmObject`: The VM object for which the IP address is to be retrieved.

**Example:**

```powershell
$ipAddress = Get-VMIP -vmObject $vm
```

#### `Stop-VMInstance`

Stops a specified VM.

**Parameters:**

- `vmName`: The name of the VM to stop.

**Example:**

```powershell
Stop-VMInstance -vmName "MyVM"
```

#### `Invoke-SSHConnection`

Initiates an SSH connection to a specified VM.

**Parameters:**

- `user`: The username for the SSH connection.
- `vmIP`: The IP address of the VM.

**Example:**

```powershell
Invoke-SSHConnection -user "username" -vmIP "192.168.1.100"
```

#### `Get-VMHeartbeat`

Checks the heartbeat status of a specified VM.

**Parameters:**

- `vmObject`: The VM object for which the heartbeat status is to be checked.

**Example:**

```powershell
$heartbeat = Get-VMHeartbeat -vmObject $vm
```

## Example Workflow

1. Ensure the script runs with administrator privileges.
2. Enable Hyper-V if it is not already enabled.
3. Check that the PowerShell version is 7 or greater.
4. Retrieve and display a list of VMs for the user to select from.
5. Start the selected VM.
6. Check the VM's heartbeat status.
7. Retrieve the VM's IP address.
8. Initiate an SSH connection to the VM.
9. Stop the VM after the SSH session ends.
