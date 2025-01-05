package extension.admob.android;

#if android
import lime.system.JNI;
import extension.admob.AdmobEvent;
import extension.admob.AdmobBannerAlign;
import extension.admob.AdmobBannerSize;

/**
 * A class to manage AdMob advertisements on Android devices.
 */
class AdmobAndroid
{
	@:noCompletion
	private static var _initialized:Bool = false;
	
	private static var _init:Null<Dynamic> = null;
	
	private static var _showBanner:Null<Dynamic> = null;
	private static var _hideBanner:Null<Dynamic> = null;
	
	private static var _loadInterstitial:Null<Dynamic> = null;
	private static var _showInterstitial:Null<Dynamic> = null;
	
	private static var _loadRewarded:Null<Dynamic> = null;
	private static var _showRewarded:Null<Dynamic> = null;
	
	private static var _loadAppOpen:Null<Dynamic> = null;
	private static var _showAppOpen:Null<Dynamic> = null;
	
	private static var _setVolume:Null<Dynamic> = null;
	
	private static var _hasConsentForPurpose:Null<Dynamic> = null;
	private static var _getConsent:Null<Dynamic> = null;
	private static var _isPrivacyOptionsRequired:Null<Dynamic> = null;
	private static var _showPrivacyOptionsForm:Null<Dynamic> = null;
	
	/**
	 * Event triggered for status updates from AdMob.
	 */
	private static var _onStatus:Null<String->String->Void> = null;

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
			_init = JNI.createStaticMethod("org/haxe/extension/Admob", "init", "(ZZZLorg/haxe/lime/HaxeObject;)V");
			
			_showBanner = JNI.createStaticMethod("org/haxe/extension/Admob", "showBanner", "(Ljava/lang/String;II)V");
			_hideBanner = JNI.createStaticMethod("org/haxe/extension/Admob", "hideBanner", "()V");
			
			_loadInterstitial = JNI.createStaticMethod("org/haxe/extension/Admob", "loadInterstitial", "(Ljava/lang/String;Z)V");
			_showInterstitial = JNI.createStaticMethod("org/haxe/extension/Admob", "showInterstitial", "()V");
			
			_loadRewarded = JNI.createStaticMethod("org/haxe/extension/Admob", "loadRewarded", "(Ljava/lang/String;Z)V");
			_showRewarded = JNI.createStaticMethod("org/haxe/extension/Admob", "showRewarded", "()V");
			
			_loadAppOpen = JNI.createStaticMethod("org/haxe/extension/Admob", "loadAppOpen", "(Ljava/lang/String;Z)V");
			_showAppOpen = JNI.createStaticMethod("org/haxe/extension/Admob", "showAppOpen", "()V");
			
			_setVolume = JNI.createStaticMethod("org/haxe/extension/Admob", "setVolume", "(F)V");
			
			_hasConsentForPurpose = JNI.createStaticMethod("org/haxe/extension/Admob", "hasConsentForPurpose", "(I)I");
			_getConsent = JNI.createStaticMethod("org/haxe/extension/Admob", "getConsent", "()Ljava/lang/String;");
			_isPrivacyOptionsRequired = JNI.createStaticMethod("org/haxe/extension/Admob", "isPrivacyOptionsRequired", "()Z");
			_showPrivacyOptionsForm = JNI.createStaticMethod("org/haxe/extension/Admob", "showPrivacyOptionsForm", "()V");

			if (_init != null)
				_init(testingAds, childDirected, enableRDP, new CallBackHandler());
			else
				dispatchEvent(AdmobEvent.FAIL, "JNI call failed"); //should never happen
			
