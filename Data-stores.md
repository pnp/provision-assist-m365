# Data Stores

The Provision Assist contains a number of SharePoint lists which are used for different purposes. See below to find out what each list is used for. The explanation of each column is also provided, with the exception of the 'Provisioning Requests' list.

### SharePoint Lists  

**Provisioning Requests**  

The Provisioning Requests list stores the details of all requests made through the Power App. If required, request list items can be updated by an admin outside of the Power App, however this is not recommended.

**Teams Templates**

The Teams Templates list stores the details of all templates used for creating teams, both Admin Center templates and teams to clone.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Name of the template|
|Template Id|Single line of text|Id of the template from the Teams Admin Center.|
|Team Id|Single line of text|Id of the team you wish to clone as a template (Office 365 Unified Group id).|
|Description|Multiple lines of text|Template description|
|Admin Center Template|Yes/No|Defines whether the template is an out of the box Microsoft Team Template - set to 'Yes'. Otherwise should be set to 'No' if you are cloning teams.|
|PrefixAttribute|Choice|Attribute to use for the prefix of a team created from this template.|
|SuffixAttribute|Choice|Attribute to use for the suffix of a team created from this template.|
|PrefixText|Single line of text|Prefix text to be prepended to the name of a team created from this template.|
|SuffixText|Single line of text|Suffix text to be appended to the name of a team created from this template.|
|PrefixUseAttribute|Yes/No|Whether or not to use an attribute for the prefix.|
|SuffixUseAttribute|Yes/No|Whether or not to use an attribute for the suffix.|

**Provisioning Request Settings**

The Provisioning Request Settings list stores all configurable settings for Provision Assist.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Name of the setting.|
|Description|Multiple lines of text|Description of the respective setting.|
|Value|Single line of text|Value of the respective setting.
|PrefixAttribute|Choice|Attribute to use for the prefix of the requested collaboration space.|
|SuffixAttribute|Choice|Attribute to use for the suffix of the requested collaboration space.|
|PrefixText|Single line of text|Prefix text to be prepended to the name of the collaboration space.|
|SuffixText|Single line of text|Suffix text to be appended to the name of the collaboration space.|
|PrefixUseAttribute|Yes/No|Whether or not to use an attribute for the prefix.|
|SuffixUseAttribute|Yes/No|Whether or not to use an attribute for the suffix.|
|ExternalSharingSetting|Choice|Default setting for external sharing e.g. Anyone, New and Existing Guests etc.|
|BlockedWordsValue|Single line of text|Stores blocked words configured in AAD as a comma separated string.|

**Provisioning Types**

The Provisioning Types list stores the types of collaboration space that can be requested and provisioned by the solution - Team Site, Office 365 Group etc. Please do not add new types to this list as they are unsupported and will not work. 

You should only change the value of the following columns: Title, Description, Allowed, Image, Learn Video URL, Icon, Prefix Text, Suffix Text, Prefix Use Attribute, Suffix Use Attribute, Visible To, Managed Path column values.

See the [Provisioning types](./Provisioning-types.md) documentation to find out more about this list.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Title of the collaboration space type e.g. Office 365 Group. You may change this value if use another terminology for this type in your organisation, for example a 'Team Site' could be a 'Document Management Area'.|
|Description|Multiple lines of text|Description of the respective collaboration space type, displayed to end users in the Power App.|
|Allowed|Yes/No|Whether or not this collaboration space type should be hidden from the Power App (disallow users from requesting this type of space).|
|TemplateID|Single line of text|Internal template id for the collaboration space type (only applies to SharePoint Team Sites).|
|Image|Hyperlink or Picture|Image of the collaboration space type that is displayed on the 'Recommendation' screen of the Power App.|
|WebTemplateID|Single line of text|Internal web template id for the collaboration space type (only applies to SharePoint Sites & O365 Groups)|
|Learn Video|Hyperlink or Picture|URL to a video which explains this type of collaboration space, this could be a video hosted on YouTube for example, it can be viewed directly in the Power App by the end user.|
|Icon|Hyperlink or Picture|Icon image of the collaboration space that is displayed on the 'Recommendation' screen of the Power App.|
|Prefix Text|Single line of text|Text prefix to be prepended to the name of the collaboration space when requested.|
|Prefix Use Attribute|Yes/No|Whether or not to use an attribute for the prefix.|
|Prefix Attribute|Choice|Attribute to use for the prefix.|
|Suffix Text|Single line of text|Text suffix to be appended to the name of the collaboration space when requested.|
|Suffix Use Attribute|Yes/No|Whether or not to use an attribute for the suffix.|
|Suffix Atribute|Choice|Attribute to use for the suffix.|
|Visible To|Person or Group|Security group containing users who this collaboration space type should be visible to. This MUST be a group and not individual users. If this column is left blank then the collaboration space type will be visible to all users who have access to the app. An example where this could be used is to restrict the creation of Communication Sites to those in Corporate Comms.
|Managed Path|Single line of text|Managed path to use when creating collaboration spaces using this type. You can use this to create SharePoint sites under the 'sites' managed path even if your tenant default is 'teams'.
|Default Visibility|Choice|Default visibility - 'Private' or 'Public' for this space type.
|Default Confidential Data|Yes/No|Default value for the Confidential Data radio button for this space type.

