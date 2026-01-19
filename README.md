# Junk Directory Scripts

This directory contains two scripts for different operating systems to help automate tasks or run commands specific to your environment.

## Scripts

### Linux.sh (Linux)
This Bash script performs a comprehensive system cleanup on Linux systems. It:
- Requires root privileges (run with sudo).
- Cleans APT cache (autoremove, autoclean, clean).
- Removes old systemd journal logs (older than 2 days).
- Deletes thumbnail cache for all users.
- Empties user and root trash bins.
- Deletes temporary files in /tmp older than 1 day.
- Clears browser caches (Google Chrome, Chromium, Firefox, Edge, Brave, Mozilla) for all users.
- Cleans VS Code cache and logs for all users.
- Summarizes and displays the total disk space recovered per category.

### Windows.ps1 (Windows)
This PowerShell script provides an interactive, user-friendly system cleaner for Windows. It:
- Prompts the user before closing browsers (Chrome, Edge, Firefox).
- Calculates and displays storage usage per app/cache before cleaning.
- Cleans the following:
   - Windows Temp folder (C:\Windows\Temp)
   - User Temp folder (%TEMP%)
   - Browser caches (Chrome, Edge, Firefox; closes browsers if running)
   - App caches (Discord, Microsoft Teams)
- For Temp folders, only deletes files older than 24 hours (safe mode).
- For caches, deletes all files.
- Shows a summary of space reclaimed for each category and the total.
- Uses a modern UI with colored output and prompts.

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
