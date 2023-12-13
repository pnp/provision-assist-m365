# Deployment guide

## Prerequisites

To begin, you will need:

- Power Apps and Power Automate (seeded licenses) enabled and rolled out across your organisation.
- Power Apps environment with a Dataverse database deployed. You may use the default environment, however a production environment is recommended. If you do not have capacity to create a Dataverse database, you may need to use the default environment.
- Billable Azure Subscription in the same tenant to which you will deploy Provision Assist.
- Service account (used by Logic Apps to connect to SPO, Outlook and Teams) with an appropriate Microsoft 365 license (This account should NOT be an admin). This account CAN have MFA.
- Service account for sensitivity label functionality (applying sensitivity labels), if you wish to use it. This can be the same account as the above if you wish however at the time of writing this account CANNOT use MFA due to restrictions in the Microsoft Graph. 
- Windows 10/11 machine on which to execute the PowerShell deployment script.
- Azure CLI (Command Line Interface) - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli.
- Firewall/Proxy configured to allow connectivity using the Azure CLI - please test the 'az login' cmdlet works before proceeding.
 - Global Administrator (to execute the `createazureadapp.ps1` script and authorize PnP PowerShell).
 - A user account with **Owner** rights to the Azure Subscription that is also a SharePoint, Power Platform and Teams Administrator. 
 - A certificate (self-signed is ok) to use for Microsoft Graph and SharePoint REST API authentication (**Optional** as the deployment script will create a self-signed cert for you if preffered). 

#### PowerShell Modules

The following PowerShell modules are used by the deployment script and must be installed before executing the script:

- PnP.PowerShell (We do not support v2 - please install the latest v1 version)
- Az
- AzureADPreview
- ImportExcel
- WriteAscii
- Microsoft.Graph

Once installed, please perform the following steps to 'authorize' the PnP Management Shell (PnP PowerShell). PnP now uses an Azure AD app registration to carry out operations, this requires the consent of a **Global Administrator** and must be performed BEFORE the main deployment script can be executed.

1. Launch PowerShell as an Administrator (Global Administrator).
2. Connect to your SharePoint admin center by running the following cmdlet - ```Connect-PnPOnline -Url https://contoso-admin.sharepoint.com``` (replace contoso with your tenant name).
3. Check the 'Consent on behalf of your organization' checkbox and click 'Accept', wait for the cmdlet to finish. 
4. Close the PowerShell window.

![PnP powershell consent screenshot](/Images/PnPPowerShellConsent.png)

You can delete this Azure AD app registration AFTER deployment of Provision Assist is completed if you wish.

## Step 1: Configuring PowerShell

