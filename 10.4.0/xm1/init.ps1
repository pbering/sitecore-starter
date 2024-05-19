[CmdletBinding(DefaultParameterSetName = "no-arguments")]
Param (
    [Parameter(HelpMessage = "Enables initialization of values in the .env file, which may be placed in source control.", ParameterSetName = "env-init")] [switch]$InitEnv
    ,
    [Parameter(Mandatory = $true, HelpMessage = "The path to a valid Sitecore license.xml file.", ParameterSetName = "env-init")] [string]$LicenseXmlPath
    ,
    # We do not need to use [SecureString] here since the value will be stored unencrypted in .env,
    # and used only for transient local development environments.
    [Parameter(Mandatory = $true, HelpMessage = "Sets the sitecore\\admin password for this environment via environment variable.", ParameterSetName = "env-init")] [string]$AdminPassword
    ,
    [Parameter(Mandatory = $false)] [string] $ProjectName = "ss1040xm1"
)

$ErrorActionPreference = "Stop";

if ($InitEnv)
{
    if (-not $LicenseXmlPath.EndsWith("license.xml"))
    {
        Write-Error "Sitecore license file must be named 'license.xml'."
    }

    if (-not (Test-Path $LicenseXmlPath))
    {
        Write-Error "Could not find Sitecore license file at path '$LicenseXmlPath'."
    }

    # We actually want the folder that it's in for mounting
    $LicenseXmlPath = (Get-Item $LicenseXmlPath).Directory.FullName
}

Write-Host "Preparing your Sitecore Containers environment!" -ForegroundColor Green

################################################
# Retrieve and import SitecoreDockerTools module
################################################

# Check for Sitecore Gallery
Import-Module PowerShellGet

$SitecoreGallery = Get-PSRepository | Where-Object { $_.SourceLocation -eq "https://nuget.sitecore.com/resources/v2/" }

if (-not $SitecoreGallery)
{
    Write-Host "Adding Sitecore PowerShell Gallery..." -ForegroundColor Green

    Register-PSRepository -Name SitecoreGallery -SourceLocation https://nuget.sitecore.com/resources/v2/ -InstallationPolicy Trusted

    $SitecoreGallery = Get-PSRepository -Name SitecoreGallery
}

# Install and Import SitecoreDockerTools
$dockerToolsVersion = "10.3.40"

Remove-Module SitecoreDockerTools -ErrorAction SilentlyContinue

if (-not (Get-InstalledModule -Name SitecoreDockerTools -RequiredVersion $dockerToolsVersion -ErrorAction SilentlyContinue))
{
    Write-Host "Installing SitecoreDockerTools..." -ForegroundColor Green

    Install-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion -Scope CurrentUser -Repository $SitecoreGallery.Name
}

Write-Host "Importing SitecoreDockerTools..." -ForegroundColor Green

Import-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion

Write-SitecoreDockerWelcome

##################################
# Configure TLS/HTTPS certificates
##################################

Push-Location "docker\data\traefik\certs"

try
{
    $mkcert = ".\mkcert.exe"

    if ($null -ne (Get-Command mkcert.exe -ErrorAction SilentlyContinue))
    {
        # mkcert installed in PATH
        $mkcert = "mkcert"
    }
    elseif (-not (Test-Path $mkcert))
    {
        Write-Host "Downloading and installing mkcert certificate tool..." -ForegroundColor Green

        Invoke-WebRequest "https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-windows-amd64.exe" -UseBasicParsing -OutFile "mkcert.exe"

        if ((Get-FileHash mkcert.exe).Hash -ne "D2660B50A9ED59EADA480750561C96ABC2ED4C9A38C6A24D93E30E0977631398")
        {
            Remove-Item mkcert.exe -Force

            throw "Invalid mkcert.exe file"
        }
    }

    Write-Host "Generating Traefik TLS certificate..." -ForegroundColor Green

    & $mkcert -install

    & $mkcert "*.$ProjectName.localhost"
}
catch
{
    Write-Error "An error occurred while attempting to generate TLS certificate: $_"
}
finally
{
    Pop-Location
}

################################
# Add Windows hosts file entries
################################

Write-Host "Adding Windows hosts file entries..." -ForegroundColor Green

Add-HostsEntry "cm-platform.$ProjectName.localhost"
Add-HostsEntry "cd-platform.$ProjectName.localhost"
Add-HostsEntry "id.$ProjectName.localhost"

###############################
# Populate the environment file
###############################

if ($InitEnv)
{
    Write-Host "Populating required .env file values..." -ForegroundColor Green

    # HOST_LICENSE_FOLDER
    Set-EnvFileVariable "HOST_LICENSE_FOLDER" -Value $LicenseXmlPath

    # CM_HOSTS
    Set-EnvFileVariable "CM_HOST_PLATFORM" -Value "cm-platform.$ProjectName.localhost"
    Set-EnvFileVariable "CD_HOST_PLATFORM" -Value "cm-platform.$ProjectName.localhost"

    # ID_HOST
    Set-EnvFileVariable "ID_HOST" -Value "id.$ProjectName.localhost"

    # TELERIK_ENCRYPTION_KEY = random 64-128 chars
    Set-EnvFileVariable "TELERIK_ENCRYPTION_KEY" -Value (Get-SitecoreRandomString 128 -DisallowSpecial)

    # MEDIA_REQUEST_PROTECTION_SHARED_SECRET
    Set-EnvFileVariable "MEDIA_REQUEST_PROTECTION_SHARED_SECRET" -Value (Get-SitecoreRandomString 64 -DisallowSpecial)

    # SITECORE_IDSECRET = random 64 chars
    Set-EnvFileVariable "SITECORE_IDSECRET" -Value (Get-SitecoreRandomString 64 -DisallowSpecial)

    # SITECORE_ID_CERTIFICATE
    $idCertPassword = Get-SitecoreRandomString 8 -DisallowSpecial

    Set-EnvFileVariable "SITECORE_ID_CERTIFICATE" -Value (Get-SitecoreCertificateAsBase64String -DnsName "localhost" -Password (ConvertTo-SecureString -String $idCertPassword -Force -AsPlainText))

    # SITECORE_ID_CERTIFICATE_PASSWORD
    Set-EnvFileVariable "SITECORE_ID_CERTIFICATE_PASSWORD" -Value $idCertPassword

    # SQL_SA_PASSWORD
    # Need to ensure it meets SQL complexity requirements
    Set-EnvFileVariable "SQL_SA_PASSWORD" -Value (Get-SitecoreRandomString 19 -DisallowSpecial -EnforceComplexity)

    # SITECORE_ADMIN_PASSWORD
    Set-EnvFileVariable "SITECORE_ADMIN_PASSWORD" -Value $AdminPassword
}

Write-Host "Done!" -ForegroundColor Green