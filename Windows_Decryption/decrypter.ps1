# === Load RSA Private Key ===
$privateKeyXml = Get-Content -Path "<copy your private key path in here !!!!>" -Raw
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(2048)
$rsa.PersistKeyInCsp = $false
$rsa.FromXmlString($privateKeyXml)

# === Target Directories (where you encrypted) ===
$folders = @(
    [Environment]::GetFolderPath("Desktop"),
    [Environment]::GetFolderPath("MyDocuments"),
    [Environment]::GetFolderPath("MyPictures"),
    "$env:USERPROFILE\Downloads"
)

# === File Extensions You Encrypted ===
$extensions = @("*.docx", "*.pdf", "*.jpg", "*.xlsx")

# === Decrypt Function ===
function Decrypt-File($filePath, $rsa) {
    try {
        # Read the encrypted file
        $encryptedData = [System.IO.File]::ReadAllBytes($filePath)

        # Calculate RSA encrypted block size (256 bytes for 2048-bit RSA)
        $rsaBlockSize = 256

        # Extract RSA-encrypted AES Key and IV
        $encAESKey = $encryptedData[0..($rsaBlockSize - 1)]
        $encAESIV = $encryptedData[$rsaBlockSize..(2 * $rsaBlockSize - 1)]

        # Decrypt AES Key and IV using the private RSA key
        $aesKey = $rsa.Decrypt($encAESKey, $true)
        $aesIV = $rsa.Decrypt($encAESIV, $true)

        # Remaining data is the AES-encrypted file content
        $encryptedFileContent = $encryptedData[(2 * $rsaBlockSize)..($encryptedData.Length - 1)]

        # Create AES decryptor
        $aes = New-Object System.Security.Cryptography.AesManaged
        $aes.KeySize = 256
        $aes.Key = $aesKey
        $aes.IV = $aesIV
        $decryptor = $aes.CreateDecryptor()

        # Decrypt file content
        $decryptedContent = $decryptor.TransformFinalBlock($encryptedFileContent, 0, $encryptedFileContent.Length)

        # Overwrite the encrypted file with decrypted content
        [System.IO.File]::WriteAllBytes($filePath, $decryptedContent)

        Write-Host "[+] Decrypted: $filePath"
    }
    catch {
        Write-Host "[-] Failed to decrypt: $filePath"
    }
}

# === Loop and Decrypt Files ===
foreach ($folder in $folders) {
    foreach ($ext in $extensions) {
        Get-ChildItem -Path $folder -Recurse -Filter $ext -File -ErrorAction SilentlyContinue | ForEach-Object {
            Decrypt-File $_.FullName $rsa
        }
    }
}

Write-Host "Decryption complete."
