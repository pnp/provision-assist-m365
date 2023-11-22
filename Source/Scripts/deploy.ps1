<#
.SYNOPSIS
    Deploys the following assets of the Provision Assist solution - 

        -SharePoint Site & Assets 
        -Azure AD App - Creates sectet
        -Azure Automation Account & Runbooks
        -Logic App

.DESCRIPTION
    Deploys the Provision Assist solution (excluding the PowerApp and Flows).
    This script uses the Azure CLI, Azure Az PowerShell, SharePoint PnP PowerShell and the Microsoft Graph PowerShell Modules to perform the deployment.

    As part of the deployment, the script will generate a secet for the Azure AD App created by the 'createadapp.ps1' script. 

    The account running this script must be able to create secrets for Azure AD Applications. The 'Cloud Application Administrator' role will suffice.

    The script requires input during execution, requires sign-in to a number of services and therefore should be monitored.

    Parameters should be filled out in the parameters.json file before executing the script.

.EXAMPLE
    deploy.ps1 

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

<# Valid Azure locations that support Azure Automation & Logic Apps at the time of writing - https://azure.microsoft.com/en-gb/global-infrastructure/services/?products=logic-apps,automation&regions=all #>

Add-Type -AssemblyName System.Web

# Check for presence of Azure CLI
If (-not (Test-Path -Path "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2") -and -not (Test-Path -Path "C:\Program Files\Microsoft SDKs\Azure\CLI2")) {
    Write-Host "AZURE CLI NOT INSTALLED!`nPLEASE INSTALL THE CLI FROM https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest and re-run this script in a new PowerShell session" -ForegroundColor Red
    break
}

# Variables
$packageRootPath = "..\"
$imagesDir = "Assets\ProvTypesImages"
$iconsDir = "Assets\ProvTypesIcons"
$templatePath = "Templates\provisionassist-sitetemplate.xml"
$settingsPath = "Settings\SharePoint List items.xlsx"

# Required PS modules
$preReqModules = "PnP.PowerShell", "Az", "AzureADPreview", "ImportExcel", "WriteAscii", "Microsoft.Graph"

#  Worksheets
$provRequestSettingsWorksheetName = "Provisioning Request Settings"
$provTypesWorksheetName = "Provisioning Types"
$recommendationsWorksheetName = "Recommendation Scoring"
$teamsTemplatesWorksheetName = "Teams Templates"
$timeZonesWorksheetName = "Time Zones"
$localesWorksheetName = "Locales"

#  lists
$requestsListName = "Provisioning Requests"
$requestSettingsListName = "Provisioning Request Settings"
$siteAssetsListURL = "SiteAssets"
$provTypesListName = "Provisioning Types"
$siteTemplatesListName = "Site Templates"
$hubSitesListName = "Hub Sites"
$recommendationScoreListName = "Recommendation Scoring"
$teamsTemplatesListName = "Teams Templates"
$timeZonesListName = "Time Zones"
$localesListName = "Locales"
$ipLabelsListName = "IP Labels"

#  Folder names
$provRequestsFolderName = "Provisioning Request"
$provTypesImageFolderName = "ProvTypesImages"
$provTypesIconFolderName = "ProvTypesIcons"

#  Field names
$TitleFieldName = "Title"
$SpaceTitleFieldName = "Space Title"
$RequirementFieldName = "Requirement"

$imageFolderUpload = "$siteAssetsListURL/$provRequestsFolderName/$provTypesImageFolderName"
$iconFolderUpload = "$siteAssetsListURL/$provRequestsFolderName/$provTypesIconFolderName"

$saUsername = ""
$saPassword = ""

$automationAccountName = "provisionassist-auto"

# Global variables
$global:context = $null
$global:requestsListId = $null
$global:requestsSettingsListId = $null
$global:siteTemplatesListId = $null
$global:hubSitesListId = $null
$global:teamsTemplatesListId = $null
$global:appId = $null
$global:appSecret = $null
$global:appServicePrincipalId = $null
$global:siteClassifications = $null

# Validates if a parameter in the json file is valid
function IsValidParam {
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        $param
    )

    return -not([string]::IsNullOrEmpty($param.Value)) -and ($param.Value -ne '<<value>>')
}

function IsValidGuid {
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ObjectGuid
    )

    # Define verification regex
    [regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'

    # Check guid against regex
    return $ObjectGuid -match $guidRegex
}

# Validate input parameters.
function ValidateParameters {
    $isValid = $true

    if (-not(IsValidParam($parameters.tenantId)) -or -not(IsValidGuid -ObjectGuid $parameters.tenantId.Value)) {
        Write-Host "Invalid tenantId. This should be a GUID" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.spoTenantName))) {
        Write-Host "Invalid spoTenantName" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.requestsSiteName))) {
        Write-Host "Invalid requestsSiteName" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.requestsSiteDesc))) {
        Write-Host "Invalid requestsSiteDesc" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.managedPath))) {
        Write-Host "Invalid managedPath" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not(IsValidParam($parameters.subscriptionId)) -or -not(IsValidGuid -ObjectGuid $parameters.subscriptionId.Value)) {
        Write-Host -message "Invalid subscriptionId. This should be a GUID." -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.region))) {
        Write-Host "Invalid region" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.resourceGroupName))) {
        Write-Host "Invalid resourceGroupName" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.appName))) {
        Write-Host "Invalid appName" -ForegroundColor Red
        $isValid = $false;
    }

    if (-not (IsValidParam($parameters.serviceAccountUPN))) {
        Write-Host "Invalid serviceAccountUPN" -ForegroundColor Red
        $isValid = $false;
    }
    
    if (-not (IsValidParam($parameters.keyVaultName))) {
        Write-Host "Invalid keyVaultName" -ForegroundColor Red
        $isValid = $false;
    }

    return $isValid
}

