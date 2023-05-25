# Teams Templates

Provision Assist supports the creation of Teams based on templates defined in the Admin Center. The Admin Center templates power the native 'out of the box' Teams Templates functionality. 

In addition to the support of Admin Center based templates, Provision Assist supports 'cloning' teams by defining these as a template.

You may also create dedicated naming conventions for teams templates, please follow the [Naming conventions](./Naming-conventions.md) documentation for details on how to configure this.

Please read on for more details on how you can configure this functionality. 

**_Templates created in the Admin Center can take up to 24 hours to be fully available in the Microsoft Graph so please wait before using them._**

***

**IMPORTANT - Graph API Endpoints used:**

The creation of Teams from Admin Center defined templates uses the Beta endpoint of the Graph API. A group is created first using the v1.0 endpoint and then a team is added from the specified template. See [Graph API Reference - Create team](https://docs.microsoft.com/en-us/graph/api/team-post?view=graph-rest-beta&tabs=http) (Example 4).

Cloning teams uses the v1.0 endpoints.

***

**Teams Templates list**

The Teams Templates list (which can be found in the SharePoint site backing the Provision Assist solution), defines a set of templates that users can choose when they make a request for a Team from a template. 

This list should contain the 'out of the box' Microsoft provided templates when the solution is first deployed. This list is populated by a logic app, this is explained in the [Deployment guide](./Deployment-guide.md).

You may delete list items for templates you do not require, however the logic app will add them again when it is executed so you may wish to disable this logic app once your required templates are in the list.

The Teams Templates list contains the following fields:

* **Title** - Title of the template
* **Description** - Description of the template
* **Template id** - ID of the template
* **Team Id** - ID of a Team (Group ID) that you wish to designate as a template (to clone teams)
* **Admin Center Template** - Identifies if the template has been created in the Admin Center
* **Prefix Attribute** - Attribute to use for the prefix of a team created from this template
* **Suffix Attribute** - Attribute to use for the suffix of a team created from this template
* **Prefix Text** - Prefix text to be prepended to the name of a team created from this template
* **Suffix Text** - Suffix text to be appended to the name of a team created from this template
* **Prefix Use Attribute** - Whether or not to use an attribute for the prefix
* **Suffix Use Attribute** - Whether or not to use an attribute for the suffix

Please see the steps below for details on how to define your own templates.

## Admin Center Templates

As detailed in the [Deployment guide](./Deployment-guide.md),a logic app named 'GetTeamsTemplates' retrieves templates defined in the admin center. This uses the Graph API, specifically this beta endpoint - https://learn.microsoft.com/en-us/graph/api/teamwork-list-teamtemplates?view=graph-rest-beta&tabs=http.

At the time of writing, this API is only available in beta and is yet to be released to v1.0.

**Only en-US locale templates are retrieved as at the time of writing. We will be adding support for localized templates in a future release.**

### Step 1: Define the Template in the Admin Center

1. Navigate to the Teams Admin Center.
2. Select 'Team templates' from the left hand menu (under 'Teams').
3. Click the '+Add' button to create a new template.
4. Choose whether to create a brand new template, use an existing team or start with an existing template.
5. Fill out the details and click 'Next' (**_Note - only English (United States) is supported with Provision Assist at the moment)_**

![Creating a template in the Admin Center](https://github.com/OfficeDev/microsoft-teams-apps-requestateam/wiki/Images/template1.png)

6. Create channels and configure apps for the template and click 'Submit'.

![Adding channels and apps to an Admin Center template](https://github.com/OfficeDev/microsoft-teams-apps-requestateam/wiki/Images/template2.png)

7. Once created, click on the template and copy the 'Template ID' value.

![Copying the template id](https://github.com/OfficeDev/microsoft-teams-apps-requestateam/wiki/Images/template3.png)

### Step 2: Execute the GetTeamsTemplates Logic App

This logic app is configured to run weekly, this can be changed to suit your requirements. It is worth noting that any new templates added to the Admin Center will automatically be added to the Teams Templates SharePoint list when this logic app runs. 

They will therefore be available in the Provision Assist Power App for selection by users. If you have templates you do not wish to display, please disable this logic app once you have executed it.

**_Note - After the above steps have been completed please WAIT 24 hours before running the logic app. It can take up to 24 hours for the template to be retrievable by the logic app. _**

1. Navigate to the Azure Portal.
2. Locate the resource group you created for Provision Assist.
3. Locate the GetTeamsTemplates Logic App.
4. Click 'Run Trigger' > 'Run'.
5. Check that the status of the Logic App displays succeeded. 
6. Open the 'Teams Templates' list.
7. Verify the template has been created as a list item. 

![GetTeamsTemplates logic app screenshot](./images/GetTeamsTemplatesLA.png)

Your template is now ready for use - make sure you refresh/reload the Provision Assist Power App if you have it open. When a user requests a team from the new template it will be created with the predefined content you configured in the Admin Center. 

**_Please note - Changes to templates in the Admin Center will not change Teams that have been previously created from the template._**

## Cloning Teams

In addition to being able to create teams from Admin Center templates, Provision Assist supports cloning of existing teams. 

The cloning team functionality uses v1.0 of the Microsoft Graph, specifically [Clone a team](https://docs.microsoft.com/en-us/graph/api/team-clone?view=graph-rest-1.0&tabs=http) so may be preferable to the other form of templating in a Production environment.

When the team is being cloned it is given the new Title, Description etc. that the user specifies when requesting the team. All original owners and members of the source team are removed and replaced with those that the user requested.

This option also offers additional functionality over Admin Center templates including being able to clone tabs and channels.

To use this functionality - follow the steps below.

### Step 1: Create a Team to use as a template

1. Create a team using the 'out of the box' functionality of Microsoft Teams.
2. Populate the team as you would like it - Channels, Apps, Tabs etc. (This is the content that will be cloned and set up as a new team).
2. Copy the Group Id for the team. You can get the Group Id from the URL that is generated when you click 'Get link to team'.

### Step 2: Add the template to the Provision Assist Teams Templates list

1. Navigate to the SharePoint site backing Provision Assist.
2. Open the 'Teams Templates' list.
3. Create a new list item with the following values:

* Title - Title for the template - this is the title the users will see when they pick from the list of templates
* Description - A description for the template
* Template Id - Leave blank
* Team Id - Paste the Group Id you copied earlier
* Admin Center Template - No

The key is to populate the 'Team Id' column as opposed to 'Template Id'. This is how the provisioning determines if we are cloning a team or creating from an Admin Center template.

![Creating template for cloning team screenshot](./images/CloneTeamsTemplate.png)

Your template is now ready for use. When a user raises a request which is approved, the team will be cloned and set up as a new team.
