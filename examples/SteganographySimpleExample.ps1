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
