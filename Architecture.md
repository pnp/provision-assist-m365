**Solution Architecture**

The diagram below details the architecture of the Provision Assist solution and the components used at a high level.

::: mermaid
graph TD
    A(Canvas Power App) --> | Submit data | B[(SharePoint List)] --> C(Power Automate Approval Flow) --> D(Logic App) --> E(Azure AD App) <--> | Secret stored in Key Vault | F(Azure Key Vault) --> G{Type of collaboration space} --> |SharePoint Site| H[SharePoint REST API] 
    G --> | Office 365 Group | I(Microsoft Graph)
    G --> | Viva Engage Community | J(Yammer REST API) 
    I --> K(Azure Automation)
    H --> K
    J --> K
    K --> | Additional configuration | L(PnP PowerShell) --> M(Provisioned space)
:::