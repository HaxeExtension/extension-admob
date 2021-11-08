package extension.admob;

import extension.admob.AdmobEvent;
import extension.admob.AdmobStatus;
import haxe.Json;
import openfl.Lib;
import lime.system.JNI;
import openfl.events.EventDispatcher;

class Admob
{
	public static inline var BANNER_SIZE_ADAPTIVE:Int = 0; //Anchored adaptive, somewhat default now (a replacement for SMART_BANNER), banner width is fullscreen, height calculated acordingly (might not work well in landscape orientation)
	public static inline var BANNER_SIZE_BANNER:Int = 1; //320x50
	public static inline var BANNER_SIZE_FLUID:Int = 2; //Android only. A dynamically sized banner that matches its parent's width and expands/contracts its height to match the ad's content after loading completes.
	public static inline var BANNER_SIZE_FULL_BANNER:Int = 3; //468x60
	public static inline var BANNER_SIZE_LARGE_BANNER:Int = 4; //320x100
	public static inline var BANNER_SIZE_LEADERBOARD:Int = 5; //728x90
	public static inline var BANNER_SIZE_MEDIUM_RECTANGLE:Int = 6; //300x250
	public static inline var BANNER_SIZE_WIDE_SKYSCRAPER:Int = 7; //160x600, Android only.
#if ios
	//https://stackoverflow.com/questions/63499520/app-tracking-transparency-how-does-effect-apps-showing-ads-idfa-ios14/63522856#63522856
	public static inline var IDFA_AUTORIZED:String = "IDFA_AUTORIZED";
	public static inline var IDFA_DENIED:String = "IDFA_DENIED";
	public static inline var IDFA_NOT_DETERMINED:String = "IDFA_NOT_DETERMINED";
	public static inline var IDFA_RESTRICTED:String = "IDFA_RESTRICTED";
	public static inline var IDFA_NOT_SUPPORTED:String = "IDFA_NOT_SUPPORTED";
#end
	
	//constants are taken from https://developer.android.com/reference/android/view/Gravity
	//you can use your own value for Android, if need more flexibility
	public static inline var BANNER_ALIGN_TOP:Int = 0x00000030 | 0x00000001; // TOP | CENTER_HORIZONTAL;
	public static inline var BANNER_ALIGN_BOTTOM:Int = 0x00000050 | 0x00000001; // BOTTOM | CENTER_HORIZONTAL;
	
	private static inline var EXT_ADMOB_ANDY:String = "admobex/AdmobEx";
	private static inline var EXT_ADMOB_IOS:String = "AdmobEx";
	
	private static var _inited:Bool = false;
	public static var status(default, null):AdmobStatus = new AdmobStatus();

	private static var _initIos:Bool->Bool->Bool->Bool->Dynamic->Void = function(testingAds:Bool, childDirected:Bool, enableRDP:Bool, requestIDFA:Bool, callback:Dynamic) {};
	private static var _initAndroid:Bool->Bool->Bool->Dynamic->Void = function(testingAds:Bool, childDirected:Bool, enableRDP:Bool, callback:Dynamic) {};
	private static var _showBanner:String->Int->Int->Void = function(id:String, size:Int, align:Int) {};
	private static var _hideBanner:Void->Void = function() {};
	private static var _loadInterstitial:String->Void = function(id:String) {};
	private static var _showInterstitial:Void->Void = function() {};
	private static var _loadRewarded:String->Void = function(id:String) {};
	private static var _showRewarded:Void->Void = function() {};
	private static var _setVolume:Float->Void = function(vol:Float){};

