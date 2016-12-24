#extension-admob

OpenFL extension for "Google AdMob" on iOS and Android.
This extension allows you to easily integrate Google AdMob on your OpenFL (or HaxeFlixel) game / application.

###Main Features

* Banners & Interstitial Support.
* Setup your banners to be on top or on the bottom of the screen.
* Allows you to specify min amount of time between interstitial displays (to avoid annoying your users).
* Allows you to specify min amount of calls to interstitial before it actually gets displayed (to avoid annoying your users).
* Callback support for Interstitial Events.

###Simple use Example

```haxe
// This example show a simple use case.

import extension.admob.AdMob;
import extension.admob.GravityMode;

class MainClass {

	function new() {
		// first of all, decide if you want to display testing ads by calling enableTestingAds() method.
		// Note that if you decide to call enableTestingAds(), you must do that before calling INIT methods.
		AdMob.enableTestingAds();

		// if your app is for children and you want to enable the COPPA policy,
		// you need to call tagForChildDirectedTreatment(), before calling INIT.
		// AdMob.tagForChildDirectedTreatment();

		// If you want to get instertitial events (LOADING, LOADED, CLOSED, DISPLAYING, ETC), provide
		// some callback function for this.
		AdMob.onInterstitialEvent = onInterstitialEvent;
		
		// then call init with Android and iOS banner IDs in the main method.
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
	
	function onInterstitialEvent(event:String) {
		trace("THE INSTERSTITIAL IS "+event);
		/*
		Note that the "event" String will be one of this:
		    AdMob.LEAVING
		    AdMob.FAILED
		    AdMob.CLOSED
		    AdMob.DISPLAYING
		    AdMob.LOADED
		    AdMob.LOADING
		
		So, you can do something like:
		if(event == AdMob.CLOSED) trace("The player dismissed the ad!");
		else if(event == AdMob.LEAVING) trace("The player clicked the ad :), and we're leaving to the ad destination");
		else if(event == AdMob.FAILED) trace("Failed to load the ad... the extension will retry automatically.");
		*/
	}
	
}

```

###How to Install

To install this library, you can simply get the library from haxelib like this:
```bash
haxelib install extension-admob
```

Once this is done, you just need to add this to your project.xml
```xml
<haxelib name="extension-admob" />
```

Also, you may need to set android sdk version to 23 or higher (as some versions of google play services requires that):
```xml
<android target-sdk-version="23" if="android" />
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
