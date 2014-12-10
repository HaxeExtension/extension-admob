package extension.admob;

import openfl.Lib;

class AdMob {

	////////////////////////////////////////////////////////////////////////////	
	private static var __init:String->String->String->Void = 
		#if android
			openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "init", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
		#elseif ios
			cpp.Lib.load("adMobEx","admobex_init",3);
		#else
			function(bannerId:String, interstitialId:String, gravityMode:String){};
		#end

	////////////////////////////////////////////////////////////////////////////	
	private static var __showBanner:Void->Void = 
		#if android
			openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "showBanner", "()V");
		#elseif ios
			cpp.Lib.load("adMobEx","admobex_banner_show",0);
		#else
			function(){};
		#end

	////////////////////////////////////////////////////////////////////////////	
	private static var __hideBanner:Void->Void = 
		#if android
			openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "hideBanner", "()V");
		#elseif ios
			cpp.Lib.load("adMobEx","admobex_banner_hide",0);
		#else
			function(){};
		#end

	////////////////////////////////////////////////////////////////////////////	
	private static var __showInterstitial:Void->Void = 
		#if android
			openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "showInterstitial", "()V");
		#elseif ios
			cpp.Lib.load("adMobEx","admobex_interstitial_show",0);
		#else
			function(){};
		#end

	////////////////////////////////////////////////////////////////////////////	
	private static var __onResize:Void->Void = 
		#if android
			openfl.utils.JNI.createStaticMethod("admobex/AdMobEx", "onResize", "()V");
		#else
			function(){};
		#end

	////////////////////////////////////////////////////////////////////////////	
	private static var __refresh:Void->Void = 
		#if ios
			cpp.Lib.load("adMobEx","admobex_banner_refresh",0);
		#else
			function(){};
		#end

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
	
	public static function initAndroid(bannerId:String, interstitialId:String, gravityMode:GravityMode){
		#if android
		try{
			__init(bannerId,interstitialId,(gravityMode==GravityMode.TOP)?'TOP':'BOTTOM');
		}catch(e:Dynamic){
			trace("Android INIT Exception: "+e);
		}
		#end
	}
	
	public static function initIOS(bannerId:String, interstitialId:String, gravityMode:GravityMode){
		#if ios
		try{
			__init(bannerId,interstitialId,(gravityMode==GravityMode.TOP)?'TOP':'BOTTOM');
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
