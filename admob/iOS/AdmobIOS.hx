package admob.android;

import admob.AdmobBannerAlign;
import admob.AdmobBannerSize;
import lime.app.Event;
import lime.utils.Log;

/**
 * A class to manage AdMob advertisements on iOS devices.
 */
class AdmobAndroid
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

		initialized = true;
	}

	/**
	 * Shows a banner ad.
	 *
	 * @param id The banner ad ID.
	 * @param size The banner size (default: adaptive).
	 * @param align The banner alignment (default: top).
	 */
	public static function showBanner(id:String, size:Int = AdmobBannerSize.ADAPTIVE, align:Int = AdmobBannerAlign.TOP):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}
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

		return -1;
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

		return '';
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

		return false;
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
	}
}