# Verifies installation of required PowerShell modules - throws error if a module is not installed
function VerifyModules {
    foreach ($module in $preReqModules) {
        $instModule = Get-InstalledModule -Name $module -ErrorAction:SilentlyContinue
        if ($null -eq $instModule) {
            throw('{0} module not installed. Please install all required modules.' -f $module)
        }
    }
    
}

# Test for availability of Azure resources
function Test-AzNameAvailability {
    param(
        [Parameter(Mandatory = $true)] [string] $AuthorizationToken,
        [Parameter(Mandatory = $true)] [string] $SubscriptionId,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [ValidateSet(
            'ApiManagement', 'KeyVault', 'ManagementGroup', 'Sql', 'StorageAccount', 'WebApp')]
        $ServiceType
    )
 
    $uriByServiceType = @{
        ApiManagement   = 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.ApiManagement/checkNameAvailability?api-version=2019-01-01'
        KeyVault        = 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.KeyVault/checkNameAvailability?api-version=2019-09-01'
        ManagementGroup = 'https://management.azure.com/providers/Microsoft.Management/checkNameAvailability?api-version=2018-03-01-preview'
        Sql             = 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Sql/checkNameAvailability?api-version=2018-06-01-preview'
        StorageAccount  = 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Storage/checkNameAvailability?api-version=2019-06-01'
        WebApp          = 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Web/checkNameAvailability?api-version=2019-08-01'
    }
 
    $typeByServiceType = @{
        ApiManagement   = 'Microsoft.ApiManagement/service'
        KeyVault        = 'Microsoft.KeyVault/vaults'
        ManagementGroup = '/providers/Microsoft.Management/managementGroups'
        Sql             = 'Microsoft.Sql/servers'
        StorageAccount  = 'Microsoft.Storage/storageAccounts'
        WebApp          = 'Microsoft.Web/sites'
    }
 
    $uri = $uriByServiceType[$ServiceType] -replace ([regex]::Escape('{subscriptionId}')), $SubscriptionId
    $body = '"name": "{0}", "type": "{1}"' -f $Name, $typeByServiceType[$ServiceType]
 
    $response = (Invoke-WebRequest -Uri $uri -UseBasicParsing -Method Post -Body "{$body}" -ContentType "application/json" -Headers @{Authorization = $AuthorizationToken }).content
    $response | ConvertFrom-Json |
    Select-Object @{N = 'Name'; E = { $Name } }, @{N = 'Type'; E = { $ServiceType } }, @{N = 'Available'; E = { $_ | Select-Object -ExpandProperty *available } }, Reason, Message
}

# Get Azure access token for current user
function Get-AccessTokenFromCurrentUser {
    $azContext = Get-AzContext
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList $azProfile
    $token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
    ('Bearer ' + $token.AccessToken)
}     

# Create site and apply provisioning template
function CreateRequestsSharePointSite {
    try {
        Write-Host "### PROVISION ASSIST SPO SITE CREATION ###`nCreating Provision Assist SharePoint site..." -ForegroundColor Yellow

        $site = Get-PnPTenantSite -Url $requestsSiteUrl -ErrorAction SilentlyContinue

        if (!$site) {

            New-PnPSite -Type TeamSite -Title $parameters.requestsSiteName.Value -Alias $requestsSiteAlias -Description $parameters.requestsSiteDesc.Value -Owners $parameters.serviceAccountUPN.Value
        
            Write-Host "Waiting for site to finish creating..." -ForegroundColor Yellow
            
            Start-sleep -Seconds 60
            Write-Host "Site created`n**PROVISION ASSIST SITE CREATION COMPLETE**" -ForegroundColor Green
        }
        else {
            Write-Host "Site already exists! Do you wish to overwrite?" -ForegroundColor Red
            $overwrite = Read-Host " ( y (overwrite) / n (exit) )"
            if ($overwrite -ne "y") {
                break
            }
        }
    }
    catch {
        throw('Failed to create the SharePoint site {0}', $_.Exception.Message)
    }
}

