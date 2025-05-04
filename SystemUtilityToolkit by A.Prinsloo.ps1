# SystemUtilityToolkit by A.Prinsloo.ps1

# --- Authentication Block ---
function Authenticate-User {
    $correctPassword = "Password123"  # You can change this!
    $attempts = 5

    while ($attempts -gt 0) {
        $inputPassword = Read-Host "Enter the toolkit password" -AsSecureString
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputPassword)
        )

        if ($plainPassword -eq $correctPassword) {
            Write-Host "Authentication successful!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Incorrect password. Attempts left: $($attempts - 1)" -ForegroundColor Red
            $attempts--
        }
    }

    Write-Host "Authentication failed. Exiting script." -ForegroundColor Red
    exit
}

# --- Logger Function ---
function Write-Log {
    param (
        [string]$message
    )
    $logFile = "C:/Users/Austi/Powershell_Practice_Folder/ps1/SystemUtilityToolkit_Log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
}

# --- Backup Tool ---
function BackupTool {
    Write-Host "You chose Backup Tool." -ForegroundColor Cyan

    $sourceFolder = Read-Host "Enter the full path of the folder you want to back up"
    if (-not (Test-Path $sourceFolder)) {
        Write-Host "Error: Source folder does not exist." -ForegroundColor Red
        return
    }

    $destinationFolder = Read-Host "Enter the destination folder to save the backup"
    if (-not (Test-Path $destinationFolder)) {
        Write-Host "Destination does not exist. Creating it..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupFileName = "Backup_$timestamp.zip"
    $backupFilePath = Join-Path -Path $destinationFolder -ChildPath $backupFileName

    try {
        Compress-Archive -Path "$sourceFolder\*" -DestinationPath $backupFilePath -Force
        Write-Host "Backup created successfully at: $backupFilePath" -ForegroundColor Green
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Backup created from '$sourceFolder' to '$backupFilePath'"
        Add-Content -Path $logFile -Value $logEntry
    }
    catch {
        Write-Host "An error occurred during backup: $_" -ForegroundColor Red
    }
}

# --- Keyword Hunter ---
function KeywordHunter {
    param ([string]$keyword)
    
    Write-Host "Searching for the keyword '$keyword' in all files..."

    $files = Get-ChildItem -Path "C:/Users/Austi/Powershell_Practice_Folder/ps1" -Recurse -File

    if ($files.Count -eq 0) {
        Write-Host "No files found in the specified folder." -ForegroundColor Red
    } else {
        $files | ForEach-Object {
            if (Select-String -Path $_.FullName -Pattern $keyword -Quiet) {
                Write-Host "Keyword '$keyword' found in: $($_.FullName)" -ForegroundColor Green
            }
        }
    }
}

# --- File Organizer ---
function FileOrganizer {
    param ([string]$folderPath)
    
    Write-Host "Organizing files in folder: $folderPath"

    $files = Get-ChildItem -Path $folderPath -File
    foreach ($file in $files) {
        $extension = $file.Extension.TrimStart('.')
        $folder = "$folderPath\$extension"
        
        if (-not (Test-Path $folder)) {
            New-Item -Path $folder -ItemType Directory
            Write-Host "Created folder: $folder"
        }
        
        Move-Item -Path $file.FullName -Destination $folder
        Write-Host "Moved $($file.Name) to $folder"
    }
}

# --- List Scripts ---
function ListScripts {
    Write-Host "Listing all scripts in your practice folder..."

    $scripts = Get-ChildItem -Path "C:/Users/Austi/Powershell_Practice_Folder/ps1" -Filter *.ps1
    if ($scripts) {
        foreach ($script in $scripts) {
            Write-Host "Found script: $($script.Name)"
        }
    } else {
        Write-Host "No scripts found."
    }
}

# --- System Info ---
function Get-SystemInfo {
    Write-Host "Gathering system information..." -ForegroundColor Cyan

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)

    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet*" -ErrorAction SilentlyContinue |
            Where-Object {$_.IPAddress -ne "127.0.0.1"} |
            Select-Object -First 1).IPAddress

    if (-not $ip) {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" -ErrorAction SilentlyContinue |
                Where-Object {$_.IPAddress -ne "127.0.0.1"} |
                Select-Object -First 1).IPAddress
    }

    if (-not $ip) { $ip = "No IP Detected" }

    $mac = (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1).MacAddress

    try {
        $publicInfo = Invoke-RestMethod -Uri "https://ipinfo.io/json" -ErrorAction Stop
        $publicIP = $publicInfo.ip
    }
    catch {
        $publicIP = "Unavailable"
    }

    Write-Host "-----------------------------------" -ForegroundColor DarkGray
    Write-Host "Operating System: $($os.Caption)" -ForegroundColor Green
    Write-Host "CPU: $($cpu.Name)" -ForegroundColor Green
    Write-Host "RAM: $ramGB GB" -ForegroundColor Green
    Write-Host "IP Address (Local): $ip" -ForegroundColor Green
    Write-Host "MAC Address: $mac" -ForegroundColor Green
    Write-Host "Public IP Address: $publicIP" -ForegroundColor Green
    Write-Host "-----------------------------------" -ForegroundColor DarkGray
}