			_initialized = true;
		}
		else
			dispatchEvent(AdmobEvent.FAIL, "Admob extension has been already initialized");
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
		if (_showBanner != null)
			_showBanner(id, size, align);
		else
			dispatchFrustration(AdmobEvent.BANNER_FAILED_TO_LOAD);
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		if (_hideBanner != null)
			_hideBanner();
		else
			dispatchFrustration(AdmobEvent.FAIL);
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadInterstitial(id:String, immersiveModeEnabled:Bool = true):Void
	{
		if (_loadInterstitial != null)
			_loadInterstitial(id, immersiveModeEnabled);
		else
			dispatchFrustration(AdmobEvent.INTERSTITIAL_FAILED_TO_LOAD);			
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		if (_showInterstitial != null)
			_showInterstitial();
		else
			dispatchFrustration(AdmobEvent.INTERSTITIAL_FAILED_TO_SHOW);
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadRewarded(id:String, immersiveModeEnabled:Bool = true):Void
	{
		if (_loadRewarded != null)
			_loadRewarded(id, immersiveModeEnabled);
		else
			dispatchFrustration(AdmobEvent.REWARDED_FAILED_TO_LOAD);
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		if (_showRewarded != null)
			_showRewarded();
		else
			dispatchFrustration(AdmobEvent.REWARDED_FAILED_TO_SHOW);
	}

	/**
	 * Loads a "app open" ad.
	 *
	 * @param id The "app open" ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadAppOpen(id:String, immersiveModeEnabled:Bool = true):Void
	{
		if (_loadAppOpen != null)
			_loadAppOpen(id, immersiveModeEnabled);
		else
			dispatchFrustration(AdmobEvent.APP_OPEN_FAILED_TO_LOAD);
	}

	/**
	 * Displays a loaded "app open" ad.
	 */
	public static function showAppOpen():Void
	{
		if (_showAppOpen != null)
			_showAppOpen();
		else
			dispatchFrustration(AdmobEvent.APP_OPEN_FAILED_TO_SHOW);
	}

	/**
	 * Sets the volume for interstitial and rewarded ads.
	 *
	 * @param vol The volume level (0.0 - 1.0, or -1 for muted).
	 */
	public static function setVolume(vol:Float):Void
	{
		if (_setVolume != null)
			_setVolume(vol);
		else
			dispatchFrustration(AdmobEvent.FAIL);
	}

	/**
	 * Checks if consent for a specific purpose has been granted.
	 *
	 * @param purpose The purpose ID (default: 0).
	 * @return `1` for consent granted, `0` for not granted, `-1` for unknown.
	 */
	public static function hasConsentForPurpose(purpose:Int = 0):Int
	{
		if (_hasConsentForPurpose != null)
			return _hasConsentForPurpose(purpose);
		else
			dispatchFrustration(AdmobEvent.FAIL);

		return -1;
	}

	/**
	 * Retrieves the current user consent status.
	 *
	 * @return A string representing the consent status.
	 */
	public static function getConsent():String
	{
		if (_getConsent != null)
			return _getConsent();
		else
			dispatchFrustration(AdmobEvent.FAIL);

		return "";
	}

	/**
	 * Checks if privacy options are required.
	 *
	 * @return `true` if required, `false` otherwise.
	 */
	public static function isPrivacyOptionsRequired():Bool
	{
		if (_isPrivacyOptionsRequired != null)
			return _isPrivacyOptionsRequired();
		else
			dispatchFrustration(AdmobEvent.FAIL);

		return false;
	}

	/**
	 * Displays the privacy options form.
	 */
	public static function showPrivacyOptionsForm():Void
	{
		if (_showPrivacyOptionsForm != null)
			showPrivacyOptionsForm();
		else
			dispatchFrustration(AdmobEvent.FAIL);
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
	private static function dispatchFrustration(status:String):Void
	{
		if (!_initialized)
			dispatchEvent(status, "Admob extension is not initialized");
		else
			dispatchEvent(status, "JNI call failed");
	}
}

/**
 * Internal callback handler for AdMob events.
 */
@:noCompletion
private class CallBackHandler #if (lime >= "8.0.0") implements lime.system.JNI.JNISafety #end
{
	public function new():Void {}

	@:keep
	#if (lime >= "8.0.0")
	@:runOnMainThread
	#end
	public function onStatus(status:String, data:String):Void
	{
		AdmobAndroid.dispatchEvent(status, data);
	}
}
#end