# Configure the new site
function ConfigureSharePointSite {

    try {

        Write-Host "### PROVISION ASSIST SPO SITE CONFIGURATION ###`nConfiguring SharePoint site..." -ForegroundColor Yellow

        If ($parameters.skipApplySPOTemplate.Value) { 

            Write-Host "You chose to skip applying the provisioning template" -ForegroundColor Yellow
        }
        else {
            
            Write-Host "Applying provisioning template..." -ForegroundColor Yellow

            Invoke-PnPSiteTemplate -Path (Join-Path $packageRootPath $templatePath) -ClearNavigation

            Write-Host "Applied template" -ForegroundColor Green
        }
        
            
        $context = Get-PnPContext
        # Ensure Site Assets
        $web = $context.Web
        $context.Load($web)
        $context.Load($web.Lists)
        $t = $web.Lists.EnsureSiteAssetsLibrary()
        $context.ExecuteQuery()
        
        Write-Host "Site Assets library initialised" -ForegroundColor Green

        # Rename Title field
        $siteRequestsList = Get-PnPList $requestsListName
        $context.Load($siteRequestsList)
        $context.ExecuteQuery()

        $context.Load($siteRequestsList.Fields)
        $context.ExecuteQuery()

        $global:requestsListId = $siteRequestsList.Id
        $fields = $siteRequestsList.Fields

        $titleField = $fields | Where-Object { $_.InternalName -eq $TitleFieldName }
        $titleField.Title = $SpaceTitleFieldName
        $titleField.UpdateAndPushChanges($true)
        $context.ExecuteQuery()

        <# Create folders in Site Assets
         Try to get the folder first to see if it already exists - delete Site Request folder if it exists #>
        $siteRequestsFolder = Get-PnPFolder -Url "/$($parameters.managedPath.Value)/$requestsSiteAlias/SiteAssets/$provRequestsFolderName" -ErrorAction SilentlyContinue

        if ($null -ne $siteRequestsFolder) {
            Remove-PnPFolder -Name $provRequestsFolderName -Folder "SiteAssets" -Force
        }

        $folder = Add-PnPFolder -Name $provRequestsFolderName -Folder "$requestsSiteUrl/$siteAssetsListURL"
        
        $folder = Add-PnPFolder -Name $provTypesImageFolderName -Folder "$requestsSiteUrl/$siteAssetsListURL/$provRequestsFolderName"

        $folder = Add-PnPFolder -Name $provTypesIconFolderName -Folder "$requestsSiteUrl/$siteAssetsListURL/$provRequestsFolderName"

        Write-Host "Created folders in Site Assets" -ForegroundColor Green

        # Adding settings in Site request Settings list
        $siteRequestsSettingsList = Get-PnPList $requestSettingsListName
        $context.Load($siteRequestsSettingsList)
        $context.ExecuteQuery()

        # Get request settings list id
        $global:requestsSettingsListId = $siteRequestsSettingsList.Id

        # Get site templates List id
        $siteTemplatesList = Get-PnPList $siteTemplatesListName
        $context.Load($siteTemplatesList)
        $context.ExecuteQuery()

        $global:siteTemplatesListId = $siteTemplatesList.Id

        # Get hub sites List id
        $hubSitesList = Get-PnPList $hubSitesListName
        $context.Load($hubSitesList)
        $context.ExecuteQuery()

        $global:hubSitesListId = $hubSitesList.Id

        # Delete existing settings items
        $settingsItems = Get-PnPListItem -List $siteRequestsSettingsList

        foreach ($settingItem in $settingsItems) {
            Remove-PnPListItem -List $siteRequestsSettingsList -Identity $settingItem -Force
        }

        $siteRequestSettings = Import-Excel "$packageRootPath$settingsPath" -WorksheetName $provRequestSettingsWorksheetName
        foreach ($setting in $siteRequestSettings) {
            if ($setting.Title -eq "TenantURL") {
                $setting.Value = $tenantUrl
            }
            if ($setting.Title -eq "SPOManagedPath") {
                $setting.Value = $parameters.managedPath.Value
            }
            if ($setting.Title -eq "SiteClassifications") {
                $setting.Value = $global:siteClassifications
            }
            if ($setting.Title -eq "EnableSensitivityLabels") {
                If ($parameters.enableSensitivity.Value) {
                    $setting.Value = "true"
                }
            }
            $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $newItem = $siteRequestsSettingsList.AddItem($listItemCreationInformation)
            $newitem["Title"] = $setting.Title
            $newitem["Description"] = $setting.Description
            # Hide site classifications option in Power App if no site classifications were found in the tenant
            if ($null -eq $global:siteClassifications -and $setting.Title -eq "HideSiteClassifications") {
                $newItem["Value"] = "true"
            }
            else {
                $newitem["Value"] = $setting.Value
            }
            $newitem.Update()
            $context.ExecuteQuery()

        }

        # Hide blocked words field in settings list
        $field = $siteRequestsSettingsList.Fields.GetByInternalNameOrTitle("BlockedWordsValue")
        $field.SetShowInEditForm($false)
        $context.ExecuteQuery()
        $field.SetShowInNewForm($false)
        $context.ExecuteQuery()
        $field.SetShowInDisplayForm($false)
        $context.ExecuteQuery()

        Write-Host "Added settings to Provisioning Requests Settings list" -ForegroundColor Green

        # Adding provisioning types to Provisioning Types list
        $provTypesList = Get-PnPList $provTypesListName 
        $context.Load($provTypesList)
        $context.ExecuteQuery()

        # Delete existing provisioning types 
        $provTypeItems = Get-PnPListItem -List $provTypesList

        foreach ($provTypeItem in $provTypeItems) {
            Remove-PnPListItem -List $provTypesList -Identity $provTypeItem -Force
        }

        $provTypes = Import-Excel "$packageRootPath$settingsPath" -WorksheetName $provTypesWorksheetName
        foreach ($provType in $provTypes) {
            $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $newItem = $provTypesList.AddItem($listItemCreationInformation)
            $newitem["Title"] = $provType.Title
            $newitem["Description"] = $provType.Description
            $newitem["Allowed"] = $provType.Allowed
            $newitem["TemplateId"] = $provType.TemplateID
            $newitem["Image"] = "$requestsSiteUrl/$imageFolderUpload/$($provType.Image)"
            $newItem["Icon"] = "$requestsSiteUrl/$iconFolderUpload/$($provType.Icon)"
            $newitem["WebTemplateId"] = $provType.WebTemplateID
            $newitem["LearnVideoURL"] = $provType.LearnVideo
            $newItem["InternalTitle"] = $provType.InternalTitle
            $newitem.Update()
            $context.ExecuteQuery()
        }

        #Hide internal title field in provisioning types list
        $field = $provTypesList.Fields.GetByInternalNameOrTitle("InternalTitle")
        $field.SetShowInEditForm($false)
        $context.ExecuteQuery()
        $field.SetShowInNewForm($false)
        $context.ExecuteQuery()
        $field.SetShowInDisplayForm($false)
        $context.ExecuteQuery()

        Write-Host "Added provisioning types to Provisioning Types list" -ForegroundColor Green

        # Adding requirements to Recommendation Scoring list
        $recommendationScoreList = Get-PnPList $recommendationScoreListName
        $context.Load($recommendationScoreList)
        $context.ExecuteQuery()

        # Rename Title field to 'Requirement'
        $fields = $recommendationScoreList.Fields
        $context.Load($fields)
        $context.ExecuteQuery()
 
        $titleField = $fields | Where-Object { $_.InternalName -eq $TitleFieldName }
        $titleField.Title = $RequirementFieldName
        $titleField.UpdateAndPushChanges($true)
        $context.ExecuteQuery()

        # Delete existing recommendation items
        $recommendationItems = Get-PnPListItem -List $recommendationScoreList

        foreach ($recommendationItem in $recommendationItems) {
            Remove-PnpListItem -List $recommendationScoreList -Identity $recommendationItem -Force
        }

        $recommendations = Import-Excel "$packageRootPath$settingsPath" -WorksheetName $recommendationsWorksheetName
        foreach ($recommendation in $recommendations) {
            $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $newItem = $recommendationScoreList.AddItem($listItemCreationInformation)
            $newitem["Title"] = $recommendation.Requirement
            $newitem["ModernTeamSite"] = $recommendation.ModernTeamSite
            $newitem["ModernTeamSiteGroup"] = $recommendation.ModernTeamSiteGroup
            $newitem["CommunicationSite"] = $recommendation.CommunicationSite
            $newitem["MicrosoftTeamsTeam"] = $recommendation.MicrosoftTeamsTeam
            $newitem["HubSite"] = $recommendation.HubSite
            $newitem["VivaEngageCommunity"] = $recommendation.VivaEngageCommunity
            $newitem.Update()
            $context.ExecuteQuery()

        }
        Write-Host "Added requirements and recommendation scores types to Recommendation Scoring list" -ForegroundColor Green

        # Adding templates to Teams Templates list
        $teamsTemplatesList = Get-PnPList $teamsTemplatesListName
        $context.Load($teamsTemplatesList)
        $context.ExecuteQuery()

        $global:teamsTemplatesListId = $teamsTemplatesList.Id

        # Delete existing teams templates items
        $teamsTemplatesItems = Get-PnPListItem -List $teamsTemplatesList

        foreach ($teamsTemplateItem in $teamsTemplatesItems) {
            Remove-PnpListItem -List $teamsTemplatesList -Identity $teamsTemplateItem -Force
        }

        $teamsTemplates = Import-Excel "$packageRootPath$settingsPath" -WorksheetName $teamsTemplatesWorksheetName
        foreach ($template in $teamsTemplates) {
            If (!$parameters.IsEdu.Value -and ($template.BaseTemplateId -eq "educationStaff" -or $template.BaseTemplateId -eq "educationProfessionalLearningCommunity")) {
                # Tenant is not an EDU tenant  - do nothing
            }
            else {
                $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
                $newItem = $teamsTemplatesList.AddItem($listItemCreationInformation)
                $newItem["Title"] = $template.Title
                $newItem["TemplateId"] = $template.TemplateId
                $newItem["TeamId"] = $template.TeamId
                $newItem["Description"] = $template.Description
                $newItem["AdminCenterTemplate"] = $template.AdminCenterTemplate
                $newitem.Update()
                $context.ExecuteQuery()
            }
        }

        Write-Host "Added templates to Teams Templates list" -ForegroundColor Green

        # Adding time zones to the Time Zones list
        $timeZonesList = Get-PnPList $timeZonesListName
        $context.Load($timeZonesList)
        $context.ExecuteQuery()

        # Delete existing time zone items
        $timeZoneItems = Get-PnPListItem -List $timeZonesList

        foreach ($timeZoneItem in $timeZoneItems) {
            Remove-PnpListItem -List $timeZonesList -Identity $timeZoneItem -Force
        }

        $timeZones = Import-Excel "$packageRootPath$settingsPath" -WorksheetName $timeZonesWorksheetName
        foreach ($timeZone in $timeZones) {
            $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $newItem = $timeZonesList.AddItem($listItemCreationInformation)
            $newItem["Title"] = $timeZone.Title
            $newItem["TimeZoneId"] = $timeZone.TimeZoneId
            $newitem.Update()
            $context.ExecuteQuery()
        }
        
        Write-Host "Added time zones to Time Zones list" -ForegroundColor Green

        # Adding locales to the Locales list
        $localesList = Get-PnPList $localesListName
        $context.Load($localesList)
        $context.ExecuteQuery()
 
        # Delete existing locale items
        $localeItems = Get-PnPListItem -List $localesList
 
        foreach ($localeItem in $localeItems) {
            Remove-PnpListItem -List $localesList -Identity $localeItem -Force
        }
 
        $locales = Import-Excel "$packageRootPath$settingsPath" -WorksheetName $localesWorksheetName
        foreach ($locale in $locales) {
            $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $newItem = $localesList.AddItem($listItemCreationInformation)
            $newItem["Title"] = $locale.Title
            $newItem["LCID"] = $locale.LCID
            $newitem.Update()
            $context.ExecuteQuery()
        }
         
        Write-Host "Added locales to Locales list" -ForegroundColor Green

        # Hide site template store field - site templates list
        $field = Get-PnPField -Identity "Store" -List "Site Templates"

        $field.SetShowInEditForm($false)
        $field.SetShowInNewForm($false)
        $field.SetShowInDisplayForm($false)
        $context.ExecuteQuery()

        # Hide site template store field - provisioning requests list
        $field = Get-PnPField -Identity "SiteTemplateStore" -List "Provisioning Requests"

        $field.SetShowInEditForm($false)
        $field.SetShowInNewForm($false)
        $field.SetShowInDisplayForm($false)
        $context.ExecuteQuery()

        # Hide space type internal field - provisioning requests list
        $field = Get-PnPField -Identity "SpaceTypeInternal" -List "Provisioning Requests"

        $field.SetShowInEditForm($false)
        $field.SetShowInNewForm($false)
        $field.SetShowInDisplayForm($false)
        $context.ExecuteQuery()

        # Get id of the ip labels list
        $ipLabelsList = Get-PnPList $ipLabelsListName
        $context.Load($ipLabelsList)
        $context.ExecuteQuery()
        $global:ipLabelsListId = $ipLabelsList.Id

        Write-Host "Configuring Service Account permissions"
        Add-PnPSiteCollectionAdmin -Owners $parameters.serviceAccountUPN.value

        Write-Host "Finished configuring site" -ForegroundColor Green

    }
    catch {
        throw('Failed to configure the SharePoint site {0}', $_.Exception.Message)
    }
}

