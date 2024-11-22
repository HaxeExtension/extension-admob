# extension-admob

![](https://img.shields.io/github/repo-size/FunkinDroidTeam/extension-admob) ![](https://badgen.net/github/open-issues/FunkinDroidTeam/extension-admob) ![](https://badgen.net/badge/license/MIT/green)

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

1. **Add AdMob App IDs**  
   Include your AdMob app IDs in your **project.xml**. Ensure you specify the correct IDs for both Android and iOS platforms.

```xml
<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123457" if="android"/>
<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123458" if="ios"/>
```

2. **GDPR Consent Management**  
   Beginning January 16, 2024, Google requires publishers serving ads in the EEA and UK to use a certified consent management platform (CMP). This extension integrates Google's UMP SDK to display a consent dialog during the first app launch. Ads may not function if the user does not provide consent.

3. **Checking GDPR Consent Requirements**  
   You can determine if the GDPR consent dialog is required based on the user's location:
   ```haxe
   if (admob.Admob.isPrivacyOptionsRequired())
       trace("GDPR consent dialog is required.");
   ```

4. **Verify User Consent**
   Check if the user has consented to personalized ads:
   ```haxe
   if (admob.Admob.getConsent() == admob.AdmobConsent.FULL)
    trace("User consented to personalized ads.");
   else
    trace("User did not consent to personalized ads. Ads may not work.");
   ```

5. **Check Consent for Specific Purposes**
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

   - **Interstitial Ad**
     ```haxe
     admob.Admob.loadInterstitial("ca-app-pub-XXXX/XXXXXXXXXX");
     admob.Admob.showInterstitial();
     ```

   - **Banner Ad**
     ```haxe
     admob.Admob.showBanner("ca-app-pub-XXXX/XXXXXXXXXX");
     ```

   - **Rewarded Ad**
     ```haxe
     admob.Admob.loadRewarded("ca-app-pub-XXXX/XXXXXXXXXX");
     admob.Admob.showRewarded();
     ```
