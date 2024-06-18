#Runbook to add new domains to the allowed domains list - for use with the Provision Assist solution
[CmdletBinding()]
Param
(
    [Parameter (Mandatory = $true)]
    [String] $siteUrl,
    [string]$domains
)

$tenantName = $siteUrl.Substring(0, $siteUrl.IndexOf(".")).Replace("https://", "")

try {
    #Connect to spo tenant
    Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity

    #Check connection
    $context = Get-PnPContext
    if ($context) {
        Write-Output "Connected to SharePoint Online"

        #Get the current allowed domains
        $allowedDomains = Get-PnPTenant | Select-Object -ExpandProperty SharingAllowedDomainList

        $allowedDomainsCollection = $allowedDomains -split " "

        #Loop through domains to add and add them to the allowed domains list
        ForEach ($domain in $domains.Split(",")) {
            if ($allowedDomainsCollection -notcontains $domain) {
                Write-Host "Adding $domain to the allowed domains list"
                $allowedDomains += " $domain"
            }
        }

        Set-PnPTenant -SharingAllowedDomainList $allowedDomains

        Write-Output "Domain configuration successful"
    }
    else {
        Write-Error "Issue connecting to SharePoint Online"
    }
}
catch {
    #Script error
    Write-Error "An error occured: $($PSItem.ToString())"
}

