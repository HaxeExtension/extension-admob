# extension-admob

OpenFL extension for "Google AdMob" on iOS and Android.<br />
This extension allows you to integrate Google AdMob on your OpenFL application.<br />
*Extension still has some bugs.*

### Main Features

* iOS SDK 8.5
* Android SDK 20.0.3
* iOS14+ App Tracking Transparency (if iOS14+, app automatically presents user authorization request on first start)
* COPPA, CCPA
* Banners, Interstitial, Rewarded ads
* Ads sound volume control
* Events

### Prerequisites
Set the following in your project.xml, replace value with your app id from Admob:
```xml
<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123457" if="android"/>
<setenv name="ADMOB_APPID" value="ca-app-pub-XXXXX123458" if="ios"/>
```

For Android:<br />
You need to install the latest version of Android SDK Platfrom, Android SDK Platfrom-Tools and Android SDK Build-Tools.<br />
Current version of Lime (7.9.0) doesn't support latest Gradle version.<br />
Open file "\lib\lime\X,X,X\templates\android\template\gradle.properties" and add the following lines in the end of the file to fix that:
```
android.useAndroidX=true
android.enableJetifier=true
```

### Sample code

```haxe
import extension.admob.Admob;
import extension.admob.AdmobEvent;

...

Admob._status.addEventListener(AdmobEvent.INIT_OK, onInitOk); //add more event listeners, if needed
Admob.init(); //set first param to true to enable testing ads, default is false

...

private function onInitOk(ae:AdmobEvent):Void
{
	trace(ae.type, ae._data);
	Admob.setVolume(0); //set sound volume to 0 (mute)
	//you can start loading ads after successful initialization
}

...

Admob.showBanner("[BANNER_ID]", Admob.BANNER_SIZE_BANNER, Admob.BANNER_ALIGN_TOP);

...

Admob.hideBanner();

...

Admob._status.addEventListener(AdmobEvent.INTERSTITIAL_LOADED, onLoadInterstitial);
Admob.loadInterstitial([INTERSTITIAL_ID]);

...


private function onLoadInterstitial(ae:AdmobEvent):Void
{
	Admob.showInterstitial();
}
```

### How to Install

~~To install this library, you can simply get the library from haxelib like this:~~<br />
*Not yet, but hope I will upload it to haxelib.*
```bash
haxelib install extension-admob
```

Once this is done, you just need to add this to your project.xml
```xml
<haxelib name="extension-admob" />
```

Also, you may need to set android sdk version to 29 or higher (as some versions of google play services requires that):
```xml
<android target-sdk-version="29" if="android" />
```

### Disclaimer

Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

AdMob is a registrered trademark of Google Inc.
http://unibrander.com/united-states/479956US/admob.html

### License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy; 2021 Pozirk Games (https://www.pozirk.com/)
