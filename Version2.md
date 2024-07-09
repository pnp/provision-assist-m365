# Provision Assist Version 2

<img src="https://github.com/pnp/provision-assist-m365/blob/59eaf10ffc84af53560b6671c421997e7be2af59/Images/V2HomeDesktop.png" height="500" alt="Provision Assist V2 Home Screen Desktop Screenshot"><br/>

<img src="https://github.com/pnp/provision-assist-m365/blob/59eaf10ffc84af53560b6671c421997e7be2af59/Images/V2RecommendationMobile.jpeg" height="500" alt="Provision Assist V2 Home Screen Mobile Screenshot"><br/>

We are excited to announce the release of Provision Assist V2 🥳

This release includes a brand new Power App which is fully responsive across all devices including the Teams mobile app. It also takes advantage of some of the new Power Apps 'modern controls' to provide a cleaner UI and user experience.

Branding of the app is made easier through the addition of two new settings in the settings list allowing you to configure a primary and secondary colour for the app. You can create these settings manually (details below) to avoid the need to rerun the deployment script. 

The previous version of the app remains in the solution allowing you to test V2 before you launch it across your organization. The previous app will remain in the solution for some time before it is eventually removed.

There have been no changes made to the backend components as part of the V2 release so there is no need to redeploy these.

The new Power App is named 'Provision Assist (V2)', feel free to rename this to suit your needs.

The V2 app is still a work in progress and is currently missing the following capabilities:

- Dark Mode.
- Ability to filter the status of a request on the 'My Requests' screen.

See the [Provision Assist Roadmap](https://github.com/orgs/pnp/projects/5) for more details on enhancements to the V2 app. 

## Deploying V2

1. Download the [V2 release](https://github.com/pnp/provision-assist-m365/releases/tag/v2.0.0).
2. Manually create the following setting list items in the 'Provisioning Request Settings' list. Feel free to update the colour values to your brand colours at this point. 

---

**Title**: AppPriAccentColor

**Description**: Primary accent colour (HEX format) for the Provision Assist app. Set this to the main brand colour for your organization.

**Value**: #4DA6FF

---

**Title**: AppSecAccentColor

**Description**: Secondary accent colour (HEX format) for the Provision Assist app. Set this to a colour from your organizations brand palette.

**Value**: #FFA6FF

3. Deploy the V2 solution into your Power Platform environment using either the Managed or Unmanaged solution. If you have not customized the previous solution, the solution should be upgraded.
4. Follow 'Step 5' onwards in the main [Deployment guide](./Deployment-guide.md) to complete deployment of the Power Platform components. **When configuring the app ensure you edit and configure the 'Provision Assist V2' app.**
5. Share the V2 Power App with Users/Admins and optionally add to Microsoft Teams.

## Feedback and Issues

This is the first release of the new Provision Assist app and we expect there to be teething issues and odd pesky 🪲. Please report any issues by raising an [issue](https://github.com/pnp/provision-assist-m365/issues/new/choose) so that we can address these.

And finally If you like V2, please buy us some pizza 🍕🍕 to say thanks, a lot of effort went into creating V2 - your support is greatly received.

<a href="https://www.buymeacoffee.com/provisionassist" target="_blank"><img src="./Images/buypizza.png" alt="Buy us some pizza" ></a>

## Extra Screenshots

<img src="https://github.com/pnp/provision-assist-m365/blob/59eaf10ffc84af53560b6671c421997e7be2af59/Images/V2HomeMobile.jpeg" height="500" alt="Provision Assist V2 Home Screen Mobile Screenshot"><br/>

<img src="https://github.com/pnp/provision-assist-m365/blob/59eaf10ffc84af53560b6671c421997e7be2af59/Images/V2RequestDesktop.png" height="500" alt="Provision Assist V2 New Request Desktop Screenshot"><br/>