# --- New Features! ---

# Quick Notes Manager
function QuickNotes {
    $note = Read-Host "Enter your quick note"
    $notesFile = "C:/Users/Austi/Powershell_Practice_Folder/ps1/QuickNotes.txt"
    Add-Content -Path $notesFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $note"
    Write-Host "Note saved to QuickNotes.txt!" -ForegroundColor Green
}

# Process Killer
function Kill-Process {
    $processName = Read-Host "Enter the process name to kill"
    try {
        Get-Process -Name $processName | Stop-Process -Force
        Write-Host "Process '$processName' terminated successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to kill process. Make sure the name is correct." -ForegroundColor Red
    }
}

# Disk Cleanup Helper
function DiskCleanup {
    $tempFolder = "$env:Temp"
    Write-Host "Cleaning temporary files from $tempFolder..." -ForegroundColor Yellow

    try {
        Get-ChildItem -Path $tempFolder -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Temporary files deleted!" -ForegroundColor Green
    }
    catch {
        Write-Host "An error occurred during cleanup: $_" -ForegroundColor Red
    }
}

# Simple Port Scanner
function PortScanner {
    $host = Read-Host "Enter the IP address or hostname to scan"
    $ports = @(80, 443, 21, 22, 3389)

    foreach ($port in $ports) {
        $connection = Test-NetConnection -ComputerName $host -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "Port $port is OPEN on $host." -ForegroundColor Green
        } else {
            Write-Host "Port $port is CLOSED on $host." -ForegroundColor Red
        }
    }
}

# --- Main Script Start ---

Authenticate-User

# Welcome Menu
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   Welcome to the System Utility Toolkit" -ForegroundColor Green
Write-Host "                by A.Prinsloo" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please choose a tool to run:" -ForegroundColor Yellow
Write-Host "1. Keyword Hunter" -ForegroundColor Green
Write-Host "2. File Organizer" -ForegroundColor Green
Write-Host "3. List Scripts" -ForegroundColor Green
Write-Host "4. System Info" -ForegroundColor Green
Write-Host "5. Exit" -ForegroundColor Green
Write-Host "6. Backup Tool" -ForegroundColor Green
Write-Host "7. Quick Notes Manager" -ForegroundColor Green
Write-Host "8. Process Killer" -ForegroundColor Green
Write-Host "9. Disk Cleanup Helper" -ForegroundColor Green
Write-Host "10. Port Scanner" -ForegroundColor Green
Write-Host ""

$choice = Read-Host "Enter the number of your choice"

switch ($choice) {
    1 { Write-Host "You chose Keyword Hunter. Please enter the keyword:"; $keyword = Read-Host; Write-Log "Keyword Hunter - $keyword"; KeywordHunter($keyword) }
    2 { Write-Host "You chose File Organizer. Enter folder path:"; $folderPath = Read-Host; Write-Log "File Organizer - $folderPath"; FileOrganizer($folderPath) }
    3 { Write-Host "You chose List Scripts."; Write-Log "List Scripts"; ListScripts }
    4 { Write-Host "You chose System Info."; Write-Log "System Info"; Get-SystemInfo }
    5 { Write-Host "Exiting... Goodbye!"; Write-Log "Exit"; break }
    6 { Write-Log "Backup Tool"; BackupTool }
    7 { Write-Log "Quick Notes Manager"; QuickNotes }
    8 { Write-Log "Process Killer"; Kill-Process }
    9 { Write-Log "Disk Cleanup Helper"; DiskCleanup }
    10 { Write-Log "Port Scanner"; PortScanner }
    default { Write-Host "Invalid choice. Please enter a number between 1 and 10." }
}
