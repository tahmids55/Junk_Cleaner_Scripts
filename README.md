# Junk Directory Scripts

This directory contains two scripts for different operating systems to help automate tasks or run commands specific to your environment.

## Scripts

- **Linux.sh**: Bash script for Linux systems.
- **Windows.ps1**: PowerShell script for Windows systems.

## Usage

### On Linux
1. Open a terminal.
2. Navigate to this directory:
   ```bash
   cd /path/to/this/directory
   ```
3. Make the script executable (if not already):
   ```bash
   chmod +x Linux.sh
   ```
4. Run the script:
   ```bash
   ./Linux.sh
   ```

### On Windows
1. Open PowerShell.
2. Navigate to this directory:
   ```powershell
   cd 'C:\path\to\this\directory'
   ```
3. Run the script:
   ```powershell
   .\Windows.ps1
   ```
   If you encounter an execution policy error, you may need to allow script execution:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

## Notes
- Ensure you have the necessary permissions to execute scripts on your system.
- Review the script contents before running for security and customization.