# Get configured site classifications
function GetSiteClassifications {
    try {
        $groupDirectorySetting = AzureADPreview\Get-AzureADDirectorySetting | Where-Object DisplayName -eq "Group.Unified"
        $classifications = $groupDirectorySetting.Values | Where-Object Name -eq "ClassificationList" | Select-Object Value

        $global:siteClassifications = $classifications.Value
    }
    catch {
        throw('Failed to retrieve site classifications {0}', $_.Exception.Message)
    }
}

function UploadFiles ($context, $targetFolder, $sourcePath, $sourceFolder, $libraryName) {
    # Upload files into the folder
    $folder = $Web.GetFolderByServerRelativeUrl($targetFolder)
    $context.Load($folder)
    $context.ExecuteQuery() 

    Get-ChildItem (Join-Path $sourcePath $sourceFolder) | 
    Foreach-Object {
        $FileStream = New-Object IO.FileStream($_.FullName, [System.IO.FileMode]::Open)
        $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
        $FileCreationInfo.Overwrite = $true
        $FileCreationInfo.ContentStream = $FileStream
        $FileCreationInfo.URL = $_
        $Upload = $folder.Files.Add($FileCreationInfo)
        $context.Load($Upload)
        $context.ExecuteQuery()
        Write-Host "Uploaded $($_.FullName) to $libraryName" -ForegroundColor Green
    }
}


