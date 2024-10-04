# extension-admob
Google AdMob OpenFL extension for iOS and Android.<br />
This extension allows you to integrate Google AdMob with your OpenFL application.

### Features
* iOS Mobile Ads SDK 11.10.0 (Xcode 15.1+, iOS 13+)
* Android Mobile Ads SDK is always the latest automatically (update with SDK Manager)
* GDPR for EEA and UK, read how to setup here: https://support.google.com/admob/answer/10113207
* App Tracking Transparency (if iOS14+, app automatically presents user authorization request on first start)
* COPPA, CCPA
* Banners, Interstitial, Rewarded ads
* Ads sound volume control
* Events
* Some bugs :)

### Installation
To install this library, you can simply get the library from haxelib like this:<br />
```bash
haxelib install extension-admob
```

Once this is done, you just need to add this to your project.xml
```xml
<haxelib name="extension-admob" />
```

### Setup
Set the following in your project.xml, replace value with your app id from Admob:
```xml
<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123457" if="android"/>
<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123458" if="ios"/>
```

For Android:<br />
You need to install the latest version of Android SDK Platfrom (31+), Android SDK Platfrom-Tools, Android SDK Build-Tools and Google Play services.<br />
Version of Lime (8.2.0) doesn't support (probably?) latest Gradle version.<br />
More details here: https://github.com/haxelime/lime/issues/1476

You need to set Gradle version in your project.xml file:
```xml
<config:android gradle-version="6.7.1" if="android" />
<config:android gradle-plugin="4.2.0" if="android" />
```

And fix some other problems with Lime, open file "\lib\lime\X,X,X\templates\android\template\gradle.properties" and add the following lines in the end of the file:
```
android.useAndroidX=true
android.enableJetifier=true
```

Also, you may need to set android sdk version to 31 or higher (as some versions of google play services requires that):
```xml
<android target-sdk-version="34" if="android" />
```

### Sample code
```haxe
import extension.admob.AdMob;
import extension.admob.AdmobEvent;

...

Admob.status.addEventListener(AdmobEvent.INIT_OK, onInitOk); //you can add more event listeners, if needed
Admob.init(); //set first param to true to enable testing ads, default is false

...

private function onInitOk(ae:AdmobEvent):Void
{
	trace(ae.type, ae.data);
	Admob.setVolume(0.5); //set sound volume to 0.5 for interstitial and rewarded ads
	Admob.setVolume(-1); //mute
	//you can start showing/loading ads after successful initialization
}

...

Admob.showBanner("[BANNER_ID]", Admob.BANNER_SIZE_BANNER, Admob.BANNER_ALIGN_TOP);

...

Admob.hideBanner();

...

Admob.status.addEventListener(AdmobEvent.INTERSTITIAL_LOADED, onLoadInterstitial);
Admob.loadInterstitial([INTERSTITIAL_ID]);

...


private function onLoadInterstitial(ae:AdmobEvent):Void
{
	Admob.showInterstitial();
}
```

Beginning 16 January 2024, Google will require all publishers serving ads to EEA and UK users to use a Google-certified consent management platform (CMP).
This extension uses Google's UMP SDK and shows a consent dialog on the first app start.
If the user does not consent, there is a high probability that ads will not work.

After the user makes the choice, the dialog is not shown anymore unless consent has expired.
You can check if the GDPR dialog is required and show it manually.

How to know, if GDPR dialog is required (ie user is from UK or EEA):
```haxe
if( Admob.isPrivacyOptionsRequired() == 1)
	//required
```

How to know, if user consented to personalized ads:
```haxe
if(Admob.getConsent() == Admob.CONSENT_FULL)
	//constented, ads should work fine
```
You can also check consent to each purpose individually:
```haxe
if(Admob.hasConsentForPuprpose(0) == 1)
	//consented to purpose 1, you should check all the purposes, there are like 10 of them (0-9)
```
More details about purposes and how users' consent influences ads:
https://support.google.com/admob/answer/9760862#consent-policies
From my experience, unless the user consents to everything ("Consent" at the initial dialog or "Accept all" at the Manage options dialog), ads will not work!

How to show privacy dialog to user again:
```haxe
Admob.showPrivacyOptionsForm();
```


### Not working, eh?
While I was working on this extension I came across lots of problems/bugs, so those links might help you, please go through them before contacting me:
1. https://community.openfl.org/t/extension-admob/13242/12
2. https://github.com/native-toolkit/lime/issues/1476

### Games with Admob extension
Google Play: https://play.google.com/store/apps/details?id=air.com.pozirk.allinonesolitaire<br />
App Store: https://itunes.apple.com/app/all-in-one-solitaire-free/id660577037<br />
Win/lose/restart any game to see interstitial ad.

### Disclaimer
Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

AdMob is a registrered trademark of Google Inc.
http://unibrander.com/united-states/479956US/admob.html

### License
The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright (c) 2024 OpenFL contributors
