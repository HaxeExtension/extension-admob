openfl-admob
=======

OpenFL extension for "Google AdMob" on iOS and Android.
This extension allows you to easily integrate Google AdMob on your OpenFL (or HaxeFlixel) game / application.

###Main Features

* Banners & Interstitial Support.
* Setup your banners to be on top or on the bottom of the screen.
* Allows you to specify min amount of time between interstitial displays (to avoid annoying your users).
* Allows you to specify min amount of calls to interstitial before it actually gets displayed (to avoid annoying your users).

###Simple use Example

```haxe
// This example show a simple use case.

import extension.admob.AdMob;
import extension.admob.GravityMode;

class MainClass {

	function new() {
		// first of all... call init with Android and iOS banner IDs in the main method.
		// parameters are (bannerId:String, interstitialId:String, gravityMode:GravityMode).
		// if you don't have the bannerId and interstitialId, go to www.google.com/ads/admob to create them.

		AdMob.initAndroid("ca-app-pub-XXXXX123456","ca-app-pub-XXXXX123457", GravityMode.BOTTOM); // may also be GravityMode.TOP
		AdMob.initIOS("ca-app-pub-XXXXX123458","ca-app-pub-XXXXX123459", GravityMode.BOTTOM); // may also be GravityMode.TOP

		// NOTE: If your game allows screen rotation, you should call AdMob.onResize(); when rotation happens.
	}
	
	function gameOver() {
		// some implementation
		AdMob.showInterstitial(0);

		/* NOTE:
		showInterstitial function has two parameters you can use to control how often you want to display the interstitial ad.

		public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0);

		* The banner will not show if it was displayed less than "minInterval" seconds ago.
		* The banner will show only after "#minCallsBeforeDisplay" calls to showInterstitial function.

		- To display an interstitial after every time the game finishes, call:
		AdMob.showInterstitial(0);
		- To avoid displaying the interstitial if the game was too short (60 seconds), call:
		AdMob.showInterstitial(60);
		- To display an interstitial every 3 finished games call:
		AdMob.showInterstitial(0,3);
		- To display an interstitial every 3 finished games (but never before 120 secs since last display), call:
		AdMob.showInterstitial(120,3); */
	}
	
	function mainMenu() {
		// some implementation
		AdMob.showBanner(); // this will show the AdMob banner.
	}

	function beginGame() {
		// some implementation
		AdMob.hideBanner(); // if you don't want the banner to be on screen while playing... call AdMob.hideBanner();
	}
	
}

```

###How to Install

To install this library, you can simply get the library from haxelib like this:
```bash
haxelib install openfl-admob
```

Also, you'll need to download the google-play-services_lib and android-support-v4 from your Android SDK Manager. To do that, you need to execute the android tool from:
```bash
$ANDROID_SDK/tools/android
```

Then select *Google Play Services* and *Android Support Library* under the "Extras" section.

Once this is done, you just need to add this to your project.xml
```xml
<haxelib name="openfl-admob" />
```

###Disclaimer

Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

AdMob is a registrered trademark of Google Inc.
http://unibrander.com/united-states/479956US/admob.html

###License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy; 2013 SempaiGames (http://www.sempaigames.com)

Author: Federico Bricker
