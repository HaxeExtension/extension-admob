# extension-admob

![](https://img.shields.io/github/repo-size/MAJigsaw77/extension-admob) ![](https://badgen.net/github/open-issues/MAJigsaw77/extension-admob) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[Lime](https://lime.openfl.org) extension for integrating [Google AdMob](https://admob.google.com/home) on iOS and Android.

### Installation

To install **extension-admob**, follow these steps:

1. **Haxelib Installation**
   ```bash
   haxelib install extension-admob
   ```

2. **Haxelib Git Installation (for latest updates)**
   ```bash
   haxelib git extension-admob https://github.com/FunkinDroidTeam/extension-admob.git
   ```

3. **Project Configuration** (Add the following code to your **project.xml** file)
   ```xml
   <section if="cpp">
   	<haxelib name="extension-admob" if="mobile" />
   </section>
   ```

### Setup

To configure **extension-admob** for your project, follow these steps:

1. **iOS Frameworks Installation**  
   To set up the required frameworks for iOS compilation, navigate to the directory where the library is installed and execute the following command:
   ```bash
   chmod +x setup_admob_ios.sh && ./setup_admob_ios.sh
   ```

2. **Add AdMob App IDs**  
   Include your AdMob app IDs in your **project.xml**. Ensure you specify the correct IDs for both Android and iOS platforms.
   ```xml
   <setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123457" if="android"/>
   <setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123458" if="ios"/>
   ```

3. **GDPR Consent Management**  
   Beginning January 16, 2024, Google requires publishers serving ads in the EEA and UK to use a certified consent management platform (CMP). This extension integrates Google's UMP SDK to display a consent dialog during the first app launch. Ads may not function if the user does not provide consent.

4. **Checking GDPR Consent Requirements**  
   You can determine if the GDPR consent dialog is required based on the user's location:
   ```haxe
   if (admob.Admob.isPrivacyOptionsRequired())
       trace("GDPR consent dialog is required.");
   ```

5. **Verify User Consent**
   Check if the user has consented to personalized ads:
   ```haxe
   if (admob.Admob.getConsent() == admob.AdmobConsent.FULL)
    trace("User consented to personalized ads.");
   else
    trace("User did not consent to personalized ads. Ads may not work.");
   ```

6. **Check Consent for Specific Purposes**
   Verify if the user has consented to individual purposes, such as purpose 0:
   ```haxe
   if (admob.Admob.hasConsentForPurpose(0) == 1)
    trace("User has consented to purpose 0.");
   else
    trace("User has not consented to purpose 0.");
   ```

7. Reopen Privacy Options Dialog
   If needed, allow users to manage their consent options again.
   ```haxe
   admob.Admob.showPrivacyOptionsForm();
   ```

8. Load and Show Ads
   Add the following snippets to display ads in your app:

   - **Banner Ad**
     ```haxe
     admob.Admob.showBanner("ca-app-pub-XXXX/XXXXXXXXXX");
     ```

   - **Interstitial Ad**
     ```haxe
     admob.Admob.onStatus.add(function(event:String, message:String):Void
     {
     	if (event == admob.AdmobEvent.INTERSTITIAL_LOADED)
     		admob.Admob.showInterstitial();
     });
     admob.Admob.loadInterstitial("ca-app-pub-XXXX/XXXXXXXXXX");
     ```

   - **Rewarded Ad**
     ```haxe
     admob.Admob.onStatus.add(function(event:String, message:String):Void
     {
     	if (event == admob.AdmobEvent.REWARDED_LOADED)
     		admob.Admob.showRewarded();
     });
     admob.Admob.loadRewarded("ca-app-pub-XXXX/XXXXXXXXXX");
     ```

   - **App Open Ad**
     ```haxe
     admob.Admob.onStatus.add(function(event:String, message:String):Void
     {
     	if (event == admob.AdmobEvent.APP_OPEN_LOADED)
     		admob.Admob.showAppOpen();
     });
     admob.Admob.loadAppOpen("ca-app-pub-XXXX/XXXXXXXXXX");
     ```

### Disclaimer

[Google](http://unibrander.com/united-states/140279US/google.html) is a registered trademark of Google Inc.

[AdMob](http://unibrander.com/united-states/479956US/admob.html) is a registrered trademark of Google Inc.

### License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright (c) 2023 Pozirk Games contributors
