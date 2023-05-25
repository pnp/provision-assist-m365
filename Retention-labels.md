# Retention Labels

Provision Assist supports the application of retention labels to the SharePoint site backing a created collaboration space.

The label will be applied to the **out of the box 'Documents' library only**.

To use this functionality retention labels must have been created in the Microsoft Purview Compliance Portal.

**Allow 24 hours after creating and publishing labels before you follow this guide.**

Once labels are created, you will need to enable this functionality in the Provision Assist solution. Follow the steps below to do this. 

We will first cover how the functionality works and then how to enable it.

### What does this look like?

Retention labels are stored as list items in a SharePoint list named 'Retention Labels' in the SharePoint site backing Provision Assist.

Labels need to be added manually to the SharePoint list named 'Retention Labels'. Ensure that the value of the 'Label Name' column **matches the exact name of the label in Purview**. 

![Retention labels list screenshot](./images/RetentionLabelsList.png)

![Retention label in app screenshot](./images/RetentionLabelPA.png)

If the functionality is enabled, the labels are shown to the user in a combo box on the Data Classification step.

You can set a default label and choose whether to require the user to select a label by configuring the 'DefaultRetentionLabel' and 'RequireRetentionLabel' settings in the Site Request Settings list. This will be covered in the Configuration section of this documentation.

## Enabling the functionality

1. Navigate to the **'Provisioning Request Settings'** list in the SharePoint site.
2. Edit the **'EnableRetentionLabels'** list item and set the Value field to **'true'**. It will be set to 'false' by default.

## Configuration

Once enabled, this functionality can be configured as follows:

1. Create your labels in the '**Retention Labels**' list by creating list items manually, ensure 'Label Name' matches the exact name of the label. 
2. Set a default label (Optional) by setting the value of the **'DefaultRetentionLabel'** list item in the **'Site Request Settings'** list to the label name of your chosen label. The label name must **exactly** match a valid label name from the Retention Labels list. You can find the label name in the **'Label Name'** column.
3. Choose whether to require the user to select a label (Optional). The default is **'false'** which means the user will not be required to select a label and the combo box can be left blank. If you wish to require (force) users to select a label, simply set the value of the **'RequireRetentionLabel'** list item to **'true'**.

![Retention label configuration in settings list screenshot](./images/RetentionLabelSettings.png)

5. The functionality is now configured and when users launch the app to request spaces, they should see the Retention label combo box on the Data Classification screen.
