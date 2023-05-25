# Sensitivity Labels

Provision Assist supports the application of sensitivity labels to created Teams or Office 365 Groups. 

To use this functionality sensitivity labels must be enabled for Teams & Groups, for more information see - https://docs.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels-teams-groups-sites?view=o365-worldwide. 

**You will need to have labels created in the Microsoft Purview Compliance Portal and published using Label Policies before this will work. Allow 24 hours after creating and publishing labels before you follow this guide.**

This functionality needs to be enabled and configured for it to work.

_Note - Due to limitations in the Microsoft Graph API, labels can only be applied using the Delegated permissions model. This means a Service Account (this can be the same one used for Provision Assist) is required. This account must NOT have MFA configured._

_The username and password for this account is stored in Key Vault in order to ensure it is as secure as possible._

_When this restriction is removed, we will update Provision Assist to use Application permissions, removing the need for a NO MFA Service Account._

We will first cover how the functionality works and then how to enable it.

### What does this look like?

Sensitivity labels are retrieved from the Purview portal using the Microsoft Graph API. A Logic App named 'SyncLabels' performs this sync. By default, this Logic App is set to run daily, you can change this if desired.

Labels are stored as list items in a SharePoint list named 'IP Labels' in the SharePoint site backing Provision Assist.

![IP labels list screenshot](./images/IPLabelsList.png)

For a label to appear in the Power App, the 'Enabled' column must be checked. This column has been added because the Graph API does not allow filtering on labels that can be applied to Sites/Groups vs Document/Email labels and ensures that users cannot select the wrong type of label. You will notice that there may be document/email labels in the IP Labels list. Make sure these are not set to 'Enabled' and that only ones that can be applied to sites or groups are marked as enabled.

![Sensitivity label in power app screenshot](./images/SensitivityLabelPA.png)

You can validate which labels can be applied to sites/groups through the Security & Compliance center.

If the functionality is enabled, the labels are shown to the user in a combo box on the Data Classification screen.

You can set a default label and choose whether to require the user to select a label by configuring the 'DefaultSensitivityLabel' and 'RequireSensitivityLabel' settings in the Site Request Settings list. This will be covered in the Configuration section of this documentation.

## Enabling the functionality

There are two ways to enable this functionality:

1. When running the script - A parameter 'EnableSensitivity' can be found in the parameters.json file which will enable the sensitivity label functionality. If this is set to true, the functionality will be automatically enabled. This is documented in the [deployment guide](./Deployment-guide.md).

2. Manual Enablement - Follow the steps below to manually enable this functionality, assuming you did not enable it in the parameters.json file. 

### Manual Enablement

1. Navigate to the **'Provisioning Request Settings'** list in the SharePoint site.
2. Edit the **'EnableSensitivityLabels'** list item and set the Value field to **'true'**. It will be set to 'false' by default.
3. Navigate to the **Azure Portal > Key Vaults blade** and click on the key vault used for your Provision Assist implementation.
4. Select **'Secrets'** from the left pane.

![Key vault secrets screenshot](./images/KeyVaultSecrets.png)

5. Click **'Generate/Import'** and create the following secret:

![Generate secret screenshot](./images/KeyVaultGenerateSecret.png)

Name: sausername

Value: UPN of your service account

Click 'Create' once done'

![Create username secret screenshot](./images/KeyVaultUsernameSecret.png)

6. Repeat the step above and create the following secret:

Name: sapassword

Value: Password for your service account

7. Locate the Logic App named **'SyncLabels'** in the Azure Portal and click on it.
8. Click **'Run Trigger > Run'** and wait for the run to complete.

![Sync labels logic app screenshot](./images/SyncLabelsLA.png)

9. Navigate to the **'IP Labels'** list in the SharePoint site and validate that the labels are present (See screenshot of IP Labels list at the top of this documentation). If there are no list items present then the **'SyncLabels'** logic app has failed to run. Check the run history of the Logic App and investigate any failures. 

## Configuration

Once enabled, this functionality can be configured as follows:

1. If not already done, locate the **'SyncLabels'** Logic App from within the Azure portal and run it - **'Run Trigger > Run'**. This will synchronize the labels into the IP Labels list. (See screenshot above). 
2. Enable some labels to display in the Power App by editing the list items, setting the **'Enabled'** column to **'true'** and saving the items.

![Enabling a label screenshot](./images/EnableIPLabel.png)

3. Set a default label (Optional) by setting the value of the **'DefaultSensitivityLabel'** list item in the **'Provisioning Request Settings'** list to the label id of your chosen label. The label id must **exactly** match a valid label id from the IP Labels list. You can find the label id in the **'Label Id'** column.

![Set default label screenshot](./images/SetDefaultLabel.png)

4. Choose whether to require the user to select a label (Optional). The default is **'false'** which means the user will not be required to select a label and the combo box can be left blank. If you wish to require (force) users to select a label, simply set the value of the **'RequireSensitivityLabel'** list item to **'true'**.
5. The functionality is now configured and when users launch the app to request collaboration spaces, they should see the Sensitivity combo box on the Data Classification step (only for 'Microsoft Teams Teams' or 'Office 365 Groups').