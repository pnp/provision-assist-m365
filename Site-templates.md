# Site Templates

Provision Assist includes the ability to apply Site Templates (previously known as Site Designs) when a user requests the creation of a SharePoint Site (Team Site, Office 365 Group, Communication Site or Hub Site).

The solution now includes the ability to apply PnP Provisioning templates, at the time of writing these can be applied **instead** of Site Templates. Please read the [PnP Templates](/PnP-Templates.md) documentation for more details. 

All available Site Templates in the current SharePoint tenant are retrieved by a Logic App and a Runbook - both named 'GetSiteTemplates'. 

This includes out of the box templates - Topic, Showcase, Blank etc. and any custom templates that have been created.

These are then stored in a SharePoint list within the Provision Assist site - 'Site Templates'.

The following properties of the Site Templates are stored in the list:

- Title (Title of the template e.g. Topic)
- SiteTemplateId - Unique Id (GUID) of the template
- PreviewImage - Link to the preview image for the template
- WebTemplate - Web template that the template can be applied to (64 for a Team Site, 68 for a Comms/Hub site)
- Enabled - Whether or not the template should be displayed in the Power App for users to select. Default is false and you can enable which ones are required.
- ThemeName - Name of a SharePoint theme in your tenant that should be applied to the area once created. Default is blank if you do what want to apply a template. If you want to apply a template, simply set this field to the name of a valid template. This can be an out of the box template e.g. Blue or a custom one e.g. 'Contoso Dark'. 

![Site templates list screenshot](/images/SiteTemplatesList.png)

Users can select one of these from the Power App when creating a request, the 'ProcessProvisionRequest' logic applies these using the SharePoint REST API. 

As above, if you want a template to display, set the 'Enabled' column to true.

The 'GetSiteTemplates' logic app will handle creating, updating and deleting the list items in the Site Templates list. It will not handle updating/setting the 'ThemeName' column therefore this should be manually populated. 