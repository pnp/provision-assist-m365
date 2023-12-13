# Provision Assist

| [Deployment guide](/Deployment-guide.md) | [Architecture](/Architecture.md) | [Data Stores](/Data-stores.md) | [Cost Estimates](/Cost-estimates.md) | [Data Access & Security](/Data-access-security.md) | [Naming Conventions](/Naming-conventions.md) | [Provisioning Types](/Provisioning-types.md) | [Site Templates](/Site-templates.md) | [Sensitivity Labels](/Sensitivity-labels.md) | [Teams Templates](/Teams-templates.md) | [PnP Templates](/PnP-templates.md) | [Retention Labels](/Retention-labels.md) | [Approval Flow](/Approval-flow.md) | [Regional Settings](/Regional-settings.md) | [Recommendation Scoring](/Recommendation-scoring.md) | [Translations](/Translations.md) | [Refreshing App Secret](/Refreshing-app-secret.md) 
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |

Provision Assist is a Power Platform and Azure based solution that provides an alternative to self-service creation in Microsoft 365. It provides governance over this process through a frontend Power App allowing users to request Collaboration 'Spaces' (Teams, Groups, SharePoint Online Sites & Viva Engage Communities) and backend Azure components providing automated provisioning. 

![Provision Assist Home Screenshot](/Images/ProvisionAssistHome.png)

![Provision Assist Recommendations Screenshot](/Images/ProvisionAssistRecommendations.png)

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

For more details on the architecture please read the [Architecture](Architecture.md) documentation.

## Getting Started

To get started please follow the [Deployment guide](Deployment-guide.md). 

## Issues

Please report any issues by raising an [issue](https://github.com/pnp/provision-assist-m365/issues/new/choose).

## Contributing

We 💖 to accept contributions.

Check out our [Contribution guidelines](/CONTRIBUTING.md) for guidance on how to contribute. 

If you want to get involved with helping us enhance Provision Assist, whether that is suggesting or adding new functionality, updating our documentation or fixing bugs, we would love to hear from you.

## Special Thanks

Special thanks to those below who have helped build this awesome solution.

- [@alexc-MSFT](https://github.com/alexc-MSFT)
- [@OlgKis](https://www.github.com/OlgKis)
- [@PalinaSolik](https://www.github.com/PalinaSolik)

## Support

This solution is open-source and community provided with no active community providing support for it. This solution is maintained by both Microsoft employees and community contributors and is not a Microsoft provided solution so there is no SLA or direct support for this from Microsoft. Please report any issues by raising an [issue](https://github.com/pnp/provision-assist-m365/issues/new/choose).

If you like this project, please buy us some pizza 🍕🍕 to say thanks - your support is greatly received.

<a href="https://www.buymeacoffee.com/provisionassist" target="_blank"><img src="./Images/buypizza.png" alt="Buy us some pizza" ></a>

## Microsoft 365 & Power Platform Community

Provision Assist is a Microsoft 365 & Power Platform Community (PnP) project. Microsoft 365 & Power Platform Community is a virtual team consisting of Microsoft employees and community members focused on helping the community make the best use of Microsoft products. Provision Assist is an open-source project not affiliated with Microsoft and not covered by Microsoft support. If you experience any issues using Provision Assist, please submit an issue in the [issues list](https://github.com/pnp/provision-assist-m365/issues).

## "Sharing is Caring"

![Parker PnP](/Images/parker-pnp.png)

## Disclaimer

**THIS CODE IS PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.**

## Code of Conduct

This repository has adopted the Microsoft Open Source Code of Conduct. For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact opencode@microsoft.com with any additional questions or comments.
