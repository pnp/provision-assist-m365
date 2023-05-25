# Refreshing App Secret

From time to time you may need to update/refresh the client secret used in the Azure AD App for Provision Assist. This may be because the secret has expired or you wish to generate a new one.

When you deploy Provision Assist, the secret generated for the AD app has a default expiry of 1 year from the date the deployment script was executed.

The secret is used in a few places in the Provision Assist solution:

- Key Vault
- Key Vault API Connection
- Automation Account encrypted variable

**It is advisable to note down the date when the secret expires as once this has expired, the Logic Apps and Automation Runbooks will fail until a new secret is created and Provision Assist updated.**

## Refreshing the Secret

***Appropriate permissions will be needed when following the process below. Ensure the account you are using has permissions to generate AAD app secrets, update secrets in Key Vault and update the Provision Assist API Connections.**

When the secret expires (OR when you want to create a new one), please follow this process to update Provision Assist to use the new value:

### Generating a new secret

1. Open the Azure Portal.
2. Navigate to Azure Active Directory.
3. Click 'App registrations' on the left menu.
4. Click 'All applications'.
5. Locate your Provision Assist AAD application and click on it.
6. Click 'Certificates and secrets' on the left menu.
7. Click 'New cient secret' under Client secrets.
8. Enter a description for the secret and choose an expiry date. **Note down this expiry date.**
9. Copy the **value** of the secret. **Once you leave this blade, the value will be permanently hidden.**

### Updating Key Vault

1. Open the Azure Portal.
2. Locate the Key Vault for Provision Assist.
3. Click 'Secrets' on the left menu. If you cannot view the secrets you will need to create an access policy for the account you are using OR use an account with appropriate permissions.
4. Locate the 'appSecret' secret and click on it.

![Key Vault appSecret secret screenshot](/Images/KeyVaultAppSecret.png)

5. Click 'New Version', enter the value of the new secret into the 'Secret value' box and click 'Create'.

![Key Vault create secret version screenshot](/Images/KeyVaultUpdateSecret.png)

6. Key vault has now been updated.

### Updating API Connection

1. Locate the 'provisionassist-kv' API Connection in the Azure portal, you can use the search box to search for it.
2. Click 'Edit API connect' on the left menu.

![Key Vault API Connection screenshot](/Images/KeyVaultAPIConnection.png)

12. Enter the new secret into the 'Client secret' textbox and click 'Save'.
13. API Connection has now been updated.

### Updating Automation Account Variable

1. Open the Azure Portal.
2. Locate the 'provisionassist-auto' Automation Account.
3. Click 'Variables' in the left menu.

![Automation Account variables option screenshot](/Images/AutomationAccountVariables.png)

4. Click on the 'appSecret' variable.

![Automation Account appSecret variable screenshot](/Images/AutomationAccountAppSecretVariable.png)

5. Click 'Edit value'.
6. Enter the value of the new secret into the 'Value' textbox and click 'Save'.
7. Automation Account has now been updated.

The secret has now been updated for Provision Assist.