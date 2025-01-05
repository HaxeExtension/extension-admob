package extension.admob.ios;

#if ios
import extension.admob.AdmobBannerAlign;
import extension.admob.AdmobBannerSize;
import haxe.MainLoop;

/**
 * A class to manage AdMob advertisements on iOS devices.
 */
@:buildXml("<include name=\"${haxelib:extension-admob}/project/admob-ios/Build.xml\" />")
@:headerInclude("admob.hpp")
class AdmobIOS
{
	/**
	 * Event triggered for status updates from AdMob.
	 */
	private static var _onStatus:Null<String->String->Void> = null;

	@:noCompletion
	private static var _initialized:Bool = false;

	/**
	 * Initializes the AdMob extension.
	 *
	 * @param testingAds Whether to use testing ads.
	 * @param childDirected Whether the ads should comply with child-directed policies.
	 * @param enableRDP Whether to enable restricted data processing (RDP).
	 */
	public static function init(testingAds:Bool = false, childDirected:Bool = false, enableRDP:Bool = false):Void
	{
		if (!_initialized)
		{
			initAdmob(testingAds, childDirected, enableRDP, cpp.Callable.fromStaticFunction(onAdmobStatus));	
			_initialized = true;
		}
		else
			dispatchEvent(AdmobEvent.FAIL, "Admob extension has been already initialized");
	}

	@:noCompletion
	private static function onAdmobStatus(event:cpp.ConstCharStar, value:cpp.ConstCharStar):Void
	{
		MainLoop.runInMainThread(function():Void
		{
			dispatchEvent((event : String), (value : String));
		});
	}

	/**
	 * Shows a banner ad.
	 *
	 * @param id The banner ad ID.
	 * @param size The banner size (default: adaptive).
	 * @param align The banner alignment (default: bottom).
	 */
	public static function showBanner(id:String, size:Int = AdmobBannerSize.ADAPTIVE, align:Int = AdmobBannerAlign.BOTTOM):Void
	{
		if (_initialized)
			showAdmobBanner(id, size, align);
		else
			dispatchFrustration();
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		if (_initialized)
			hideAdmobBanner();
		else
			dispatchFrustration();
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 */
	public static function loadInterstitial(id:String):Void
	{
		if (_initialized)
			loadAdmobInterstitial(id);
		else
			dispatchFrustration();
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		if (_initialized)
			showAdmobInterstitial();
		else
			dispatchFrustration();
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 */
	public static function loadRewarded(id:String):Void
	{
		if (_initialized)
			loadAdmobRewarded(id);
		else
			dispatchFrustration();
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		if (_initialized)
			showAdmobRewarded();
		else
			dispatchFrustration();
	}

	/**
	 * Loads a "app open" ad.
	 *
	 * @param id The "app open" ad ID.
	 */
	public static function loadAppOpen(id:String):Void
	{
		if (_initialized)
			loadAdmobAppOpen(id);
		else
			dispatchFrustration();
	}

	/**
	 * Displays a loaded "app open" ad.
	 */
	public static function showAppOpen():Void
	{
		if (_initialized)
			showAdmobAppOpen();
		else
			dispatchFrustration();
	}

	/**
	 * Sets the volume for interstitial and rewarded ads.
	 *
	 * @param vol The volume level (0.0 - 1.0, or -1 for muted).
	 */
	public static function setVolume(vol:Float):Void
	{
		if (_initialized)
			setAdmobVolume(vol);
		else
			dispatchFrustration();
	}

	/**
	 * Checks if consent for a specific purpose has been granted.
	 *
	 * @param purpose The purpose ID (default: 0).
	 * @return `1` for consent granted, `0` for not granted, `-1` for unknown.
	 */
	public static function hasConsentForPurpose(purpose:Int = 0):Int
	{
		if (_initialized)
			return hasAdmobConsentForPurpose(purpose);
		else
			dispatchFrustration();
		
		return -1;
	}

	/**
	 * Retrieves the current user consent status.
	 *
	 * @return A string representing the consent status.
	 */
	public static function getConsent():String
	{
		if (_initialized)
			return getAdmobConsent();
		else
			dispatchFrustration();
		
		return "";
	}

	/**
	 * Checks if privacy options are required.
	 *
	 * @return `true` if required, `false` otherwise.
	 */
	public static function isPrivacyOptionsRequired():Bool
	{
		if (_initialized)
			return isAdmobPrivacyOptionsRequired();
		else
			dispatchFrustration();
		
		return false;
	}

	/**
	 * Displays the privacy options form.
	 */
	public static function showPrivacyOptionsForm():Void
	{
		if (_initialized)
			showAdmobPrivacyOptionsForm();
		else
			dispatchFrustration();
	}
	
	/**
	 * Add events' listener
	 */
	public static function listenEvents(onStatus:String->String->Void):Void
	{
		_onStatus = onStatus;
	}
	
	/**
	 * Dispatcjh and event, if there is a listener
	 */
	public static function dispatchEvent(status:String, data:String):Void
	{
		if(_onStatus != null)
			_onStatus(status, data);
	}
	
	/**
	 * I don't how to describe this
	 */
	private static function dispatchFrustration():Void
	{
		dispatchEvent(status, "Admob extension is not initialized");
	}

	@:native("initAdmob")
	extern public static function initAdmob(testingAds:Bool, childDirected:Bool, enableRDP:Bool,
		callback:cpp.Callable<(event:cpp.ConstCharStar, value:cpp.ConstCharStar) -> Void>):Void;

	@:native("showAdmobBanner")
	extern public static function showAdmobBanner(id:cpp.ConstCharStar, size:Int, align:Int):Void;

	@:native("hideAdmobBanner")
	extern public static function hideAdmobBanner():Void;

	@:native("loadAdmobInterstitial")
	extern public static function loadAdmobInterstitial(id:cpp.ConstCharStar):Void;

	@:native("showAdmobInterstitial")
	extern public static function showAdmobInterstitial():Void;

	@:native("loadAdmobRewarded")
	extern public static function loadAdmobRewarded(id:cpp.ConstCharStar):Void;

	@:native("showAdmobRewarded")
	extern public static function showAdmobRewarded():Void;

	@:native("loadAdmobAppOpen")
	extern public static function loadAdmobAppOpen(id:cpp.ConstCharStar):Void;

	@:native("showAdmobAppOpen")
	extern public static function showAdmobAppOpen():Void;

	@:native("setAdmobVolume")
	extern public static function setAdmobVolume(vol:Single):Void;

	@:native("hasAdmobConsentForPurpose")
	extern public static function hasAdmobConsentForPurpose(purpose:Int):Int;

	@:native("getAdmobConsent")
	extern public static function getAdmobConsent():cpp.ConstCharStar;

	@:native("isAdmobPrivacyOptionsRequired")
	extern public static function isAdmobPrivacyOptionsRequired():Bool;

	@:native("showAdmobPrivacyOptionsForm")
	extern public static function showAdmobPrivacyOptionsForm():Void;
}
#end
