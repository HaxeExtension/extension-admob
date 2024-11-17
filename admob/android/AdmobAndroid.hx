package admob;

import admob.AdmobBannerAlign;
import admob.AdmobBannerSize;
import admob.AdmobConsent;
import android.jni.JNICache;
import lime.app.Event;
import lime.utils.Log;

class AdmobAndroid
{
	public static var onStatus:Event<(String->String)->Void>;

	@:noCompletion
	private static var initialized:Bool = false;

	public static function init(testingAds:Bool = false, childDirected:Bool = false, enableRDP:Bool = false):Void
	{
		if (initialized)
			return;

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'init',
			'(ZZZLorg/haxe/lime/HaxeObject;)V')(testingAds, childDirected, enableRDP, new CallBackHandler());

		initialized = true;
	}

	public static function showBanner(id:String, size:Int = AdmobBannerSize.ADAPTIVE, align:Int = AdmobBannerAlign.BOTTOM):Void
	{
		if (initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V')(id, size, align);
	}

	public static function hideBanner():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'hideBanner', '()V')();
	}

	public static function loadInterstitial(id:String):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadInterstitial', '(Ljava/lang/String;)V')(id);
	}

	public static function showInterstitial():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showInterstitial', '()V')();
	}

	public static function loadRewarded(id:String):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'loadRewarded', '(Ljava/lang/String;)V')(id);
	}

	public static function showRewarded():Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'showRewarded', '()V')();
	}

	public static function setVolume(vol:Float):Void
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return;
		}

		JNICache.createStaticMethod('org/haxe/extension/Admob', 'setVolume', '(F)V')(vol);
	}

	public static function hasConsentForPurpose(purpose:Int = 0):Int
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return -1;
		}

		return JNICache.createStaticMethod('org/haxe/extension/Admob', 'hasConsentForPurpose', '(I)I')(purpose);
	}

	public static function getConsent():String
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return '';
		}

		return JNICache.createStaticMethod('org/haxe/extension/Admob', 'getConsent', '()Ljava/lang/String;')();
	}

	public static function isPrivacyOptionsRequired():Bool
	{
		if (!initialized)
		{
			Log.warn('Admob extension isn\'t initialized');
			return false;
		}

		return JNICache.createStaticMethod('org/haxe/extension/Admob', 'isPrivacyOptionsRequired', '()Z')();
	}

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

@:noCompletion
private class CallBackHandler #if (lime >= "8.0.0") implements JNISafety #end
{
	public function new():Void {}

	#if (lime >= "8.0.0")
	@:runOnMainThread
	#end
	public function onStatus(status:String, data:String):Void
	{
		if (AdmobAndroid.onStatus != null)
			AdmobAndroid.onStatus.dispatch(status, data);
	}
}
