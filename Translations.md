# Multilingual support
## Overview
The Provision Assist Power App supports multiple languages, so that users can interact with the app in the default language of their browser or MS Teams client. The app currently supports English and Dutch, but it can be easily extended to include more languages.

## How Multilingual Support Works
The app uses a custom component called TranslationLibrary, which contains the translations for all the labels in the app. The translations are provided in the JSON format in the OnReset action of the component. For example, the JSON object for the English language looks like this:

```{Language: "en-US"; Labels: { lblWelcome: "Welcome to the Provision Assist"; btnCancel: "Cancel"; btnBack: "Back"; btnNext: "Next"; btnSubmit: "Submit";  ... }}```

The app has a global variable called varLanguage, which stores the current language of the user. When the app loads, it checks the language setting of the user's device and assigns it to the varLanguage variable. If the user's language is not defined in the TranslationLibrary component, the app defaults to English.

The app uses the Language variable and the TranslationLibrary component to display the labels in the user's language. For example, to display the welcome message, the app uses this formula:

```cmpTranslationWS.Labels.lblWelcome```
 
This formula returns the value of the Welcome key in the JSON object that corresponds to the Language variable. If the Language variable is "en", the formula returns "Welcome to the Provision Assist App". If the Language variable is "nl", the formula returns "Welkom bij de Provission Assist App".

For more detailed information on how the TranslationLibrary component was built, you can refer to this URL: [Build a multi-language app](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/multi-language-apps)

## How to Add More Languages
To add more languages to the app, you need to modify the OnReset action of the TranslationLibrary component. You need to add a new JSON object for each language you want to support, with the same keys as the existing languages, but with different values. For example, to add French as a new language, you need to add this JSON object:

```{Language: "fr-FR"; Labels: { lblWelcome: "Bienvenue dans Provision Assist"; btnCancel: "Annuler"; btnBack: "Retourner"; btnNext: "Ensuite"; btnSubmit: "Soumettre";  ... }}```

For your convinience, full formula from the OnReset action is saved in the file TranslationsProvisionAssist.json under Source/Power Apps. You can use it to prepare the translations before pasting it into the  OnReset action of the component of the app.
