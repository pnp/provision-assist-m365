# Deployment guide

## Prerequisites

To begin, you will need:

- Power Apps and Power Automate (seeded licenses) enabled and rolled out across your organisation.
- Billable Azure Subscription in the same tenant to which you will deploy Provision Assist.
- Service account (used by Logic Apps to connect to SPO, Outlook and Teams) with an appropriate Microsoft 365 license (This account should NOT be an admin).
- Windows 10/11 machine on which to execute the PowerShell deployment script.
- Azure CLI (Command Line Interface) - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli.
- Firewall/Proxy configured to allow connectivity using the Azure CLI - please test the 'az login' cmdlet works before proceeding.

#### PowerShell Modules

The following PowerShell modules are used by the deployment script and must be installed before executing the script:

- PnP.PowerShell (We do not support v2 - please install the latest v1 version)
- Az
- AzureADPreview
- ImportExcel
- WriteAscii

## Step 1: Configuring PowerShell

1. Download the latest release of Provision Assist.
2. Launch PowerShell as an Administrator.
3. Set the PowerShell Execution Policy to 'Unrestricted' by running the following cmdlet - ```Set-ExecutionPolicy -ExecutionPolicy unrestricted```

## Step 2: Updating Parameters.json file

You will find a parameters.json file in the Scripts folder. Please update all the parameters with the correct values for your tenant.

Replace `<<value>>` with appropriate values for all required parameters. 

You may refer to the following to understand each parameter:

- `tenantId` - Id of the tenant to deploy to. Can be found in the Azure Active Directory blade.

- `spoTenantName` - Name of the SharePoint tenant excluding .sharepoint.com e.g. `contoso`.

- `requestsSiteName` - Name of the SharePoint site to store requests made by users, can include spaces (URL/Alias automatically generated). If the site exists, it will prompt to overwrite and will apply the PnP provisioning template.

- `requestsSiteDesc` - Description of the site that will be created above.

- `managedPath ` - Managed path configured in the tenant e.g. 'sites' or 'teams' (no forward slash).

- `subscriptionId` - Azure subscription to deploy the solution to (MUST be associated with the Azure AD of the Microsoft 365 tenant that you wish to deploy this solution to).

- `region` - Azure region in which to create the resources. The internal name should be used e.g. `uksouth`. The location MUST support Automation and Logic Apps. See [Valid Azure locations](https://azure.microsoft.com/en-gb/explore/global-infrastructure/products-by-region/?products=logic-apps%2Cautomation&regions=all).

- `resourceGroupName` - Name for a new resource group to deploy the solution to - the script will create this resource group.

 - `appName` - Name for the Azure AD app that will be created e.g. `ProvisionAssist`.

- `siteLogoPath` (**Optional)** - Path to a company logo (ideally stored in SharePoint) that all users can access to set as the logo for created sites. Please ensure this path is to an image, if you don't have an image leave this blank.

- `serviceAccountUPN` - UPN of Service Account to be used for the solution - used to connect the Logic App API connections. Service account should be a standard Microsoft 365 user who has SPO/Exchange/Teams licenses enabled. Refer to [Assign licenses to users](https://docs.microsoft.com/en-us/microsoft-365/admin/manage/assign-licenses-to-users?view=o365-worldwide) for more details.

- `isEdu` - Specifies whether the current tenant is an Education tenant. If set to true, the Education Teams Templates will be deployed. These will be skipped if set to false or left blank

- `KeyVaultName` - Name to use for the Key Vault that is provisioned by the deployment script. The Key Vault stores the app id and secret of the Azure AD app that this solution uses. This ensures that these are held securely. The name of the key vault must be unique across the Azure region that you are deploying to. If a key vault matching the name provided exists ***in*** the current subscription, it can be used. The script will validate that the name is available and if not, an alternative name will need to be provided.

 - `enableSensitivity` - Enable the Sensitivity Label functionality. Note - this will require you to have a Service Account with NO MFA, this can be the same service account as above if you wish.

 ## Step 3: Execute the script






