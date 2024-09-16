# Data Access & Security

The Provision Assist solution uses the **Microsoft Graph API**, **Yammer REST API** and the **SharePoint REST API** to perform provisioning of Groups, Sites, Teams and Yammer Communities.

Provisioning is carried out using an **Entra ID App Registration** which has the required permissions to the Microsoft Graph API assigned to it. For the most part **Application Permissions** are used with one exception - the application of sensitivity labels.

At the time of writing (July 2023), the Graph API does not support applying sensitivity labels to Groups and Teams using Application Permissions therefore a Service Account is used (no MFA) and **Delegated Permissions** configured to the relevant Graph endpoint.

If you choose to disable or not use the sensitivity label functionality, then this is not required. 

The **Client ID** and **Client Secret** of the Entra ID app are stored in a dedicated Key Vault that is created for the Provision Assist solution. These are then extracted for use in the Logic Apps using the Key Vault action, the action is set to hide the input and outputs so the secret value cannot be seen when viewing the run history.

The full list of the required API permissions for the Microsoft Graph and SharePoint tenant can be found below. 

## API Permissions 

The API permissions required for the Entra ID app are as follows:

### Microsoft Graph

| API Permission | Type | Description| Reason |
|--|--|--|--|
| Directory.Read.All | Application | Read directory data |Used to read Users, Groups and Teams from the tenant.|
| Directory.ReadWrite.All | Application | Read and write directory data |Used to create guest users in Entra ID if they are requested.|
| Group.ReadWrite.All | Delegated | Read and write all groups |Used to apply sensitivity labels to created groups/teams.|
| Group.ReadWrite.All | Application | Read and write all groups |Used to create and update the properties of groups/teams.|
| InformationProtectionPolicy.Read.All | Application | Read all published labels and label policies for an organization. |Used to syncronize sensivity labels in the tenant to a SharePoint list.|
| Sites.FullControl.All | Application | Have full control of all site collections. |Update the properties of provisioned SharePoint sites.|
| TeamsTemplates.Read.All | Application | Read all available Teams Templates |Used to read the teams templates in the tenant and syncronize them to a SharePoint list.|
| User.Invite.All | Application | Invite guest users to the organization |Used to invite guest users in Entra ID if they are requested.|
| User.ReadWrite.All | Application | Read and write to all users' full profiles |Used to update guest users in Entra ID if they are requested.|

### SharePoint

| API Permission | Type | Description| Reason |
|--|--|--|--|
| Sites.FullControl.All | Application | Have full control of all site collections| Used to read and write to created SharePoint sites. |

In addition to the above, the Entra ID App must be registered as a **SharePoint add-in** and granted **Full Control permissions** to the SharePoint tenant. 

This is required because, as part of the provisioning there is a check to see if a SharePoint site matching the URL already exists both as an active site but also in the tenant recycle bin. 

### Viva Engage

For the Viva Engage functionality, an 'App' must be created in the Yammer 'Registered applications' page and a developer token generated.

The developer token is then stored in a variable in the main Logic App which is used for provisioning. 