# Upload assets - Provisioning Type images to the Site Assets library
function UploadAssets {
    try {
        Write-Host "Uploading assets" -ForegroundColor Yellow
        $context = Get-PnPContext
        $web = $context.Web
        $context.ExecuteQuery()

        UploadFiles $context $imageFolderUpload $packageRootPath $imagesDir "Site Assets"
        UploadFiles $context $iconFolderUpload $packageRootPath $iconsDir "Site Assets"

        Write-Host "Uploaded files to Site Assets`n**PROVISION ASSIST SPO SITE CONFIGURATION COMPLETE**" -ForegroundColor Green
    }
    catch {
        throw('Failed to upload assets {0}', $_.Exception.Message)
    }
}

# Gets the azure ad app
function GetAzureADApp {
    param ($appName)

    $app = az ad app list --filter "displayName eq '$appName'" | ConvertFrom-Json

    return $app

}

function CreateAzureADAppSecret {
    try {
        Write-Host "### AZURE AD APP SECRET CREATION ###" -ForegroundColor Yellow

        # Check if the app already exists - script has been previously executed
        $app = GetAzureADApp $parameters.appName.Value

        if (-not ([string]::IsNullOrEmpty($app))) {

            $global:appId = $app.appId

            # Create a secret - this will autogenerate a password
            Write-Host "Azure AD App $($parameters.appName.Value) found..." -ForegroundColor Yellow

            Write-Host "Creating secret for Azure AD App - $($parameters.appName.Value)..." -ForegroundColor Yellow

            $secret = az ad app credential reset --id $global:appId
    
            $secretValue = $secret | ConvertFrom-Json | Select-Object password
    
            $global:appSecret = $secretValue.password

            # Get service principal id for the app
            $global:appServicePrincipalId = Get-AzADServicePrincipal -DisplayName $parameters.appName.Value  | Select-Object -ExpandProperty Id
            
            Write-Host "Created secret for app" -ForegroundColor Green
        } 
        else {

            throw("Azure AD App $($parameters.appName.Value)' does not exist. Please run the createadapp script first.")

        }

        Write-Host "### AZURE AD APP SECRET CREATION FINISHED ###" -ForegroundColor Green
    }
    catch {
        throw('Failed to create the secret for the Azure AD App {0}', $_.Exception.Message)
    }
}

