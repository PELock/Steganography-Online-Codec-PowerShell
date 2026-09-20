################################################################################
#
# Steganography Online Codec Web API client for PowerShell.
# Hide a password-encrypted message inside images using AES-256 / PBKDF2.
#
# Version      : PowerShell SDK v1.0.0
# PowerShell   : Windows PowerShell 5.1 / PowerShell 7+
# Author       : Bartosz Wójcik (support@pelock.com)
# Project      : https://www.pelock.com/products/steganography-online-codec
# Homepage     : https://www.pelock.com
#
################################################################################

Set-StrictMode -Version Latest

if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

$script:StegoApiUrl = 'https://www.pelock.com/api/steganography-online-codec/v1'
$script:StegoUserAgent = 'PELock Steganography Online Codec'
$script:StegoTimeoutSec = 3600

class SteganographyErrors {
    static [int] $WEBAPI_CONNECTION = -1
    static [int] $SUCCESS = 0
    static [int] $UNKNOWN = 1
    static [int] $MESSAGE_TOO_LONG = 2
    static [int] $IMAGE_TOO_BIG = 3
    static [int] $INVALID_INPUT = 4
    static [int] $INVALID_IMAGE_FORMAT = 5
    static [int] $IMAGE_MALFORMED = 6
    static [int] $INVALID_PASSWORD = 7
    static [int] $LIMIT_MESSAGE = 9
    static [int] $LIMIT_PASSWORD = 10
    static [int] $OUTPUT_FILE = 99
    static [int] $INVALID_LICENSE = 100
}

function ConvertTo-StegoFormBody {
    param([Parameter(Mandatory)] [hashtable]$Fields)

    $parts = foreach ($key in $Fields.Keys) {
        $name = [uri]::EscapeDataString([string]$key)
        $value = [uri]::EscapeDataString([string]$Fields[$key])
        '{0}={1}' -f $name, $value
    }

    return ($parts -join '&')
}

function Invoke-StegoMultipartRequest {
    param(
        [Parameter(Mandatory)] [hashtable]$Fields,
        [string]$FileField,
        [string]$FilePath
    )

    $headers = @{ 'User-Agent' = $script:StegoUserAgent }

    if ($PSVersionTable.PSVersion.Major -ge 6 -and $FilePath) {
        $form = @{}
        foreach ($key in $Fields.Keys) {
            $form[$key] = [string]$Fields[$key]
        }
        $form[$FileField] = Get-Item -LiteralPath $FilePath
        return Invoke-RestMethod -Uri $script:StegoApiUrl -Method Post -Form $form `
            -Headers $headers -TimeoutSec $script:StegoTimeoutSec
    }

    $boundary = '---------------------------' + [guid]::NewGuid().ToString('N')
    $encoding = [System.Text.Encoding]::UTF8
    $ms = New-Object System.IO.MemoryStream
    try {
        foreach ($key in $Fields.Keys) {
            $header = "--$boundary`r`nContent-Disposition: form-data; name=`"$key`"`r`n`r`n"
            $headerBytes = $encoding.GetBytes($header)
            $ms.Write($headerBytes, 0, $headerBytes.Length)
            $valueBytes = $encoding.GetBytes([string]$Fields[$key])
            $ms.Write($valueBytes, 0, $valueBytes.Length)
            $crlf = $encoding.GetBytes("`r`n")
            $ms.Write($crlf, 0, $crlf.Length)
        }

        if ($FilePath) {
            $fileName = [System.IO.Path]::GetFileName($FilePath)
            $fileHeader = "--$boundary`r`nContent-Disposition: form-data; name=`"$FileField`"; filename=`"$fileName`"`r`nContent-Type: application/octet-stream`r`n`r`n"
            $fileHeaderBytes = $encoding.GetBytes($fileHeader)
            $ms.Write($fileHeaderBytes, 0, $fileHeaderBytes.Length)
            $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $FilePath).Path)
            $ms.Write($fileBytes, 0, $fileBytes.Length)
            $crlf = $encoding.GetBytes("`r`n")
            $ms.Write($crlf, 0, $crlf.Length)
        }

        $end = $encoding.GetBytes("--$boundary--`r`n")
        $ms.Write($end, 0, $end.Length)
        $body = $ms.ToArray()
    }
    finally {
        $ms.Dispose()
    }

    return Invoke-RestMethod -Uri $script:StegoApiUrl -Method Post -Body $body `
        -ContentType ("multipart/form-data; boundary={0}" -f $boundary) `
        -Headers $headers -TimeoutSec $script:StegoTimeoutSec
}

