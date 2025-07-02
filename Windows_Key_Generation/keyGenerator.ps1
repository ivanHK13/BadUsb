# Generate RSA 2048 key pair
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(2048)

# Export the private key (keep safe!)
$privateKey = $rsa.ToXmlString($true)
[IO.File]::WriteAllText("C:\Users\ivan\Desktop\private_key.xml", $privateKey)

# Export the public key (put into your script)
$publicKey = $rsa.ToXmlString($false)
[IO.File]::WriteAllText("C:\Users\ivan\Desktop\public_key.xml", $publicKey)
