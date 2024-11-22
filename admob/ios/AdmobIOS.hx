package admob.ios;

#if ios
import admob.AdmobBannerAlign;
import admob.AdmobBannerSize;
import haxe.MainLoop;
import lime.app.Event;
import lime.utils.Log;

/**
 * A class to manage AdMob advertisements on iOS devices.
 */
@:buildXml('<include name="${haxelib:extension-admob}/project/admob-ios/Build.xml" />')
@:headerInclude('admob.hpp')
class AdmobIOS
{
	/**
	 * Event triggered for status updates from AdMob.
	 */
	public static var onStatus:Event<String->String->Void> = new Event<String->String->Void>();

	@:noCompletion
	private static var initialized:Bool = false;

	/**
	 * Initializes the AdMob extension.
	 *
	 * @param testingAds Whether to use testing ads.
	 * @param childDirected Whether the ads should comply with child-directed policies.
	 * @param enableRDP Whether to enable restricted data processing (RDP).
	 */
	public static function init(testingAds:Bool = false, childDirected:Bool = false, enableRDP:Bool = false):Void
	{
		if (initialized)
			return;

		initAdmob(testingAds, childDirected, enableRDP, cpp.Callable.fromStaticFunction(onAdmobStatus));

		initialized = true;
	}

	private static function onAdmobStatus(event:cpp.ConstCharStar, value:cpp.ConstCharStar):Void
	{
		MainLoop.runInMainThread(function():Void
		{
			onStatus.dispatch((event : String), (value : String));
		});
	}

	/**
	 * Shows a banner ad.
	 *
	 * @param id The banner ad ID.
	 * @param size The banner size (default: banner).
	 * @param align The banner alignment (default: top).
	 */
	public static function showBanner(id:String, size:Int = AdmobBannerSize.BANNER, align:Int = AdmobBannerAlign.TOP):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		showAdmobBanner(id, size, align);
	}

	/**
	 * Hides the currently displayed banner ad.
	 */
	public static function hideBanner():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		hideAdmobBanner();
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 */
	public static function loadInterstitial(id:String):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		loadAdmobInterstitial(id);
	}

	/**
	 * Displays a loaded interstitial ad.
	 */
	public static function showInterstitial():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		showAdmobInterstitial();
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 */
	public static function loadRewarded(id:String):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		loadAdmobRewarded(id);
	}

	/**
	 * Displays a loaded rewarded ad.
	 */
	public static function showRewarded():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		showAdmobRewarded();
	}

	/**
	 * Sets the volume for interstitial and rewarded ads.
	 *
	 * @param vol The volume level (0.0 - 1.0, or -1 for muted).
	 */
	public static function setVolume(vol:Float):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		setAdmobVolume(vol);
	}

	/**
	 * Checks if consent for a specific purpose has been granted.
	 *
	 * @param purpose The purpose ID (default: 0).
	 * @return `1` for consent granted, `0` for not granted, `-1` for unknown.
	 */
	public static function hasConsentForPurpose(purpose:Int = 0):Int
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return -1;
		}

		return hasAdmobConsentForPurpose(purpose);
	}

	/**
	 * Retrieves the current user consent status.
	 *
	 * @return A string representing the consent status.
	 */
	public static function getConsent():String
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return '';
		}

		return getAdmobConsent();
	}

	/**
	 * Checks if privacy options are required.
	 *
	 * @return `true` if required, `false` otherwise.
	 */
	public static function isPrivacyOptionsRequired():Bool
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return false;
		}

		return isAdmobPrivacyOptionsRequired();
	}

	/**
	 * Displays the privacy options form.
	 */
	public static function showPrivacyOptionsForm():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		showAdmobPrivacyOptionsForm();
	}

	@:native('initAdmob')
	extern public static function initAdmob(testingAds:Bool, childDirected:Bool, enableRDP:Bool,
		callback:cpp.Callable<(event:cpp.ConstCharStar, value:cpp.ConstCharStar) -> Void>):Void;

	@:native('showAdmobBanner')
	extern public static function showAdmobBanner(id:cpp.ConstCharStar, size:Int, align:Int):Void;

	@:native('hideAdmobBanner')
	extern public static function hideAdmobBanner():Void;

	@:native('loadAdmobInterstitial')
	extern public static function loadAdmobInterstitial(id:cpp.ConstCharStar):Void;

	@:native('showAdmobInterstitial')
	extern public static function showAdmobInterstitial():Void;

	@:native('loadAdmobRewarded')
	extern public static function loadAdmobRewarded(id:cpp.ConstCharStar):Void;

	@:native('showAdmobRewarded')
	extern public static function showAdmobRewarded():Void;

	@:native('setAdmobVolume')
	extern public static function setAdmobVolume(vol:Single):Void;

	@:native('hasAdmobConsentForPurpose')
	extern public static function hasAdmobConsentForPurpose(purpose:Int):Int;

	@:native('getAdmobConsent')
	extern public static function getAdmobConsent():cpp.ConstCharStar;

	@:native('isAdmobPrivacyOptionsRequired')
	extern public static function isAdmobPrivacyOptionsRequired():Bool;

	@:native('showAdmobPrivacyOptionsForm')
	extern public static function showAdmobPrivacyOptionsForm():Void;
}
#end
