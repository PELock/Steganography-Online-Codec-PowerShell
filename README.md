# Steganography Online Codec — PowerShell SDK

**[Steganography Online Codec](https://www.pelock.com/products/steganography-online-codec)** hides an AES-encrypted message inside an image.

API: https://www.pelock.com/api/steganography-online-codec/v1

## Installation

```powershell
Install-Module -Name SteganographyOnlineCodec
```

or

```powershell
Install-PSResource -Name SteganographyOnlineCodec
```

```powershell
using module SteganographyOnlineCodec
# or:
Import-Module SteganographyOnlineCodec
$client = New-SteganographyOnlineCodec -ApiKey 'YOUR-WEB-API-KEY'
```

## Usage

Encode and decode send the image as a multipart file.

```powershell
using module SteganographyOnlineCodec

$client = New-SteganographyOnlineCodec -ApiKey 'YOUR-WEB-API-KEY'
$encoded = $client.Encode('input.jpg', 'Secret message', 'Pa$$word', 'output.png')
if ($encoded.error -eq [SteganographyErrors]::SUCCESS) {
    $decoded = $client.Decode('output.png', 'Pa$$word')
    Write-Host $decoded.message
}
```

See `examples/` for login, encode, and decode samples.

Author: Bartosz Wójcik / PELock — https://www.pelock.com