**Recommendation Scoring**

The Recommendation Scoring list determines which types of collaboration space are recommended to users based on the requirements they select when making the request.

You can edit existing requirements in this list or add your own. 

Columns exist with numeric values for each type of collaboration space, these values are the score for this space type. The higher the score, the more likely this collaboration space will be recommended to the user. The spaces with the highest scores are recommended (this is calculated in the Power App).

For more details on how the recommendation scoring works, please see the [Recommendation scoring](./Recommendation-scoring.md) documentation.

|Name of Column|Type|Comment|
|---|---|---|
|Requirement|Single line of text|Name of the requirement.|
|Modern Team Site|Number|Score for a Modern Team Site.|
|Modern Team Site Group|Number|Score for a Modern Team Site with Office 365 Group.|
|Communication Site|Number|Score for a Communication Site.|
|Microsoft Teams Team|Number|Score for a Microsoft Teams 'Team'.|
|Hub Site|Number|Score for a Hub Site.|
|Viva Engage Community|Number|Score for a Viva Engage Community.|

**Site Templates**

The Site Templates list stores the SharePoint Site Templates in the current tenant. A logic app (GetSiteTemplates) syncronizes these from the tenant into this list. 

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Title of the Site Template.|
|SiteTemplateId|Single line of text|Id of the Site Template.|
|PreviewImage|Hyperlink or Picture|URL to the preview image for the Site Template.|
|WebTemplate|Single line of text|Internal web template id for the Site Template|
|Store|Single line of text|Store for the Site Template, only applicable to out of the box templates.|
|Enabled|Yes/No|Whether or not the Site Template should be displayed in the Power App for the user to select.|
|ApplyPnPTemplate|Yes/No|Whether or not to associate and apply a PnP template with this Site Template. See the [PnP Templates](/PnP-templates.md) documentation to find out more.|
|PnPTemplateURL|Hyperlink|URL to a PnP template stored in the 'PnP Templates' library.|
|ThemeName|Single line of text|Name of a SharePoint theme to apply with this template e.g. Blue.|

**Hub Sites**

The Hub Sites list stores the Hub Sites in the current tenant. A logic app (GetHubSites) syncronises these from the tenant into this list. 

**Please do not change values directly in this list.**

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Title of the Hub Site.|
|HubSiteId|Single line of text|Id of the Hub Site.|
|Owner|Person or Group|Owner of the Hub Site (unused at the time of writing).|
|Second Owner|Person or Group|Second owner of the Hub Site (unused at the time of writing).|
|Enabled|Yes/No|Whether or not the Hub Site should be displayed in the Power App.|

**Time Zones**

The Time Zones list stores all time zones that can be selected in the app and set on a SharePoint site.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Title of the time zone e.g. (UTC-12:00) International Date Line West. |
|Time Zone Id|Number|Id of the time zone.|

**Locales**

The Locales list stores all locales that can be selected in the app and set on a SharePoint site.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Title of the locale e.g. (Arabic - Egypt). |
|LCID|Number|Id of the locale.|

**IP Labels**

The IP Labels list stores all sensitivity labels from the current tenant. Read the [Sensitivity labels](/Sensitivity-labels.md) documentation to find out more.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Name of the label. |
|Label Name|Single line of text|Name of the label. |
|Label Id|Single line of text|Id of the label. |
|Label Description|Multiple lines of text|Description of the label. |
|Enabled|Yes/No|Whether or not the label should be displayed in the Power App for users to select. |

**Retention Labels**

The Retention Labels list stores all retention labels from the current tenant. These must be added manually to the list as there is no Graph API to retrieve these automatically. Read the [Retention labels](/Retention-labels.md) documentation to find out more.

|Name of Column|Type|Comment|
|---|---|---|
|Title|Single line of text|Name of the label. |
|Label Name|Single line of text|Name of the label. |
|Label Description|Multiple lines of text|Description of the label. |