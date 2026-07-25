$broker = "5026391e7d864c9ba7055b9943613481.s1.eu.hivemq.cloud"
$port   = 8883

$tcp = New-Object System.Net.Sockets.TcpClient($broker, $port)
$ssl = New-Object System.Net.Security.SslStream($tcp.GetStream(), $false, { $true })
$ssl.AuthenticateAsClient($broker)

$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
[void]$chain.Build($ssl.RemoteCertificate)

Write-Host "--- Certificate chain ---"
for ($i = 0; $i -lt $chain.ChainElements.Count; $i++) {
    $el = $chain.ChainElements[$i]
    Write-Host "[$i] Subject : $($el.Certificate.Subject)"
    Write-Host "    Issuer  : $($el.Certificate.Issuer)"
    Write-Host "    Expiry  : $($el.Certificate.NotAfter)"
    Write-Host ""
}

# Export the ROOT CA (last element) as PEM
$root = $chain.ChainElements[$chain.ChainElements.Count - 1].Certificate
$b64  = [Convert]::ToBase64String($root.Export("Cert"), "InsertLineBreaks")
$pem  = "-----BEGIN CERTIFICATE-----`n$b64`n-----END CERTIFICATE-----"
$pem | Out-File -FilePath "root_ca.pem" -Encoding ASCII

Write-Host "root_ca.pem written to current directory."