function CreateAutomationRoleAssignments {
    # Create automation role assignments for AD app service principal if they do not already exist

    $jobOperatorRoleAssignment = Get-AzRoleAssignment -ObjectId $global:appServicePrincipalId -ResourceName $automationAccountName -ResourceType Microsoft.Automation/automationAccounts -ResourceGroupName $parameters.resourceGroupName.Value -RoleDefinitionName "Automation Job Operator"

    if($null -eq $jobOperatorRoleAssignment)
    {
        New-AzRoleAssignment -ObjectId $global:appServicePrincipalId -RoleDefinitionName "Automation Job Operator" -ResourceName $automationAccountName -ResourceType Microsoft.Automation/automationAccounts -ResourceGroupName $parameters.resourceGroupName.Value
    }

    $runbookOperatorRoleAssignment = Get-AzRoleAssignment -ObjectId $global:appServicePrincipalId -ResourceName $automationAccountName -ResourceType Microsoft.Automation/automationAccounts -ResourceGroupName $parameters.resourceGroupName.Value -RoleDefinitionName "Automation Runbook Operator"

    if($null -eq $runbookOperatorRoleAssignment)
    {
        New-AzRoleAssignment -ObjectId $global:appServicePrincipalId -RoleDefinitionName "Automation Runbook Operator" -ResourceName $automationAccountName -ResourceType Microsoft.Automation/automationAccounts -ResourceGroupName $parameters.resourceGroupName.Value

    }

}

function AssignManagedIdentityPermissions {
    # NEED TO ADD CODE TO CHECK IF THE PERMISSIONS EXIST FIRST

    try {
        Write-Host "Assigning SharePoint app role to managed identity" -ForegroundColor Yellow

        # Get service principal for the automation account
        $paAutoServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$($automationAccountName)'"

        $spoResource = Get-MgServicePrincipal -Filter "DisplayName eq 'Office 365 SharePoint Online'"

        # Get the app role we need to assign
        $spoFullControlAppRole = $spoResource.AppRoles | Where-Object {$_.value -eq 'Sites.FullControl.All'}

        # Get existing role assignments
        $roles = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $paAutoServicePrincipal.Id

         # Build the params
        $spoParams = @{
            "PrincipalId" = $paAutoServicePrincipal.Id 
            "ResourceId" = $spoResource.Id
            "AppRoleId" = $spoFullControlAppRole.Id
        }

        # Check that the role assigments do not already exist

        $existingRoleAssignment = $roles | Where-Object { $_.ResourceId -eq $spoResource.Id }

        if ($null -eq $existingRoleAssignment) {
            # Assign SharePoint app roles to the service principal
            New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $paAutoServicePrincipal.Id -BodyParameter $spoParams
        }

        Write-Host "Finished assigning SharePoint app role to managed identity" -ForegroundColor Green
    }
    catch {
        throw('Failed to assign graph and SharePoint app roles to the managed identity {0}', $_.Exception.Message)
    }
}


# Deploy ARM templates
function DeployARMTemplates {
    try { 
        # Deploy ARM templates
        Write-Host "Deploying api connections..." -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/apiconnections.json' --parameters "subscriptionId=$($parameters.subscriptionId.Value)" "tenantId=$($parameters.tenantId.Value)" "appId=$global:appId" "appSecret=$global:appSecret" "location=$($global:location)" "keyvaultName=$($parameters.keyVaultName.Value)"

        Write-Host "Finished deploying api connections..." -ForegroundColor Green
       
        Write-Host "Deploying logic apps..." -ForegroundColor Yellow

        Write-Host "ProcessGuests" -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/processguests.json' --parameters  "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "tenantId=$($parameters.tenantId.Value)" "location=$($global:location)"

        Write-Host "CheckSiteExists" -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/checksiteexists.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "spoTenantName=$($parameters.spoTenantName.Value).sharepoint.com" "location=$($global:location)"
        
        Write-Host "ProcessProvisionRequest" -ForegroundColor Yellow
        
        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/processprovisionrequest.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "tenantId=$($parameters.tenantId.Value)" "automationAccountName=$automationAccountName" "requestsSiteUrl=$requestsSiteUrl" "requestsListId=$global:requestsListId" "location=$($global:location)" "requestsSettingsListId=$global:requestsSettingsListId" "tenantName=$($parameters.spoTenantName.Value)" "serviceAccountUPN=$($parameters.serviceAccountUPN.value)"
    
        Write-Host "SyncGroupSettings" -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/syncgroupsettings.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "tenantId=$($parameters.tenantId.Value)" "requestsSiteUrl=$requestsSiteUrl" "location=$($global:location)" "requestsSettingsListId=$global:requestsSettingsListId"

        Write-Host "GetSiteTemplates" -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/getsitetemplates.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "requestsSiteUrl=$requestsSiteUrl" "location=$($global:location)" "siteTemplatesListId=$global:siteTemplatesListId" "automationAccountName=$automationAccountName"
        
        Write-Host "GetHubSites" -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/gethubsites.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "tenantId=$($parameters.tenantId.Value)" "tenantName=$($parameters.spoTenantName.Value)" "requestsSiteUrl=$requestsSiteUrl" "location=$($global:location)" "hubSitesListId=$global:hubSitesListId"
        
        Write-Host "SyncLabels" -ForegroundColor Yellow
        
        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/synclabels.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "tenantId=$($parameters.tenantId.Value)" "location=$($global:location)" "requestsSiteUrl=$requestsSiteUrl" "ipLabelsListId=$global:ipLabelsListId"

        Write-Host "GetTeamsTemplates" -ForegroundColor Yellow

        az deployment group create --resource-group $parameters.resourceGroupName.Value --subscription $parameters.subscriptionId.Value --template-file '../ARMTemplates/LogicApps/getteamstemplates.json' --parameters "resourceGroupName=$($parameters.resourceGroupName.Value)" "subscriptionId=$($parameters.subscriptionId.Value)" "requestsSiteUrl=$requestsSiteUrl" "location=$($global:location)" "teamsTemplatesListId=$global:teamsTemplatesListId" "tenantId=$($parameters.tenantId.Value)"
        
        Write-Host "Finished deploying logic apps" -ForegroundColor Green
    }
    catch {
        throw('Failed to deploy the Azure resources {0}', $_.Exception.Message)
    }
}

