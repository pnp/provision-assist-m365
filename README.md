# Provision Assist
Provision Assist is a Power Platform and Azure based solution that provides an alternative to self-service creation in Microsoft 365. It provides governance over this process through a frontend Power App allowing users to request Collaboration 'Spaces' (Teams, Groups, SPO Sites & Viva Engage Communities) and backend Azure components providing automated provisioning. 

## Capabilities

Provision Assist provides the following capabilities:

- Canvas based Power App (designed to be added and pinned in Teams) allowing users to request collaboration spaces.
- Recommendations 'engine' meaning users are recommended an appropriate collaboration space e.g. A Microsoft Teams Team based on their requirements.
- Configurable approval process using Power Automate to facilitate the approval of requests.
- SharePoint site and supporting lists which act as the backend for the solution.
- Requestor dashboard showing past and current requests with the approval status.
- Automated provisioning using Azure Logic Apps and Azure Automation.
  
## Architecture

The solution uses the Microsoft Graph and the SharePoint REST APIs for provisioning. Azure Runbooks are used with PnP PowerShell for tasks that cannot be completed using the Graph API. 

Application permissions are used through an Azure AD app registration, the secret for the Azure AD app is stored in a key vault.

Provisioning and other automation tasks in the solution is achieved through Azure Logic apps, ensuring a low runtime cost and the ability to secure access to all resources.

For more details on the archictured please read the [Architecture](www.microsoft.com) documentation.


## Getting Started

To get started please follow the [Deployment guide](www.microsoft.com). 

## Issues

## Contributing

## Support
