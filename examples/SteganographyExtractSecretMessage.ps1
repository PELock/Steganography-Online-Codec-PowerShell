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
