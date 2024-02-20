#Runbook to configure collaboration spaces post provisioning - for use with the Provision Assist solution
[CmdletBinding()]
Param
(
    [Parameter (Mandatory = $false)]
    [String] $siteUrl,
    [String] $spaceType,
    [String] $externalSharing,
    [String] $owners,
    [String] $members,
    [String] $visitors,
    [String] $visibility,
    [String] $classification,
    [String] $joinHub,
    [String] $hubSiteId,
    [String] $timeZoneId,
    [String] $lcid,
    [bool] $enableAllowAccessRequests,
    [String] $defaultExternalSharingSetting,
    [Int] $storageQuota,
    [Int] $storageQuotaWarning,
    [bool] $syncHubPermissions,
    [bool] $disableDocSync,
	[String] $retentionLabel,
	[String] $featuresToActivate,
	[String] $applyPnPTemplate,
	[String] $pnpTemplateUrl,
	[String] $themeName,
	[String] $siteTemplateTitle,
	[String] $siteCollectionAdmins,
    [String] $siteDesignId
)

$logoUrl = Get-AutomationVariable -Name "logoUrl"
$tenantName = $siteUrl.Substring(0, $siteUrl.IndexOf(".")).Replace("https://", "")

function SetSiteLogo {
    if ($spaceType -ne "Office 365 Group" -and $logoUrl -ne "") {
        Write-Output "Setting site logo"
        Set-PnPWeb -SiteLogoUrl $logoUrl
        Write-Output "Finished setting site logo"
    }
}

function AddOwners {
    if ($spaceType -ne "Office 365 Group") {
        Write-Output "Updating SP owners group"
		$group = Get-PnPGroup | Where-Object { $_.Title -like "*Owners" }
        ForEach ($owner in $owners -split ",") {
            #Get the group
            Add-PnPGroupMember -LoginName $owner -Identity $group
        }

}
}

function AddMembers {
    If ($members -ne "" -and $spaceType -ne "Office 365 Group") {
        Write-Output "Updating SP members group"
        ForEach ($member in $members -split ",") {
            #Get the group
            $group = Get-PnPGroup | Where-Object { $_.Title -like "*Members" }
            Add-PnPGroupMember -LoginName $member -Identity $group
        }

        Write-Output "Finished updating SP members group"
    }
}

function AddVisitors {
    If ($visitors -ne "") {
        Write-Output "Updating SP visitors group"
        ForEach ($visitor in $visitors -split ",") {
            #Get the group
            $group = Get-PnPGroup | Where-Object { $_.Title -like "*Visitors" }
            Add-PnPUserToGroup -LoginName $visitor -Identity $group
        }

        Write-Output "Finished updating SP visitors group"
    }
}

function AddSiteCollectionAdmins {
    if ($spaceType -ne "Office 365 Group") {
        Write-Output "Adding Site Collection Administrators"
        ForEach ($sca in $siteCollectionAdmins -split ",") {
            #Add the sca
			Add-PnPSiteCollectionAdmin -Owners $sca
        }
        Write-Output "Finished adding Site Collection Administrators"
    }
}

function SetExternalSharing {
    If ($externalSharing -eq "True") {

        Write-Output "External sharing is required - configuring sharing settings"

        Switch ($defaultExternalSharingSetting) {

            "NewExistingGuests" {  
                Set-PnPTenantSite -Url $siteUrl -SharingCapability ExternalUserSharingOnly

            }

            "Anyone" {
                Set-PnPTenantSite -Url $siteUrl -SharingCapability ExternalUserAndGuestSharing
            }

            "ExistingGuests" {
                Set-PnPTenantSite -Url $siteUrl -SharingCapability ExistingExternalUserSharingOnly
            }
			
        }

        Write-Output "Finished configuring sharing settings"
    }
}

function SetAccessRequestSettings {
    #Disable access requests if visibility set to private
    If ($visibility -eq "Private" -and $enableAllowAccessRequests -eq $false) {
        Write-Output "Disabling access requests"
        $ctx = Get-PnPContext
        $ctx.Web.RequestAccessEmail = ""
        $ctx.ExecuteQuery()
        Write-Output "Finished disabling access requests"
    }
}

function SetSiteClassification {
    If ($spaceType -ne "Office 365 Group") {
        If ($null -ne $classification) {
            Set-PnPSite -Classification $classification
        }
    }
}

function JoinOrRegisterHubSite {
    #Join hub site if space type is not a hub
    if ($joinHub -eq $true -and $spaceType -ne "Hub Site") {
        Write-Output "Joining hub site"
        Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity

        #Get hub site url
        $hubSite = Get-PnPHubSite | Where-Object SiteId -eq $hubSiteId | Select-Object -Property SiteUrl
        Add-PnPHubSiteAssociation -Site $siteUrl -HubSite $hubSite.SiteUrl

        Write-Output "Finished joining hub site"
    }
    else {
        
        #Register as a hub site
        if ($spaceType -eq "Hub Site") {
        
            try {
                Write-Output "Registering site as a hub"
                Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity
                Register-PnPHubSite -Site $siteUrl
                Write-Output "Finished registering site as a hub"

                if($syncHubPermissions)
                {
                    Write-Output "Enabling hub permissions sync"
                    Set-PnPHubSite -Identity $siteUrl -EnablePermissionsSync
                    Write-Output "Finished enabling hub permissions sync"
                }
            }
            catch {
                Write-Output $_.Exception.Message
            }
        }
    }
}