class SteganographyOnlineCodec {
    static [string] $API_URL = 'https://www.pelock.com/api/steganography-online-codec/v1'

    hidden [string] $_api_key = ''

    SteganographyOnlineCodec() {
        $this.Initialize($null)
    }

    SteganographyOnlineCodec([string]$ApiKey) {
        $this.Initialize($ApiKey)
    }

    hidden [void] Initialize([string]$ApiKey) {
        $this._api_key = $ApiKey
    }

    [hashtable] Login() {
        return $this.PostRequest(@{ command = 'login' })
    }

    [hashtable] Encode([string]$InputImagePath, [string]$MessageToHide, [string]$Password, [string]$OutputImagePath) {
        $result = $this.PostRequest(@{
                command  = 'encode'
                image    = $InputImagePath
                message  = $MessageToHide
                password = $Password
            })

        if ([int]$result['error'] -eq [SteganographyErrors]::SUCCESS) {
            try {
                $binary = [Convert]::FromBase64String([string]$result['encodedImage'])
                [System.IO.File]::WriteAllBytes($OutputImagePath, $binary)
                $result.Remove('encodedImage')
                return $result
            }
            catch {
                return @{ error = [SteganographyErrors]::OUTPUT_FILE }
            }
        }

        return $result
    }

    [hashtable] Decode([string]$InputImagePath, [string]$Password) {
        return $this.PostRequest(@{
                command  = 'decode'
                image    = $InputImagePath
                password = $Password
            })
    }

    [hashtable] PostRequest([hashtable]$ParamsArray) {
        $defaultError = @{ error = [SteganographyErrors]::WEBAPI_CONNECTION }
        $params = @{}
        foreach ($key in $ParamsArray.Keys) {
            $params[$key] = $ParamsArray[$key]
        }

        if ($this._api_key) {
            $params['key'] = $this._api_key
        }

        $filePath = $null
        if ($params.ContainsKey('image')) {
            $filePath = [string]$params['image']
            if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
                return @{ error = [SteganographyErrors]::INVALID_INPUT }
            }
            $params.Remove('image')
        }

        try {
            if ($filePath) {
                $result = Invoke-StegoMultipartRequest -Fields $params -FileField 'image' -FilePath $filePath
            }
            else {
                $body = ConvertTo-StegoFormBody -Fields $params
                $headers = @{ 'User-Agent' = $script:StegoUserAgent }
                $result = Invoke-RestMethod -Uri $script:StegoApiUrl -Method Post -Body $body `
                    -ContentType 'application/x-www-form-urlencoded' -Headers $headers `
                    -TimeoutSec $script:StegoTimeoutSec
            }
        }
        catch {
            return $defaultError
        }

        if ($null -eq $result) {
            return $defaultError
        }

        $table = @{}
        foreach ($property in $result.PSObject.Properties) {
            $table[$property.Name] = $property.Value
        }

        if (-not $table.ContainsKey('error')) {
            return $defaultError
        }

        return $table
    }

    [hashtable] post_request([hashtable]$params_array) {
        return $this.PostRequest($params_array)
    }

    [string] ConvertSize([double]$SizeBytes) {
        if ($SizeBytes -le 0) {
            return '0 bytes'
        }

        $sizeName = @('bytes', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
        $i = [int][Math]::Floor([Math]::Log($SizeBytes, 1024))
        if ($i -ge $sizeName.Length) {
            $i = $sizeName.Length - 1
        }
        $p = [Math]::Pow(1024, $i)
        $s = [Math]::Round($SizeBytes / $p, 2)
        return ('{0} {1}' -f $s, $sizeName[$i])
    }

}

function New-SteganographyOnlineCodec {
    <#
    .SYNOPSIS
        Creates a Steganography Online Codec Web API client.

    .PARAMETER ApiKey
        Activation key from PELock. Empty keys run demo mode.

    .EXAMPLE
        $client = New-SteganographyOnlineCodec -ApiKey 'YOUR-WEB-API-KEY'
        $result = $client.Encode('input.jpg', 'Secret', 'Pa$$word', 'output.png')
    #>
    [CmdletBinding()]
    [OutputType([SteganographyOnlineCodec])]
    param(
        [string]$ApiKey
    )

    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        return [SteganographyOnlineCodec]::new($null)
    }

    return [SteganographyOnlineCodec]::new($ApiKey)
}

Export-ModuleMember -Function @('New-SteganographyOnlineCodec')
