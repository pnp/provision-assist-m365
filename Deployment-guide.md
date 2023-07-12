# Deployment guide

## Prerequisites

To begin, you will need:

- Power Apps and Power Automate (seeded licenses) enabled and rolled out across your organisation.
- Billable Azure Subscription in the same tenant to which you will deploy Provision Assist.
- Service account (used by Logic Apps to connect to SPO, Outlook and Teams) with an appropriate Microsoft 365 license (This account should NOT be an admin).
- Windows 10/11 machine on which to execute the PowerShell deployment script.
- Azure CLI (Command Line Interface) - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli.
- Firewall/Proxy configured to allow connectivity using the Azure CLI - please test the 'az login' cmdlet works before proceeding.
 - Global Administrator (to execute the `createazureadapp.ps1` script).
 - A user account with **Owner** rights to the Azure Subscription that is also a SharePoint, Power Platform and Teams Administrator. 

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

 ## Step 3: Execute the scripts

### Azure AD App Creation

The first step is to execute the dedicated script response for creating the Azure AD app and granting admin consent for the Microsoft Graph API permissions. 

**This part of the deployment requires a user account with Global Administrator access.**

1. Launch a PowerShell window as an Administrator.
2. Navigate to the 'Scripts' folder.
3. Execute the createazureadapp script in the PowerShell window - ```.\createazureadapp.ps1```
4. Enter a name for the Azure AD app when prompted (**This must be the same name as the 'appName' parameter in the parameters.json file**).
5. Wait for the script to complete.

### Deployment of Researches

The next step of deployment is to execute the deploy script.

**Ensure the account you are using at this stage has owner rights to the Azure Subscription and is also a SharePoint Administrator.**

As the script uses various PowerShell modules to perform deployment, it will prompt for authentication a number of times.

1. Launch a PowerShell window as an Administrator.
2. Navigate to the 'Scripts' folder.
3. Execute the deploy script in the PowerShell window - ```.\deploy.ps1```

During installation PnP Management Shell will request permissions for the application on behalf of your organization. Please grant consent. You will be able to revoke that access after the deployment of the solution.

If you chose to enable the Sensitivity Label functionality, a dialog will be displayed prompting for the password for the Service Account. Please complete the prompt.

When the message **"DEPLOYMENT COMPLETED SUCCESSFULLY** is displayed, move onto the next stage of the deployment.

**If the script fails for any reason, it can be re-executed as many times as require without the need to delete any resources**

 ## Step 4: Register Azure AD app as a SharePoint add-in

 The Azure AD Application must be registered as a SharePoint add-in. This is required for the solution to perform various operations against the SharePoint tenant such as checking if a given SharePoint site already exists in the tenant recycle bin, as well as retrieving a list of Hub Sites/Site Templates and more.

 **IMPORTANT**

 This solution relies on ACS to work which has been retired but is still available. For tenants created **after August 2020**, the option to use an ACS app-only token is disabled and this **MUST be enabled** to work. More details can be found here - Granting access using SharePoint App-Only 

Before proceeding with the below, enable ACS on the tenant by carrying out the following -

Using the SharePoint Online Management Shell, connect to your SharePoint tenant

Run the following cmdlet -

```Set-SPOTenant -DisableCustomAppAuthentication $false```

Wait approximately 1 hour to allow this setting to be applied.

**Registering SharePoint add-in**

1. Navigate to the following page in the SharePoint Admin Center - https://contoso-admin.sharepoint.com/_layouts/15/appinv.aspx  and enter the following information (replace contoso with the name of your tenant):

App Id: Application ID of the Azure AD app (Locate the Azure AD app created by the createazureadapp script in Azure Active Directory [https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade ] and copy the Application ID).

2. Click 'Lookup'.
3. In the 'App Domain' text box, enter a suitable domain. You can specify any domain you want but do not include protocols (https) or slashes(/). For example you can use your companies SharePoint URL e.g. contoso.sharepoint.com .
4. In the App's Permissions Request XML text box, enter the following XML:

```<AppPermissionRequests AllowAppOnlyPolicy="true"> <AppPermissionRequest Scope="http://sharepoint/content/tenant" Right="FullControl" /> </AppPermissionRequests>```

5. Click 'Create'.
6. Click 'Trust It'.

 ## Step 5 (Optional): Create Admin Group/Team

Approval of requests in the solution can take place in two ways -

- Power Automate Approval action (Approval Email and Approvals app in Teams).
- Microsoft Teams Adaptive Card Approval (Adaptive card posted into a Teams channel).

If you wish to use the adaptive card approval method then please proveed with the below. 
