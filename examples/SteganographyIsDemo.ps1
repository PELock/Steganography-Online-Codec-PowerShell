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