function SetRegionalSettings {
    #Set regional settings for the site
    Write-Output "Setting regional settings"
    $web = Get-PnPWeb -Includes RegionalSettings, RegionalSettings.TimeZones
    $timeZone = $web.RegionalSettings.TimeZones | Where-Object { $_.Id -eq $timeZoneId }
    $web.RegionalSettings.LocaleId = $lcid
    $web.RegionalSettings.TimeZone = $timeZone
    $web.Update()
    Invoke-PnPQuery
    Write-Output "Finished setting regional settings"
} 

function SetStorageQuota {

    If ($storageQuota -ne 0 -and $storageQuotaWarning -ne 0) {
        Write-Output "Setting site storage quota"

        Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity
        Set-PnPTenantSite -Url $siteUrl -StorageMaximumLevel $storageQuota -StorageWarningLevel $storageQuotaWarning

        Write-Output "Finished setting storage quota"
    }

}

function DisableDocumentSync {

    if ($disableDocSync) {
        Write-Output "Disabling sync option in Shared Documents library"

        $list = Get-PnPList "Shared Documents"
 
        #Exclude List or Library from Sync
        $List.ExcludeFromOfflineClient = $true
        $List.Update()
        Invoke-PnPQuery

        Write-Output "Finished disabling sync option"
    }

}

function SetRetentionLabel {
	if($retentionLabel -ne "") {
		Write-Output "Setting retention label $retentionLabel on Shared Documents library"

		$list = Get-PnPList "Shared Documents"

		Set-PnPLabel -List $list -Label $retentionLabel

		Write-Output "Finished setting retention label"
	}
}

function ActivateFeatures {
	If($featuresToActivate -ne "") {
		Write-Output "Activating features"

		$ctx = Get-PnPContext
		$site = $ctx.Site
		$ctx.Load($site)
		$ctx.ExecuteQuery()

		$web = $ctx.Web
		$ctx.Load($web)
		$ctx.ExecuteQuery()

		# Check if we are activating a web feature - need to activate the push notifications feature first to prevent an error
		if($featuresToActivate.ToLower().Contains('web')) {

			$featureId = "41e1d4bf-b1a2-47f7-ab80-d5d6cbba3092"

			$web.Features.Add($featureId, $force, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None)
			$ctx.ExecuteQuery()

		}

		ForEach ($feature in $featuresToActivate -split ",") {

			$featureId = $feature.Substring($feature.IndexOf(':') + 1)

			If($feature.ToLower().StartsWith("web")) {
				Write-Output "Activating web feature $featureId"
			
				$web.Features.Add($featureId, $force, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None)
				$ctx.ExecuteQuery()

				Write-Output "Activated web feature $featureId"
			}
			
			If($feature.ToLower().StartsWith("site")) {
				Write-Output "Activating site feature $featureId"

				$site.Features.Add($featureId, $force, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::Farm)
				$ctx.ExecuteQuery()

				Write-Output "Activated site feature $featureId"
			}

		}

		Write-Output "Finished activating features"

	}
}

function ApplyPnPTemplate {

	if($applyPnPTemplate -eq $true) {
		Write-Output "Applying PnP template"

		#Apply the template
		Invoke-PnPSiteTemplate -Path $pnpTemplateUrl -ClearNavigation

		Write-Output "Finished applying PnP template"
	}

}

function ApplyTheme {
	if($themeName -ne "") 
	{
		Write-Output "Applying $themeName theme"

		#Apply the theme
		Set-PnPWebTheme -Theme $themeName

		Write-Output "Finished applying theme"
		
	}
}

function ApplySiteDesign {
    # Reapply site design if we have applied a PnP template
    if ($applyPnPTemplate -eq $true -and $siteDesignId -ne $null)
    {
        Write-Output "Applying site design"

        Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity
        Invoke-PnPSiteDesign -Identity $siteDesignId -WebUrl $siteUrl

        Write-Output "Finished applying site design"
    }
}

try {

    #Connect to spo
    Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity

    #Check connection
    $context = Get-PnPContext
    if ($context) {
        Write-Output "Connected to SharePoint Online"

        if ($spaceType -ne "Viva Engage Community") {

            SetExternalSharing

            Connect-PnPOnline -Url $siteUrl -ManagedIdentity

            AddOwners
            AddMembers
            AddVisitors
			AddSiteCollectionAdmins
            SetAccessRequestSettings
            SetSiteLogo
            SetRegionalSettings
			ActivateFeatures
			ApplyPnPTemplate
			ApplyTheme
            DisableDocumentSync
			SetRetentionLabel
            SetSiteClassification
            JoinOrRegisterHubSite
            SetStorageQuota
            ApplySiteDesign

            Write-Output "Site configuration successful"

        }
        else {
            Write-Output "Site configuration not required"
        }
    
    }
    else {
        Write-Error "Issue connecting to SharePoint Online"
    }
}
catch {
    #Script error
    Write-Error "An error occured: $($PSItem.ToString())"
}