	/**
	   Initialization of Admob extension
	   @param	testingAds - whether enable testing ads or not
	   @param	childDirected - COPPA, whether your app is directed for children
	   @param	enableRDP - Restricted data processing, for California Consumer Privacy Act (CCPA)
	   @param	requestIDFA - iOS 14+ only (https://developers.google.com/admob/ios/ios14?hl=en), ignored, if iOS <14 or Android
	**/
	public static function init(testingAds:Bool = false, childDirected:Bool = false, enableRDP:Bool = false, requestIDFA:Bool = true):Void
	{
		if(_inited)
			return;
		_inited = true;
		
#if android
		try
		{
			_initAndroid = JNI.createStaticMethod(EXT_ADMOB_ANDY, "init", "(ZZZLorg/haxe/lime/HaxeObject;)V");
			_showBanner = JNI.createStaticMethod(EXT_ADMOB_ANDY, "showBanner", "(Ljava/lang/String;II)V");
			_hideBanner = JNI.createStaticMethod(EXT_ADMOB_ANDY, "hideBanner", "()V");
			_loadInterstitial = JNI.createStaticMethod(EXT_ADMOB_ANDY, "loadInterstitial", "(Ljava/lang/String;)V");
			_showInterstitial = JNI.createStaticMethod(EXT_ADMOB_ANDY, "showInterstitial", "()V");
			_loadRewarded = JNI.createStaticMethod(EXT_ADMOB_ANDY, "loadRewarded", "(Ljava/lang/String;)V");
			_showRewarded = JNI.createStaticMethod(EXT_ADMOB_ANDY, "showRewarded", "()V");
			_setVolume = JNI.createStaticMethod(EXT_ADMOB_ANDY, "setVolume", "(F)V");

			_initAndroid(testingAds, childDirected, enableRDP, status);
		}
		catch(e:Dynamic)
		{
			//trace("Android Init Exception: " + e);
			status.onStatus(AdmobEvent.INIT_FAIL, e);
		}
#elseif ios
		try
		{
			_initIos = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_init", 5);
			_showBanner = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_banner_show", 3);
			_hideBanner = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_banner_hide", 0);
			_loadInterstitial = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_interstitial_load", 1);
			_showInterstitial = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_interstitial_show", 0);
			_loadRewarded = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_rewarded_load", 1);
			_showRewarded = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_rewarded_show", 0);
			_setVolume = cpp.Lib.load(EXT_ADMOB_IOS, "admobex_set_volume", 1);

			_initIos(testingAds, childDirected, enableRDP, requestIDFA, status.onStatus);
		}
		catch(e:Dynamic)
		{
			//trace("iOS Init Exception: " + e);
			status.onStatus(AdmobEvent.INIT_FAIL, e);
		}
#end
	}
	
	public static function showBanner(id:String, size:Int = Admob.BANNER_SIZE_ADAPTIVE, align:Int = Admob.BANNER_ALIGN_BOTTOM)
	{
		if(!_inited)
			status.onStatus(AdmobEvent.BANNER_FAILED_TO_LOAD, "Extension is not initialized!");
		
		try
		{
			_showBanner(id, size, align);
		}
		catch(e:Dynamic)
		{
			trace("showBanner Exception: " + e);
			status.onStatus(AdmobEvent.BANNER_FAILED_TO_LOAD, e);
		}
	}

	public static function hideBanner()
	{
		if(!_inited)
			status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, "Extension is not initialized!");
		
		try
		{
			_hideBanner();
		}
		catch (e:Dynamic)
		{
			trace("hideBanner Exception: " + e);
			status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, e);
		}
	}
	
	public static function loadInterstitial(id:String):Void
	{
		if(!_inited)
			status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_LOAD, "Extension is not initialized!");
		
		try
		{
			_loadInterstitial(id);
		}
		catch(e:Dynamic)
		{
			trace("loadInterstitial Exception: " + e);
			status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_LOAD, e);
		}
	}
	
	public static function showInterstitial():Void
	{
		if(!_inited)
			status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_SHOW, "Extension is not initialized!");
		
		try
		{
			_showInterstitial();
		}
		catch(e:Dynamic)
		{
			trace("showInterstitial Exception: " + e);
			status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_SHOW, e);
		}
	}
	
	public static function loadRewarded(id:String):Void
	{
		if(!_inited)
			status.onStatus(AdmobEvent.REWARDED_FAILED_TO_LOAD, "Extension is not initialized!");
		
		try
		{
			_loadRewarded(id);
		}
		catch(e:Dynamic)
		{
			trace("loadInterstitial Exception: " + e);
			status.onStatus(AdmobEvent.REWARDED_FAILED_TO_LOAD, e);
		}
	}

	public static function showRewarded():Void
	{
		if(!_inited)
			status.onStatus(AdmobEvent.REWARDED_FAILED_TO_SHOW, "Extension is not initialized!");
		
		try
		{
			_showRewarded();
		}
		catch(e:Dynamic)
		{
			trace("showRewarded Exception: " + e);
			status.onStatus(AdmobEvent.REWARDED_FAILED_TO_SHOW, e);
		}
	}

	/**
	   Sets volume for Interstitial and Rewarded ads, if sets to 0 might get less ads, cause some advertisers don't allow muted ads.
	   @param	vol 0.0 - 1.0
	**/
	public static function setVolume(vol:Float):Void
	{
		if(!_inited)
			status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, "Extension is not initialized!");
		
		try
		{
			_setVolume(vol);
		}
		catch(e:Dynamic)
		{
			trace("setVolume Exception: "+e);
			status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, e);
		}
	}
}
