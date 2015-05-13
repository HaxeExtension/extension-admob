package extension.admob;

import openfl.Lib;

class AdMob {

	private static var inicialized:Bool=false;
	private static var testingAds:Bool=false;

	////////////////////////////////////////////////////////////////////////////

	private static var __init:String->String->String->Bool->Void = function(bannerId:String, interstitialId:String, gravityMode:String, testingAds:Bool){};
	private static var __showBanner:Void->Void = function(){};
	private static var __hideBanner:Void->Void = function(){};
	private static var __showInterstitial:Void->Void = function(){};
	private static var __onResize:Void->Void = function(){};
	private static var __refresh:Void->Void = function(){};

	////////////////////////////////////////////////////////////////////////////

	private static var lastTimeInterstitial:Int = -60*1000;
	private static var displayCallsCounter:Int = 0;
	
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0) {
		displayCallsCounter++;
		if( (Lib.getTimer()-lastTimeInterstitial)<(minInterval*1000) ) return;
		if( minCallsBeforeDisplay > displayCallsCounter ) return;
		displayCallsCounter = 0;
		lastTimeInterstitial = Lib.getTimer();
		try{
			__showInterstitial();
		}catch(e:Dynamic){
			trace("ShowInterstitial Exception: "+e);
		}
	}
	
	public static function enableTestingAds() {
		if ( testingAds ) return;
		if ( inicialized ) {
			var msg:String;
			msg = "FATAL ERROR: If you want to enable Testing Ads, you must enable them before calling INIT!.\n";
			msg+= "Throwing an exception to avoid displaying read ads when you want testing ads.";
			trace(msg);
			throw msg;
			return;
		}
		testingAds = true;
	}

	public static function initAndroid(bannerId:String, interstitialId:String, gravityMode:GravityMode){
		#if android
		if(inicialized) return;
		inicialized = true;
		try{
			// JNI METHOD LINKING
			__init = openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "init", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)V");
			__showBanner = openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "showBanner", "()V");
			__hideBanner = openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "hideBanner", "()V");
			__showInterstitial = openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "showInterstitial", "()V");
			__onResize = openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "onResize", "()V");

			__init(bannerId,interstitialId,(gravityMode==GravityMode.TOP)?'TOP':'BOTTOM',testingAds);
		}catch(e:Dynamic){
			trace("Android INIT Exception: "+e);
		}
		#end
	}
	
	public static function initIOS(bannerId:String, interstitialId:String, gravityMode:GravityMode){
		#if ios
		if(inicialized) return;
		inicialized = true;
		try{
			// CPP METHOD LINKING
			__init = cpp.Lib.load("adMobEx","admobex_init",4);
			__showBanner = cpp.Lib.load("adMobEx","admobex_banner_show",0);
			__hideBanner = cpp.Lib.load("adMobEx","admobex_banner_hide",0);
			__showInterstitial = cpp.Lib.load("adMobEx","admobex_interstitial_show",0);
			__refresh = cpp.Lib.load("adMobEx","admobex_banner_refresh",0);

			__init(bannerId,interstitialId,(gravityMode==GravityMode.TOP)?'TOP':'BOTTOM',testingAds);
		}catch(e:Dynamic){
			trace("iOS INIT Exception: "+e);
		}
		#end
	}
	
	public static function showBanner() {
		try {
			__showBanner();
		} catch(e:Dynamic) {
			trace("ShowAd Exception: "+e);
		}
	}
	
	public static function hideBanner() {
		try {
			__hideBanner();
		} catch(e:Dynamic) {
			trace("HideAd Exception: "+e);
		}
	}
	
	public static function onResize() {
		try{
			__onResize();
		}catch(e:Dynamic){
			trace("onResize Exception: "+e);
		}
	}
	
}
