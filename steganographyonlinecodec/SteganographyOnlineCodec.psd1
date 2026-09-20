@{
    RootModule        = 'SteganographyOnlineCodec.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '09b3e0c8-e983-4c47-8c37-485a92606fa6'
    Author            = 'Bartosz Wójcik'
    CompanyName       = 'PELock'
    Copyright         = '(c) 2026 Bartosz Wójcik / PELock. All rights reserved.'
    Description       = 'PowerShell Gallery Web API client for Steganography Online Codec. Hide and extract AES-encrypted messages in images via the PELock remote API.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'New-SteganographyOnlineCodec'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @(
                'Steganography',
                'AES',
                'Image',
                'Codec',
                'PELock',
                'API',
                'Security'
            )
            LicenseUri   = 'https://www.apache.org/licenses/LICENSE-2.0'
            ProjectUri   = 'https://www.pelock.com/products/steganography-online-codec'
            ReleaseNotes = @'
## 1.0.0

- Initial PowerShell Gallery release
- SteganographyOnlineCodec class — login / encode / decode
- Multipart image upload for encode and decode
- New-SteganographyOnlineCodec — factory for the client
'@
        }
    }
}
