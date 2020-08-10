 

# Create the root certificate for the self-signed certificate

$param1 = @{

  Subject = "CN=xyz, C=US"

  KeyLength = 2048

  KeyAlgorithm = 'RSA'

  HashAlgorithm = 'SHA256'

  KeyExportPolicy = 'Exportable'

  NotAfter = (Get-Date).AddYears(5)

  CertStoreLocation = 'Cert:\LocalMachine\My'

  KeyUsage = 'CertSign','CRLSign'

}

$rootCA = New-SelfSignedCertificate @param1

 

 

# Grab the thumbprint of the root certificate

$thumb = $rootCA.Thumbprint

$root = Get-Item -Path Cert:\LocalMachine\My\$($thumb)

#This is a path you want to download the .cer of the root certificate.

$path = "my.cer"

 

 

# Export the root certificate in a Base64 encoded X.509 to the path created above

$base64certificate = @"

-----BEGIN CERTIFICATE-----

$([Convert]::ToBase64String($root.Export('Cert'), [System.Base64FormattingOptions]::InsertLineBreaks)))

-----END CERTIFICATE-----

"@

Set-Content -Path $path -Value $base64certificate

 

 

# Import the root certificate of the self-signed certificate to the local machine trusted root store

Import-Certificate -CertStoreLocation 'Cert:\CurrentUser\My' -FilePath $path

 

 

# Create a new self-signed certificate and then link the root and the self-signed certificate

$param2 = @{

    DnsName = '*.jlacloud.com'

    Subject = "api.jlacloud.com"

    Signer = $rootCA

    KeyLength = 2048

    KeyAlgorithm = 'RSA'

    HashAlgorithm = 'SHA256'

    KeyExportPolicy = 'Exportable'

    CertStoreLocation = 'Cert:\LocalMachine\My'

    NotAfter = (Get-date).AddYears(2)

}

$selfCert = New-SelfSignedCertificate @param2

 

 

# Export the certificate in .pfx format for the application gateway listener and ASE ILB Cert.

Export-PfxCertificate -Cert $selfCert -FilePath "my.pfx" -Password (ConvertTo-SecureString -AsPlainText '123456' -Force)