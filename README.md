# Steganography Online Codec SDK for PowerShell

**Steganography Online Codec** allows you to hide a password encrypted message within the images & photos using [AES](https://www.youtube.com/watch?v=O4xNJsjtN6E)
encryption algorithm with a 256-bit [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) derived key.

You can use it for free at:

https://www.pelock.com/products/steganography-online-codec

This SDK provides programming access to the codec and its encoding and decoding functions through a WebAPI interface.

## What is steganography & how it works?

Steganography is a term describing the art and science of hiding information by embedding messages within other, seemingly harmless image files.

In this case, the individual bits of the encrypted hidden message are saved as the least significant (LSB) bits in the
RGB color components in the pixels of the selected image.

![Steganography Online Codec - Hide Message in Image](https://www.pelock.com/img/en/products/steganography-online-codec/steganography-online-codec.png)

With our steganographic encoder you will be able to conceal any text message in the image in a secure way and
send it without raising any suspicion. It will only be possible to read the message after providing valid, decryption
password.

## Installation

The preferred way to install the Web API SDK is via PowerShell Gallery.

```powershell
Install-Module -Name SteganographyOnlineCodec
Import-Module SteganographyOnlineCodec
```

Module listing: https://www.powershellgallery.com/packages/SteganographyOnlineCodec

## Packages for other programming languages

The installation packages have been uploaded to repositories for several popular programming languages and their source codes have been published on GitHub:

| Repository   | Language | Installation | Package | GitHub |
| ---------- | -------- | ------------ | ------- | ------ |
| ![PyPI repository for Python](https://www.pelock.com/img/logos/repo-pypi.png) | Python | Run `pip install steganography-online-codec` | [PyPI](https://pypi.org/project/steganography-online-codec/) | [Sources](https://github.com/PELock/Steganography-Online-Codec-Python) |
| ![NPM repository for JavaScript and TypeScript](https://www.pelock.com/img/logos/repo-npm.png) | JavaScript, TypeScript | Run `npm i steganography-online-codec` or add `"steganography-online-codec": "latest"` under `dependencies` in `package.json` | [NPM](https://www.npmjs.com/package/steganography-online-codec) | [Sources](https://github.com/PELock/Steganography-Online-Codec-JavaScript) |
| ![Rust crates.io](https://www.pelock.com/img/logos/repo-crates.png) | Rust | Run `cargo add steganography-online-codec` or add `steganography-online-codec = "1"` to `Cargo.toml` (optional: `git` / `path` for unreleased or vendored builds) | [crates.io](https://crates.io/crates/steganography-online-codec) | [Sources](https://github.com/PELock/Steganography-Online-Codec-Rust) |

### Example — `SteganographyExtractSecretMessage.ps1`

```powershell
################################################################################
#
# Steganography Online Codec WebApi interface usage example.
#
# Decode a secret message from an image.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

using module '..\steganographyonlinecodec\SteganographyOnlineCodec.psd1'

$client = New-SteganographyOnlineCodec -ApiKey 'YOUR-WEB-API-KEY'
$result = $client.Decode('output_file_with_hidden_secret_message.png', 'Pa$$word')

if ($result -and $result.ContainsKey('error')) {
    if ($result.error -eq [SteganographyErrors]::SUCCESS) {
        Write-Host ("Secret message is `"{0}`"" -f $result.message)
    }
    else {
        Write-Host ("Error code {0}" -f $result.error)
    }
}
else {
    Write-Host 'Something unexpected happened while trying to extract the secret message.'
}
```

### Example — `SteganographyIsDemo.ps1`

```powershell
################################################################################
#
# Steganography Online Codec WebApi interface usage example.
#
# Check activation key / demo status.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

using module '..\steganographyonlinecodec\SteganographyOnlineCodec.psd1'

$client = New-SteganographyOnlineCodec -ApiKey 'YOUR-WEB-API-KEY'
$result = $client.Login()

if ($result) {
    $full = $false
    if ($result.ContainsKey('license') -and $result.license.activationStatus) {
        $full = $true
    }
    Write-Host ("You are running in {0} version" -f $(if ($full) { 'full' } else { 'demo' }))
    if ($full) {
        Write-Host ("Registered for - {0}" -f $result.license.userName)
        Write-Host ("Remaining number of usage credits - {0}" -f $result.license.usagesCount)
    }
    if ($result.ContainsKey('limits')) {
        Write-Host ("Max. password length - {0}" -f $result.limits.maxPasswordLen)
    }
}
else {
    Write-Host 'Something unexpected happened while trying to login to the service.'
}
```

### Example — `SteganographySimpleExample.ps1`

```powershell
################################################################################
#
# Steganography Online Codec WebApi interface usage example.
#
# Encode a secret message into an image.
#
# Version        : v1.0.0
# Language       : PowerShell
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
################################################################################

using module '..\steganographyonlinecodec\SteganographyOnlineCodec.psd1'

$client = New-SteganographyOnlineCodec -ApiKey 'YOUR-WEB-API-KEY'
$result = $client.Encode('input_file.jpg', 'Secret message', 'Pa$$word', 'output_file_with_hidden_secret_message.png')

if ($result -and $result.ContainsKey('error')) {
    if ($result.error -eq [SteganographyErrors]::SUCCESS) {
        Write-Host 'Secret message encoded and saved to the output PNG file.'
    }
    else {
        Write-Host ("Error code {0}" -f $result.error)
    }
}
else {
    Write-Host 'Something unexpected happened while trying to encode the message.'
}
```

See the `examples/` directory in this repository for complete samples.

## Got questions?

If you are interested in the Steganography Online Codec Web API or have any questions regarding SDK packages, technical or if something is not clear, [please contact me](https://www.pelock.com/contact). I'll be happy to answer all of your questions.

Bartosz Wójcik

* Visit my site at — https://www.pelock.com
* X — https://x.com/PELock
* GitHub — https://github.com/PELock