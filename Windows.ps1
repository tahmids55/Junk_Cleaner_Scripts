<#
.SYNOPSIS
    Interactive System Cleaner with a Modern UI.
.DESCRIPTION
    - Prompts user before closing browsers.
    - Calculates storage usage per app.
    - Safely removes unneeded cache files.
#>

# --- SETUP UI COLORS AND SIZE ---
$Host.UI.RawUI.WindowTitle = "System Cleanup Utility"
$ProgressPreference = 'SilentlyContinue'

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host " ===============================================================" -ForegroundColor Cyan
    Write-Host "               SYSTEM TEMPORARY FILE CLEANER                    " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host " ===============================================================" -ForegroundColor Cyan
    Write-Host "  This script will clean:" -ForegroundColor Gray
    Write-Host "   * Windows Temp Files (%temp%)" -ForegroundColor DarkGray
    Write-Host "   * Browser Caches (Chrome, Edge, Firefox)" -ForegroundColor DarkGray
    Write-Host "   * App Caches (Teams, Discord)" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-Line($Title, $Size, $Status, $Color) {
    # Formats the output into a nice table row
    $TitleString = $Title.PadRight(25)
    $SizeString = "$Size MB".PadLeft(10)
    Write-Host "  $TitleString | $SizeString | " -NoNewline -ForegroundColor Gray
    Write-Host "$Status" -ForegroundColor $Color
}

# --- 1. ASK FOR PERMISSION ---
Show-Header
Write-Host "  [!] WARNING: " -ForegroundColor Yellow -NoNewline
Write-Host "All open browsers (Chrome, Edge, Firefox) will be CLOSED." -ForegroundColor White
Write-Host ""
$UserChoice = Read-Host "  Do you want to proceed? (Y/N)"

if ($UserChoice -notmatch "^[Yy]$") {
    Write-Host ""
    Write-Host "  [X] Operation Cancelled by user." -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}

# --- 2. DEFINE TARGETS ---
# List of targets to clean. 
# Format: @{ Name="Display Name"; Path="PathToFolder"; Process="ProcessName" }
$Targets = @(
    @{ Name="System Temp";     Path="C:\Windows\Temp";                                     Process=$null },
    @{ Name="User Temp";       Path=$env:TEMP;                                             Process=$null },
    @{ Name="Google Chrome";   Path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"; Process="chrome" },
    @{ Name="Microsoft Edge";  Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"; Process="msedge" },
    @{ Name="Discord";         Path="$env:APPDATA\discord\Cache";                          Process="Discord" },
    @{ Name="Microsoft Teams"; Path="$env:APPDATA\Microsoft\Teams\Cache";                  Process="Teams" }
)

# Handle Firefox separately (Dynamic path)
$FFProfiles = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $FFProfiles) {
    Get-ChildItem $FFProfiles -Directory | ForEach-Object {
        $Targets += @{ Name="Firefox ($($_.Name))"; Path="$($_.FullName)\cache2"; Process="firefox" }
    }
}

# --- 3. EXECUTION PHASE ---
Write-Host ""
Write-Host "  Analyzing and Cleaning..." -ForegroundColor Cyan
Write-Host "  ---------------------------------------------------------------" -ForegroundColor DarkGray

$TotalCleaned = 0

foreach ($Target in $Targets) {
    $Name = $Target.Name
    $Path = $Target.Path
    $Proc = $Target.Process

    # 1. Check if path exists
    if (-not (Test-Path $Path)) {
        continue
    }

    # 2. Calculate Size Before
    $InitialBytes = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    $InitialMB = [math]::Round(($InitialBytes.Sum / 1MB), 2)

    if ($InitialMB -eq 0) {
        Show-Line $Name "0.00" "Clean" "Green"
        continue
    }

    # 3. Stop Process if requested
    if ($Proc) {
        $RunningProc = Get-Process $Proc -ErrorAction SilentlyContinue
        if ($RunningProc) {
            Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500
        }
    }

    # 4. Clean (Deletes files older than 24 hours for Temp, All for Cache)
    # Different logic for Temp vs Browser Cache
    if ($Name -like "*Temp*") {
        # Safe Mode: Keep files from last 24h
        $Limit = (Get-Date).AddDays(-1)
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt $Limit -and -not $_.PSIsContainer } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    } else {
        # Cache Mode: Delete everything
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    # 5. Calculate Size After
    $FinalBytes = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    $FinalMB = [math]::Round(($FinalBytes.Sum / 1MB), 2)
    
    $CleanedMB = [math]::Round(($InitialMB - $FinalMB), 2)
    $TotalCleaned += $CleanedMB

    # 6. Show Result
    Show-Line $Name $InitialMB "- $CleanedMB MB" "Green"
}

# --- 4. FOOTER SUMMARY ---
Write-Host "  ---------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  TOTAL SPACE RECLAIMED: " -NoNewline -ForegroundColor White
Write-Host "$([math]::Round($TotalCleaned, 2)) MB" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")