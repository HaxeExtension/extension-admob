package admob.android;

import admob.AdmobBannerAlign;
import admob.AdmobBannerSize;
import android.jni.JNICache;
import lime.app.Event;
import lime.system.JNI; // For JNISafety
import lime.utils.Log;

/**
 * A class to manage AdMob advertisements on Android devices.
 */
class AdmobAndroid
{
	/**
	 * Event triggered for status updates from AdMob.
	 */
	public static var onStatus:Event<(String->String)->Void> = new Event<(String->String)->Void>();

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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'init',
			'(ZZZLorg/haxe/lime/HaxeObject;)V')(testingAds, childDirected, enableRDP, new CallBackHandler());

		initialized = true;
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
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V')(id, size, align);
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'hideBanner', '()V')();
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadInterstitial', '(Ljava/lang/String;)V')(id);
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showInterstitial', '()V')();
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadRewarded', '(Ljava/lang/String;)V')(id);
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showRewarded', '()V')();
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'setVolume', '(F)V')(vol);
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

		return JNICache.createStaticMethod('org/haxe/extension/Admob', 'hasConsentForPurpose', '(I)I')(purpose);
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

		return JNICache.createStaticMethod('org/haxe/extension/Admob', 'getConsent', '()Ljava/lang/String;')();
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

		return JNICache.createStaticMethod('org/haxe/extension/Admob', 'isPrivacyOptionsRequired', '()Z')();
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

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showPrivacyOptionsForm', '()V')();
	}
}

/**
 * Internal callback handler for AdMob events.
 */
@:noCompletion
private class CallBackHandler #if (lime >= "8.0.0") implements JNISafety #end
{
	public function new():Void
	{
		// The void
	}

	#if (lime >= "8.0.0")
	@:runOnMainThread
	#end
	public function onStatus(status:String, data:String):Void
	{
		if (AdmobAndroid.onStatus != null)
			AdmobAndroid.onStatus.dispatch(status, data);
	}
}
