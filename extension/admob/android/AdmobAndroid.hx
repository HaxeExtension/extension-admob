package extension.admob.android;

#if android
import extension.admob.android.util.JNICache;
import extension.admob.AdmobBannerAlign;
import extension.admob.AdmobBannerSize;
import lime.app.Event;
import lime.utils.Log;

/**
 * A class to manage AdMob advertisements on Android devices.
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

		final initJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'init', '(ZZZLorg/haxe/lime/HaxeObject;)V');

		if (initJNI != null)
		{
			initJNI(testingAds, childDirected, enableRDP, new CallBackHandler());

			initialized = true;
		}
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

		final showBannerJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V');

		if (showBannerJNI != null)
			showBannerJNI(id, size, align);
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

		final hideBannerJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'hideBanner', '()V');

		if (hideBannerJNI != null)
			hideBannerJNI();
	}

	/**
	 * Loads an interstitial ad.
	 *
	 * @param id The interstitial ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadInterstitial(id:String, ?immersiveModeEnabled:Bool = true):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		final loadInterstitialJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadInterstitial', '(Ljava/lang/String;Z)V');

		if (loadInterstitialJNI != null)
			loadInterstitialJNI(id, immersiveModeEnabled);
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

		final showInterstitialJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'showInterstitial', '()V');

		if (showInterstitialJNI != null)
			showInterstitialJNI();
	}

	/**
	 * Loads a rewarded ad.
	 *
	 * @param id The rewarded ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadRewarded(id:String, ?immersiveModeEnabled:Bool = true):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		final loadRewardedJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadRewarded', '(Ljava/lang/String;Z)V');

		if (loadRewardedJNI != null)
			loadRewardedJNI(id, immersiveModeEnabled);
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

		final showRewardedJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'showRewarded', '()V');

		if (showRewardedJNI != null)
			showRewardedJNI();
	}

	/**
	 * Loads a "app open" ad.
	 *
	 * @param id The "app open" ad ID.
	 * @param immersiveModeEnabled Optional flag to enable immersive mode when the ad is displayed. Defaults to true.
	 */
	public static function loadAppOpen(id:String, ?immersiveModeEnabled:Bool = true):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		final loadAppOpenJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadAppOpen', '(Ljava/lang/String;Z)V');

		if (loadAppOpenJNI != null)
			loadAppOpenJNI(id, immersiveModeEnabled);
	}

	/**
	 * Displays a loaded "app open" ad.
	 */
	public static function showAppOpen():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		final showAppOpenJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'showAppOpen', '()V');

		if (showAppOpenJNI != null)
			showAppOpenJNI();
	}

	/**
	 * Checks if ads can be requested.
	 *
	 * @return `true` if ads can be requested, `false` if not or if not initialized.
	 */
	public static function canRequestAds():Bool
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return false;
		}

		final canRequestAdsJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'canRequestAds', '()Z');

		return canRequestAdsJNI != null ? canRequestAdsJNI() : false;
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

		final setVolumeJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'setVolume', '(F)V');

		if (setVolumeJNI != null)
			setVolumeJNI(vol);
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

		final hasConsentJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'hasConsentForPurpose', '(I)I');

		return hasConsentJNI != null ? hasConsentJNI(purpose) : -1;
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

		final getConsentJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'getConsent', '()Ljava/lang/String;');

		return getConsentJNI != null ? getConsentJNI() : '';
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

		final isPrivacyOptionsRequiredJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'isPrivacyOptionsRequired', '()Z');

		return isPrivacyOptionsRequiredJNI != null ? isPrivacyOptionsRequiredJNI() : false;
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

		final showPrivacyOptionsFormJNI:Null<Dynamic> = JNICache.createStaticMethod('org/haxe/extension/Admob', 'showPrivacyOptionsForm', '()V');

		if (showPrivacyOptionsFormJNI != null)
			showPrivacyOptionsFormJNI();
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
		if (AdmobAndroid.onStatus != null)
			AdmobAndroid.onStatus.dispatch(status, data);
	}
}
#end