#Check that the provided location is a valid Azure location
function ValidateAzureLocation {

    try {
        $locations = Get-AzLocation
    
        $global:location = $parameters.region.Value.Replace(" ", "").ToLower()

        # Validate that the location exists
        if ($null -eq ($locations | Where-Object Location -eq $global:location)) {
            throw "Invalid Azure Location. Please provide a valid location. See this list - https://azure.microsoft.com/en-gb/global-infrastructure/services/?products=automation&regions=all"

        }
    
        # Validate that the region supports Automation and Logic Apps (https://azure.microsoft.com/en-gb/global-infrastructure/services/?products=automation&regions=all)
        If (($global:location -eq "southafricawest") -or ($global:location -eq "australiacentral2") -or ($global:location -eq "australiacentral") -or ($global:location -eq "southafricawest") -or ($global:location -eq "canadaeast") -or ($global:location -eq "chinaeast") -or ($global:location -eq "germanynorth") -or ($global:location -eq "southindia") `
                -or ($global:location -eq "francesouth") -or ($global:location -eq "westindia") -or ($global:location -eq "japaneast") -or ($global:location -eq "koreasouth") -or ($global:location -eq "switzerlandnorth") -or ($global:location -eq "switzerlandnwest") -or ($global:location -eq "uaecentral") -or ($global:location -eq "uaenorth") -or ($global:location -eq "norwaywest") -or ($global:location -eq "germanywestcentral")) {
     
            throw "Azure location does not support Automation and/or Logic Apps. See this list for regions which support Automation - https://azure.microsoft.com/en-gb/global-infrastructure/services/?products=automation&regions=all"
     
        }
    }
    catch {
        throw('Failed to validate Azure location {0}', $_.Exception.Message)
    }
}

# Check that the Key Vault does not already exist and ensure the name is valid
function ValidateKeyVault {
    try {
        Write-Host "Checking for availability of Key Vault..." -ForegroundColor Yellow

        $availabilityResult = $null

        $availabilityParams = @{
            Name               = $parameters.keyVaultName.Value
            ServiceType        = 'KeyVault'
            AuthorizationToken = Get-AccessTokenFromCurrentUser
            SubscriptionId     = $parameters.subscriptionId.Value
        }
    
        $availabilityResult = Test-AzNameAvailability @availabilityParams

        if ($availabilityResult.Available) {
            Write-Host "Key Vault is available." -ForegroundColor Green
        }

        if ($availabilityResult.Reason -eq "AlreadyExists") {

            #Check if the key vault exists in this subscription
            $keyVault = Get-AzKeyVault -Name $parameters.keyVaultName.Value

            if ($null -ne $keyVault) {
                Write-Host "Key Vault already exists in this Azure subscription. Do you wish to use it? THIS WILL OVERWRITE THE KEY VAULT AND REMOVE ANY EXISTING CONFIGURATIONS INCLUDING ROLE ASSIGNMENTS." -ForegroundColor DarkYellow
                $update = Read-Host " ( y (yes) / n (exit) ) "
                if ($update -ne "y") {
                    Write-Host "Script terminated. Please specify a different Key Vault name or choose to use the existing Key Vault when re-executing the script." -ForegroundColor Red
                    break
                }
                else {
                    Write-Host "Existing Key Vault $($parameters.keyVaultName.Value) will be used." -ForegroundColor Yellow
            
                }   
            }
            else {
                throw "Key Vault already exists in another Azure subscription. Please specify a different name."
            }
        }

        if ($availabilityResult.reason -eq "Invalid") {
    
            throw $availabilityResult.message
        } 
    }
    catch {
        throw('Failed to validate availability of the key vault {0}', $_.Exception.Message)
    }

}

$ErrorActionPreference = "stop"

Write-Host "###  DEPLOYMENT SCRIPT STARTED `n(c) Microsoft Corporation ###" -ForegroundColor Magenta

# Verify required PS Modules
Write-Host "Verifying installation of required PowerShell Modules..." -ForegroundColor Yellow
VerifyModules
Write-Host "Required modules are installed" -ForegroundColor Green

# Load Parameters from json file
$parametersListContent = Get-Content '.\parameters.json' -ErrorAction Stop

# Validate all the parameters.
Write-Host "Validating all the parameters from parameters.json" -ForegroundColor Yellow
$parameters = $parametersListContent | ConvertFrom-Json
if (-not(ValidateParameters)) {
    Write-Host -message "Invalid parameters found. Please update the parameters in the parameters.json with valid values and re-run the script." -ForegroundColor Red
    EXIT
}

Write-Host "Parameters are valid" -ForegroundColor Green

Write-Ascii -InputObject "Provision Assist" -ForegroundColor Green

$tenantUrl = "https://$($parameters.spoTenantName.Value).sharepoint.com"
$requestsSiteAlias = $parameters.requestsSiteName.Value -replace (' ', '')
$requestsSiteUrl = "https://$($parameters.spoTenantName.Value).sharepoint.com/$($parameters.managedPath.Value)/$requestsSiteAlias"

# Initialise connections - Azure Az/CLI
Write-Host "Launching Azure sign-in..." -ForegroundColor Yellow
# Clear the az context before we login
#Clear-AzContext -Force
$azConnect = Connect-AzAccount -Subscription $parameters.subscriptionId.Value -Tenant $parameters.tenantId.Value
ValidateKeyVault
ValidateAzureLocation
Write-Host "Launching Azure AD sign-in..." -ForegroundColor Yellow
AzureADPreview\Connect-AzureAD
Write-Host "Launching Azure CLI sign-in..." -ForegroundColor Yellow
$cliLogin = az login
Write-Host "Connected to Azure" -ForegroundColor Green

# Connect to Microsfot Graph

# Define the scopes to use
$scopes = @("AppRoleAssignment.ReadWrite.All", "Application.Read.All", "Directory.Read.All")

# Connect to Microsoft Graph using the specified scopes
Write-Host "Launching Microsoft Graph sign-in...please consent"
Connect-MgGraph -Scopes $scopes
Write-Host "Connected to Microsoft Graph" -ForegroundColor Green

# Connect to PnP
Write-Host "Launching PnP sign-in..." -ForegroundColor Yellow
Connect-PnPOnline -Url "https://$($parameters.spoTenantName.Value)-admin.sharepoint.com" -Interactive
Write-Host "Connected to SPO" -ForegroundColor Green

CreateAzureADAppSecret
GetSiteClassifications
CreateRequestsSharePointSite
# Connect to the new site
Connect-PnPOnline $requestsSiteUrl -Interactive
ConfigureSharePointSite
UploadAssets

Write-Host "### AZURE RESOURCES DEPLOYMENT ###`nStarting Azure resources deployment..." -ForegroundColor Yellow

# Create resource group
# Handle spaces in resource group name
$parameters.resourceGroupName.Value = $parameters.resourceGroupName.Value.Replace(" ", "")
Write-Host "Creating resource group $($parameters.resourceGroupName.Value)..." -ForegroundColor Yellow
New-AzResourceGroup -Name $parameters.resourceGroupName.Value -Location $global:location
Write-Host "Created resource group" -ForegroundColor Green
Write-Host "Deploying Azure resources" -ForegroundColor Yellow

If ($parameters.enableSensitivity.Value) {
    Write-Host "You chose to enable the sensitivity label functionality. Make sure the Service Account you use does NOT have MFA enabled." -ForegroundColor Yellow

    # Add service account credentials to key vault (Required for sensitivity label functionality due to the current Graph API restriction only supporting delegated permissions)
    $saCreds = Get-Credential -Message "Enter Service Account credentials (To enable sensitivity label functionality). Must NOT have MFA enabled."
    $saUsername = $saCreds.UserName
    $saPassword = $saCreds.GetNetworkCredential().password
}

Write-Host "Deploying key vault and automation account..." -ForegroundColor Yellow
az deployment group create --resource-group $parameters.resourceGroupName.Value --template-file "../ARMTemplates/azureresources.bicep" --parameters "tenantId=$($parameters.tenantId.Value)" "appClientId=$($global:appId)" "appSecret=$($global:appSecret)" "logoUrl=$($parameters.logoUrl.Value)" "keyVaultName=$($parameters.keyVaultName.Value)" "appServicePrincipalId=$($global:appServicePrincipalId)" "saUsername=$($saUsername)" "saPassword=$($saPassword)"
CreateAutomationRoleAssignments
AssignManagedIdentityPermissions
Write-Host "Finished deploying key vault and automation account..." -ForegroundColor Green

DeployARMTemplates

Write-Host "Azure resources deployed`n### AZURE RESOURCES DEPLOYMENT COMPLETE ###" -ForegroundColor Green
Write-Host "### DEPLOYMENT COMPLETED SUCCESSFULLY ###" -ForegroundColor Green
Write-Host "### Don't forget to authorise the API Connections in the Azure Portal. ###" -ForegroundColor Green