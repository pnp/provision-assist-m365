# Regional Settings

Provision Assist includes the ability for users to choose a Time Zone and Locale to apply to their area when making a request.

This time zone/locale will be applied to the SharePoint site using PnP PowerShell during provisioning. If the area is a Team, Group or Viva Engage community then the regional settings will be applied to the SharePoint site that backs this.

---
## What does this look like?

Two lists are used in the SharePoint site to support this functionality:

**Time Zones:**

![Time zones list screenshot](./images/TimeZonesList.png)

This list stores all the Locales (LCIDs) that SharePoint Online supports. This list is used in the Power App to allow the user to select a locale. If you want to restrict the locales a user can select you can delete items from this list that are not required.

**Locales:**

![Locales list screenshot](./images/LocalesList.png)

**Power App/End User view:**

![Time zones and locales end user view screenshot](./images/TimeZoneLocalePA.png)

When making a request, the user can select a time zone/locale from the combo boxes provided on the 'Area Information' screen.

---
## Default Time Zone/Locale Configuration - Optional

You can configure a default time zone/locale that will appear when the user creates a request. The user can override the default and select their own but this ensures it will not be blank when they make the request. 

To configure a default time zone/locale, follow the steps below:

1. Navigate to the 'Provisioning Request Settings' list in the SharePoint site.
2. Edit the 'DefaultTimeZone' and 'DefaultLCID' and update the value in the 'Value' column to the time zone and LCID that you want as the default. You can obtain the ids from the Time Zones and Locales lists.

A default time zone/locale is now configured and will take affect when the Power App is next launched.