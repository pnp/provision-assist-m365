# Provisioning Types

Provision Assist supports the creation the following collaboration space 'types':

- SharePoint (No group connected) Team Site
- Office 365 Group
- Communication Site
- Hub Site
- Microsoft Teams Team
- Viva Engage Community

These are referred to in Provision Assist as space 'types'. 

A SharePoint list named 'Provisioning Types' stores each type of collaboration space that a user can request (the list above). 

These are displayed to end users in the Power App on the 'Recommendation' step. The scoring in the [Recommendation Scoring list](./Recommendation-scoring.md) determines which type(s) are recommended to the user.

![Provisioning types app screenshot](/Images/ProvisionAssistRecommendations.png)

You can customize how these are displayed in the app to end users and disable them if you do not wish to enable users to request them/you do not wish to recommend them.

![Provisioning types list screenshot](/Images/ProvisioningTypesList.png)

To customize a type, simply edit the list item and update the value of one of the following columns accordingly:

- **Title** - Title of the space type, you may change this if the terminology for this type is different in your organisation. For example a Team Site (no group connected) may be known as a 'Document Storage Area'. This is the title that is displayed to end users in the app.
- **Description** - Description of the space type. Displayed to end users in the app.
- **Allowed** - Whether to allow users to request this space type through the app. 'False' will disable the type and it will no longer be displayed in the app, 'True' will display it in the app.
- **TemplateId** - TemplateId for the space type, this is only applicable to some types and **should NOT be changed**. 
- **Image** - Image of the space type that is displayed to users in the app, you may wish to change this image to reflect how this looks in your organization. For example you may use bespoke branding on your SharePoint sites and want the image to reflect this. This is a hyperlink column, **please ensure that the image you link to will be accessible to all users that will use the app**.
- **WebTemplateId** - WebTemplateId for the space type, this is only applicable to some types and **should NOT be changed**.
- **Learn Video URL** - URL to a video that helps a user to learn about this space type, this could be a video hosted on YouTube for example, users can play this video directly in the app. 
- **Icon** - Icon for the space type that appears on the recommendation step, you can change this if you wish. By default Provision Assist uses the official Microsoft logos. **Please ensure that the image you link to will be accessible to all users that will use the app**
- **Visible To** - Security group containing users who this space type should be visible to. This MUST be a group and not individual users. If this column is left blank then the collaboration space type will be visible to all users who have access to the app. An example where this could be used is to restrict the creation of Communication Sites to those in Corporate Comms.
- **Managed Path** - Managed path to use when creating collaboration spaces using this type. You can use this to create SharePoint sites under the 'sites' managed path even if your tenant default is 'teams'.

**Please do not add new items to this list as they will not work.**

You can also edit the columns that define the naming convention, allowing you create a naming convention that is specific to the space type. See the [Naming conventions](/Naming-conventions.md) documentation to learn more.

