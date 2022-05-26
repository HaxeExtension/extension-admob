# extension-admob
OpenFL extension for "Google AdMob" on iOS and Android.<br />
This extension allows you to integrate Google AdMob on your OpenFL application.

### Features
* iOS Mobile Ads SDK 9.4.0
* Android Mobile Ads SDK 20.6.0
* iOS14+ App Tracking Transparency (if iOS14+, app automatically presents user authorization request on first start)
* COPPA, CCPA
* Banners, Interstitial, Rewarded ads
* Ads sound volume control
* Events
* Some bugs (adaptive banners are not working on iOS due to bug in SDK) :)

### Installation
~~To install this library, you can simply get the library from haxelib like this:~~<br />
```bash
haxelib install extension-admob
```
Not yet, but hope I will upload it to haxelib eventually, so download code from Github for now.

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
Current version of Lime (7.9.0) doesn't support latest Gradle version.<br />
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
<android target-sdk-version="31" if="android" />
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
	Admob.setVolume(0); //set sound volume to 0 (mute) for interstitial and rewarded ads
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

### Not working, eh?
While I was working on this extension I came across lots of problems/bugs, so those links might help you, please go through them before contacting me:
1. https://community.openfl.org/t/extension-admob/13242/12
2. https://github.com/native-toolkit/lime/issues/1476

### Game with Admob extension
Google Play: https://play.google.com/store/apps/details?id=air.com.pozirk.allinonesolitaire<br />
App Store: https://itunes.apple.com/app/all-in-one-solitaire-free/id660577037<br />
Win/lose any game to see interstitial ad.

### Disclaimer
Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

AdMob is a registrered trademark of Google Inc.
http://unibrander.com/united-states/479956US/admob.html

### License
The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy; 2022 Pozirk Games (https://www.pozirk.com/)
