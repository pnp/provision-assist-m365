<#
.SYNOPSIS
    Creates the Entra ID App Registration for the Provision Assist solution and grants required API Permissions.

.DESCRIPTION
    Creates the Entra ID App Registration for the Provision Assist solution and grants API permissions.

    This script uses the Azure CLI to create/update the Entra ID App.

    This script should be executed using an account that has Global Administrator rights, this is neccessary to grant the requried API permissions.

    This script accepts a single parameter, which is the name of the Entra ID App you wish to use for Provision Assist.

.EXAMPLE
    createadapp.ps1

-----------------------------------------------------------------------------------------------------------------------------------
Script name : deploy.ps1
Authors : Alex Clark (Prin Cloud Solution Architect, Microsoft)
Version : 1.0
Dependencies :
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
Version Changes:
Date:       Version: Changed By:     Info:
-----------------------------------------------------------------------------------------------------------------------------------
DISCLAIMER
   THIS CODE IS SAMPLE CODE. THESE SAMPLES ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
   MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES
   OF MERCHANTABILITY OR OF FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR
   PERFORMANCE OF THE SAMPLES REMAINS WITH YOU. IN NO EVENT SHALL MICROSOFT OR ITS SUPPLIERS BE LIABLE FOR
   ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS
   INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
   INABILITY TO USE THE SAMPLES, EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
   BECAUSE SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR
   INCIDENTAL DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.
#>

[CmdletBinding()]
Param
(
    [Parameter (Mandatory = $true)]
    [String] $appName
)

# Check for presence of Azure CLI
If (-not (Test-Path -Path "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2") -and -not (Test-Path -Path "C:\Program Files\Microsoft SDKs\Azure\CLI2")) {
    Write-Host "AZURE CLI NOT INSTALLED!`nPLEASE INSTALL THE CLI FROM https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest and re-run this script in a new PowerShell session" -ForegroundColor Red
    break
}

# Gets the entra id app
function GetEntraIDApp {
    param ($appName)

    $app = az ad app list --filter "displayName eq '$appName'" | ConvertFrom-Json

    return $app

}

function CreateAzureADApp {
    try {
        Write-Host "### ENTRA ID APP CREATION ###" -ForegroundColor Yellow

        # Check if the app already exists - script has been previously executed
        $app = GetEntraIDApp $appName

        if (-not ([string]::IsNullOrEmpty($app))) {

            # Update entra id app registration using CLI
            Write-Host "Entra ID App $($appName) already exists - updating existing app..." -ForegroundColor Yellow

            az ad app update --id $app.appId --required-resource-accesses './appmanifest.json'

            $adAppId = $app.appId
            
            Write-Host "Waiting for app to finish updating..."

            Start-Sleep -s 60

            Write-Host "Updated Entra ID App" -ForegroundColor Green

        } 
        else {
            # Create the app
            Write-Host "Creating Entra ID App - $($appName)..." -ForegroundColor Yellow

            # Create entra id app registration using CLI
            $app = az ad app create --display-name $appName --required-resource-accesses './appmanifest.json'

            $appId = $app | ConvertFrom-Json | Select-Object appid

            $adAppId = $appId.appid
            
            Write-Host "Waiting for app to finish creating..." -ForegroundColor Yellow

            Start-Sleep -s 60

            Write-Host "Created Entra ID App" -ForegroundColor Green


        }

        Write-Host "Granting admin consent for Microsoft Graph..." -ForegroundColor Yellow

        # Grant admin consent for app registration required permissions using CLI
        az ad app permission admin-consent --id $adAppId
        
        Write-Host "Waiting for admin consent to finish..."

        Start-Sleep -s 60
        
        Write-Host "Granted admin consent" -ForegroundColor Green

        Write-Host "### ENTRA ID APP CREATION FINISHED ###" -ForegroundColor Green
    }
    catch {
        throw('Failed to create the Entra ID App {0}', $_.Exception.Message)
    }
}


$ErrorActionPreference = "stop"

Write-Host "###  CREATE ENTRA ID APP SCRIPT STARTED `n(c) Microsoft Corporation ###" -ForegroundColor Magenta

Write-Ascii -InputObject "Provision Assist" -ForegroundColor Green

# Initialise connections - Azure Az/CLI
Write-Host "Launching Azure sign-in..." -ForegroundColor Yellow

az login
Write-Host "Connected to Azure" -ForegroundColor Green
CreateAzureADApp

Write-Host "### SCRIPT COMPLETED SUCCESSFULLY ###" -ForegroundColor Green