1. Download the [latest release](https://github.com/pnp/provision-assist-m365/releases/latest) of Provision Assist.
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

 - `createSelfSignedCert` - Specifies whether to create a self-signed certificate as part of the deployment. If set to true, a self-signed cert will be created through the Azure CLI with the name specified in the 'certName' parameter.

 - `certName` - Name for the self-signed certificate e.g. 'provisionassist'. If you are creating your own certificate, this parameter is still mandatory and should match the name of your certificate.

 - `certValidityDays` - Number of days that the certificate is valid for (if 'createSelfSignedCert' is set to true). The default is 365 days.

- `siteLogoPath` (**Optional)** - Path to a company logo (ideally stored in SharePoint) that all users can access to set as the logo for created sites. Please ensure this path is to an image, if you don't have an image leave this blank.

- `serviceAccountUPN` - UPN of Service Account to be used for the solution - used to connect the Logic App API connections. Service account should be a standard Microsoft 365 user who has SPO/Exchange/Teams licenses enabled. Refer to [Assign licenses to users](https://docs.microsoft.com/en-us/microsoft-365/admin/manage/assign-licenses-to-users?view=o365-worldwide) for more details.

- `isEdu` - Specifies whether the current tenant is an Education tenant. If set to true, the Education Teams Templates will be deployed. These will be skipped if set to false or left blank

- `KeyVaultName` - Name to use for the Key Vault that is provisioned by the deployment script. The Key Vault stores the app id and secret of the Azure AD app that this solution uses. This ensures that these are held securely. The name of the key vault must be unique across the Azure region that you are deploying to. If a key vault matching the name provided exists ***in*** the current subscription, it can be used. **PLEASE NOTE - IF YOU USE AN EXISTING KEY VAULT, IT WILL BE OVERWRITTEN AND CONFIGURATION SUCH AS ROLE ASSIGNMENTS WILL BE LOST. WE RECOMMEND USING A DEDICATED KEY VAULT FOR PROVISION ASSIST**. The script will validate that the name is available and if not, an alternative name will need to be provided.

 - `enableSensitivity` - Enable the Sensitivity Label functionality. Note - this will require you to have a Service Account with NO MFA, this can be the same service account as above if you wish.

 - `skipApplySPOTemplate` - Skip applying the PnP template to the SharePoint site. Leave **false** unless you have a specific reason to skip this.

 ## Step 3: Execute the scripts

### Azure AD App Creation

The first step is to execute the dedicated script responsible for creating the Azure AD app and granting admin consent for the Microsoft Graph API permissions. 

**This part of the deployment requires a user account with Global Administrator access.**

1. Launch a PowerShell window as an Administrator.
2. Navigate to the 'Scripts' folder.
3. Execute the createazureadapp script in the PowerShell window - ```.\createazureadapp.ps1```
4. Enter a name for the Azure AD app when prompted (**This must be the same name as the 'appName' parameter in the parameters.json file**).
5. Wait for the script to complete.

### Deployment of Resources

The next step of deployment is to execute the deploy script.

**Ensure the account you are using at this stage has owner rights to the Azure Subscription and is also a SharePoint Administrator.**

**The deployment script generates a secret for the AD app created above. The default expiry period for this secret is to 1 year, for details on how refresh the secret when it expires, see [Refreshing app secret](./Refreshing-app-secret.md).**

As the script uses various PowerShell modules to perform deployment, it will prompt for authentication a number of times.

1. Launch a PowerShell window as an Administrator.
2. Navigate to the 'Scripts' folder.
3. Execute the deploy script in the PowerShell window - ```.\deploy.ps1```

During installation PnP Management Shell will request permissions for the application on behalf of your organization. Please grant consent. You will be able to revoke that access after the deployment of the solution.

If you chose to enable the Sensitivity Label functionality, a dialog will be displayed prompting for the password for the Service Account. Please complete the prompt.

When the message **"DEPLOYMENT COMPLETED SUCCESSFULLY** is displayed, move onto the next stage of the deployment.

**If the script fails for any reason, it can be re-executed as many times as require without the need to delete any resources**

### Authorize API connections

When the script was executed, it created a number of API connections that need to be authorized manually. 
In Microsoft Azure portal go to the resource group that was created by the script. 

1. Click on the API connection with the name "provisionassist-o365".
2. Go to "Edit API connection" on the left menu.
3. Click "Authorize". Use the Service Account to authenticate.
4. Repeate the above actions for "provisionassist-o365users", "provisionassist-spo" and "provisionassist-teams" API connections.

 ## Step 4: Configure approval process

Approval of requests in the solution can take place in two ways:

- Power Automate Approval action (Approval Email and Approvals app in Teams).
- Microsoft Teams Adaptive Card Approval (Adaptive card posted into a Teams channel).

Approvals for requests use a single Power Automate flow which runs when the status of a request in the **'Provisioning Requests'** list changes to **'Submitted'** (user submits the request in the Power App). 

Follow the steps to configure the Provison Assist settings depending on which approval method you wish to implement. 

The settings for the Provision Assist solution can be found in the 'Provisioning Request Settings' list and are in the form of a key/value pair (Title/Value), both the **Title** and **Value** columns are single line of text. 

### Power Automate Approvals

1. Navigate to the SharePoint site created as part of the deployment.
2. Locate the 'Provisioning Request Settings' list and navigate to it.
3. Edit the 'ApproverEmail' list item and set the 'Value' field to a Email/UPN of a **single user** OR a **Microsoft 365 Group**.
4. Ensure the value of the 'PostToTeams' list item is set to **false**. 
5. Save the changes to the list item.

Approvals are now configured to use Power Automate Approvals tasks.

### Teams

1. Create (OR use an existing) Microsoft Teams Team to use for the approval adaptive cards. You may wish to connect the **Provision Assist** SharePoint site (group) to a new Teams Team.
2. Create (OR use an existing) channel in the same team for the approval cards. This is where they will be posted.
3. Add the appropriate users that will approve requests to the team.
4. In the Teams client, click on the epilsis and select 'Get link to channel'.

![Microsoft Teams get link to channel screenshot](/Images/LinkToChannel.png)

5. Click 'Copy' to copy the link to the clipboard.

![Get link to channel screenshot](/Images/LinkToChannelCopy.png)

6. Extract the Group Id and Channel Id from the string value as shown below:

https://teams.microsoft.com/l/channel/<span style="color:red">19%3af221b1abbb214c4b8b5fe3d7e4074194%40thread.tacv2</span>/Request%2520Approvals?groupId=<span style="color:green">320312d1-e925-433f-80bc-4422f5395edf</span>&tenantId=32292181-0169-456b-b0a4-95fa4c5773a4

The text shown in <span style="color:red">red</span> is the Group Id. The text shown in <span style="color:green">green</span> is the Channel Id.

7. Navigate to the SharePoint site created as part of the deployment.
8. Location the 'Provisioning Request Settings' list and navigate to it.
9. Edit the 'PostToTeams' list item and set the 'Value' field to **true**.
10. Edit the 'TeamsChannelID' list item and set the 'Value' field to the id of the channel that you extracted above.
11. Edit the 'TeamsTeamID' list item and set the 'Value' field to the id of the group that you extracted above.
12. Add the service account to the team as a member, this is required or the adaptive cards will not be posted.

The approvals will now use adaptive cards in Teams. Please revisit this section of the deployment guide if you want to switch to Power Automate Approvals in the future.

## Step 5: Deploy Power Apps solution

1. Sign in with the service account that you created for the Provision Assist solution. **This is an important step, you must not use the account that you used to deploy the resources.**
2. Navigate to the Power Apps portal.
3. Click on 'Solutions' in the left pane and click 'Import solution'.

![Power Apps browse solution import screenshot](/Images/PASolutionImport.png)

4. Browse and select the ProvisionAssist managed solution file.
5. Click 'Next'.

![Power Apps import solution screenshot](/Images/PASolutionImport1.png)

6. Click 'Next'.
7. Create new connections for each connection used by Provision Assist, ensure you sign in using the service account.

![Power Apps import solution connections screenshot](/Images/PASolutionConnections.png)

8. Click 'Next' once the connections have been connected.
9. The next step is to update the environment variables used by the solution. Either select the SharePoint site created by the deployment in the drop down OR if it is not visible, enter the URL. 
10. Using each drop down, connect each environment variable to the appropriate SharePoint list by matching the name.

![Power Apps solution environment variables screenshot](/Images/PASolutionEnvVariables.png)

11. Click 'Import'.
12. When the solution has imported a message will be displayed.

![Power Apps solution import success message screenshot](/Images/PASolutionImportSuccess.png)

The solution has now been imported, please proceed to the next step to configure the Power App.

## Step 6: Configure Provision Assist Power App

**At the time of writing there is known bug with Environment Variables in the Power Platform which causes them to remain connected to the source tenant. The Power App needs to be edited and re-pointed at the variables.**

Therefore this step of the deployment guide is only required while the bug remains, once the bug is fixed by the product team, this deployment guide will be updated. 

1. Navigate to the Power Apps portal as the service account and click 'Apps' in the left pane, you should see the Provision Assist Power App.
2. Open the Power App in **Edit** mode.
3. Click 'Allow' to consent to the connections.
4. When the app opens in the studio, click the 'Data' icon in the left pane to bring up the data sources.
5. Click the elipsis next to each SharePoint list and click 'Remove'. Repeat this process for all SharePoint lists.

![Power App remove data sources screenshot](/Images/PARemoveDataSources.png)

6. Click the 'Add data' option from the Data pane and search for the SharePoint data sources.

![Power App add data source screenshot](/Images/PAAddDataSources.png)

7. Click on the SharePoint data source.
8. Select the SharePoint connection you created earlier.

![Power App select SPO data source screenshot](/Images/PASelectSPODataSource.png)

9. On the 'Connect to a SharePoint site' pane that appears, click 'Advanced' and select the 'Provision Assist SPO Site' environment variable.

 ![Power App connect to SPO site screenshot](/Images/PAConnectSPOSite.png)  

 10. In the 'Choose a list' pane, click 'Advanced' and select all list environment variables.

![Power App connect SPO lists screenshot](/Images/PAConnectLists.png)

11. Click 'Connect'.
12. Wait for the data sources to appear in the Data pane.
13. Save and publish the Power App using the icons in the top right. 
14. Close the app. 

## Step 7: Share Power App, Flows and SharePoint site

Before Provision Assist can be rolled out, the Power App and SharePoint site need to be shared with all users to will submit requests.

### Power App

Follow the steps below to share the app and the SharePoint site:

1. Navigate to the Power Apps portal as the service account.
2. Select the Provision Assist Power App and click 'Share' on the top menu.
3. Enter users or groups to share the app with. You may wish to give some users 'Owner' rights to edid the app. This will avoid the need to sign in with the service account when making changes.

If you don't have a group you can add users individually or share with everyone across your tenant by sharing with the 'Everyone' group. (To keep the communication official, you should take out the checkbox to 'Send an email invitation to new users.') You can also share the app with other admins by granting them Co-Owner rights.

![Share Power App screenshot](/Images/PAShareApp.png)

4. Choose whether or not to send an email invitation and click 'Share'. 
5. The users will now have access to the Power App. 

### Flows

Next, we will share the flows that are used by Provision Assist with admins that wish to view flow runs/edit the flows. This step is optional but will avoid the need to sign in with the service account when viewing flow runs. Repeat these steps for each flow.

Two flows are provided with the Provision Assist solution, these are:

- Provisioning Request Approval - Provides an approval process for requests, see [Approval flow](/Approval-flow.md) for more details.
- Check Space Availability - Checks to see if a space matching the supplied Title/URL already exists. This flow is executed when the 'Verify' button is clicked in the Power App. It uses the 'Office 365 Groups' connector to check for a group with the same details and also checks the 'Provisioning Requests' list for a matching request. Users may only proceed if the space does not exist or a request matching the same name does not already exist. If a request is found in the list and it was created by the SAME user, they are prompted to edit the other request instead.

1. Navigate to the Power Apps portal as the service account.
2. Click 'Flows' in the left pane. You will find two flows that are used by Provision Assist - **Provisioning Request Approval** and **Check Space Availability**.
3. Select the 'Provisioning Request Approval' flow and click 'Share' on the top menu.

![Share flow screenshot](/Images/PAShareFlow.png)

4. Enter users or groups to share the flow with, select 'OK' in the 'Before you share' dialog that appears.

5. Repeat these steps for the 'Check Space Availability' flow.
6. These users will now have access to the flows.

### SharePoint site

The steps below will share the SharePoint site with end users, giving them access to create/edit requests only and not edit any of the backend settings of Provision Assist.

1. Navigate to the SharePoint site created during the deployment.
2. Click 'Settings' _(gear)_ icon at the top right corner.
3. Click 'Site permissions'.
4. Click 'Advanced Permissions settings'.	
5. Click the Grant Permission option from the top menu bar and search for the user name or type the email address of the user to whom you want to share the site OR select a group containing the users.
6. Click 'Show Options' and under the permission level, select the visitors group (this will grant the users read-only access to the site initially).
7. Navigate to the 'Provisioning Requests' list and [follow these steps](https://support.office.com/en-gb/article/customize-permissions-for-a-sharepoint-list-or-library-02d770f3-59eb-4910-a608-5f84cc297782) to break permission inheritance. Give the Visitors group 'Edit' rights (this will ensure that users can create requests).

**Note:** Every user accessing the app for the first time will be prompted to consent to accessing the data sources. The user should click on 'Allow' to proceed. This can be bypassed by using the Power Apps admin PowerShell module. See the [Solution Overview](/Solution-Overview) for more details. It is recommended to disable the consent popup using PowerShell before production deployment.

## Step 8: Add the app to Teams

1. Navigate to the Power Apps portal as the account you wish to install the app for and click 'Apps' in the left pane, you should see the Provision Assist Power App. **You may need to select the correct Environment in which you deployed the solution from the Environment menu at the top**.
2. Select the app and click 'Add to Teams' from the top menu bar.

At this point you have two options:

Add the app to Teams globally using policies in the Teams Admin Center OR sideload the app into the Teams client and install for the current logged in user only. 

3. If you wish to sideload the app, click the 'Add to Teans' option in the dialog that appears. The Teams client will open (you may choose the web client or desktop) and the app will install for the current logged in user.

If you wish to roll the app out via policies, please refer to our general documentation on docs.microsoft.com for how to upload to the Teams Admin Center and deploy globally.

## Step 9: Running/Configuring supporting Logic Apps

There are a few supporting Logic Apps which should be executed manually after the initial deployment.

These are set to use recurrent triggers and run weekly by default. You can change the run frequency of these to a schedule that suits your organization.

Details of what these are and what they do can be seen below:

- **GetHubSites** (Retrieves all Hub Sites in the tenant and creates these as list items in the 'Hub Sites' list in the SharePoint site.)
- **GetSiteTemplates** (Retrieves all SharePoint Site Templates deployed in the tenant and creates these as list items in the 'Site Templates' list in the SharePoint site.)
- **GetTeamsTemplates** (Retrieves Teams Templates configured in the Teams Admin Center and creates references to these as list items in the 'Teams Templates' list in the SharePoint site.)
- **SyncGroupSettings** (Gets group settings - Blocked Words and Classifications from Azure AD and updates list items in the 'Provisioning Request Settings' list in the SharePoint site.)
- **SyncLabels** (Retrieves all Sensitivity labels from Purview in the tenant and adds these to the 'IP Labels' list in the SharePoint site.)

Follow these steps to run them 'on demand':

1. Navigate to the Azure Portal (portal.azure.com).
2. Locate the required Logic App e.g. GetHubSites. You can either search for the logic app in the search bar or locate the resource group created as part of the deployment, click on it and locate the logic app in there.
3. Select the logic app.
4. Click on 'Run Trigger' > 'Run'.
5. Once the logic app has executed, you should see a status of 'Succeeded' in the run history.
6. Repeat the steps to execute each logic app.

## Step 10: Set up Admins group

The Provision Assist Power App leverages a setting in the 'Provisioning Request Settings' list to determine whether or not to display the 'settings' screen to a user in the app. Settings for the solution can be configured via this screen as an alternative to using the settings list in the SharePoint site. *At the time of writing this screen is experimental and should be considered a work in progress.* Settings should be visible to Administrators of Provision Assist only. Before following the steps, please create one of the following (or use an existing) which will contain the admins for Provision Assist:

- Microsoft 365 Group (can be the same one used for the Provision Assist SPO site) OR 
- Microsoft Teams Team OR 
- AAD Security Group

Obtain the id of the resource you created or an existing one you will reuse and follow the steps below:

1. Navigate to the SharePoint site created as part of the deployment.
2. Location the 'Provisioning Request Settings' list and navigate to it.
3. Edit the 'AdminGroupId' list item and set the 'Value' field to the id from above.
4. Save the list item.

The admins group is now set up and configured.

![Provision Assist settings icon screenshot](/Images/PASettingsIcon.png)

![Provision Assist settings screen screenshot](/Images/PASettingsScreen.png)

## Deployment of the solution is now complete and the app should be accessible in Teams.

## Step 11 (Optional): Enable provisioning of Viva Engage Communities

Provision Asssist includes the ability to provision Viva Engage Communities, this is disabled upon deployment because it requires an App to be registered through the Yammer Developer Center and a developer token to be generated.

To enable this functionality, please perform the following steps:

1. Ensure that Viva Engage is in Native mode. **Non-Native mode or Hybrid mode are not supported**.
2. Sign in with the service account.
3. Navigate to `https://www.yammer.com/client_applications` and click **Register New App** (You may need to sign into Viva Engage first).
4.  Complete the required details, tick the box and click 'Continue'.

- Application Name: e.g. Provision Assist
- Organization: Your organization name
- Support e-amil: Email address of an appropriate person
- Website: Not used but requires a value e.g. Your public facing website address
- Redirect URI: Not used but requires a value e.g. Your public facing website address

![Register Viva Engage app screenshot](/Images/RegisterVEApp.png)

5. Once the app has been registered, click the 'Generate a developer token for this application' link.
6. Copy the token that is displayed as you will need it shortly.
7. Navigate to the Azure Portal (as a user with appropriate rights) and locate the **ProcessProvisionRequest** logic app.
8. Edit the logic app and update the value of the **VIvaEngageAppToken** variable with the token you copied earlier.

![Update logic app with Viva Engage token screenshot](/Images/UpdateLogicAppVEApp.png)

9. Save and close the logic app.
10. Navigate to the SharePoint site created as part of the deployment and locate the **Provisioning Types** list.
11. Edit the list item entitled **Viva Engage Community** and set the **Allowed** column to **Yes**.
12. Launch the Provision Assist Power App and complete a test request. Observe that the **Recommendation** step now displays an option to select a Viva Engage Community.
13. Viva Engage Community provisioning is now enabled.
