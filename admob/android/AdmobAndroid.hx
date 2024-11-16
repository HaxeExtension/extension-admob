package admob;

import android.jni.JNICache;
import lime.app.Event;

class AdmobAndroid
{
	public static var onStatus:Event<(String->String)->Void>;

	@:noCompletion
	private static var initialized:Bool = false;

	public static function init(testingAds:Bool = false, childDirected:Bool = false, enableRDP:Bool = false):Void
        {
		if (initialized)
			return;

                JNICache.createStaticMethod('org/haxe/extension/Admob', 'init', '(ZZZLorg/haxe/lime/HaxeObject;)V')(testingAds, childDirected, enableRDP, new CallBackHandler());

		initialized = true;
	}

	public static function showBanner(id:String, size:Int = Admob.BANNER_SIZE_ADAPTIVE, align:Int = Admob.BANNER_ALIGN_BOTTOM):Void
        {
		if (initialized)
                {
                        // onStatus.
			return;
                }

                JNICache.createStaticMethod('org/haxe/extension/Admob', 'showBanner', '(Ljava/lang/String;II)V')(id, size, align);
	}

	public static function hideBanner():Void {
		if (_inited) {
			try {
				_hideBanner();
			} catch (e:Dynamic) {
				trace("hideBanner Exception: " + e);
				status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, e);
			}
		} else
			status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, "Extension is not initialized!");
	}

	public static function loadInterstitial(id:String):Void {
		if (_inited) {
			try {
				_loadInterstitial(id);
			} catch (e:Dynamic) {
				trace("loadInterstitial Exception: " + e);
				status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_LOAD, e);
			}
		} else
			status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_LOAD, "Extension is not initialized!");
	}

	public static function showInterstitial():Void {
		if (_inited) {
			try {
				_showInterstitial();
			} catch (e:Dynamic) {
				trace("showInterstitial Exception: " + e);
				status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_SHOW, e);
			}
		} else
			status.onStatus(AdmobEvent.INTERSTITIAL_FAILED_TO_SHOW, "Extension is not initialized!");
	}

	public static function loadRewarded(id:String):Void {
		if (_inited) {
			try {
				_loadRewarded(id);
			} catch (e:Dynamic) {
				trace("loadInterstitial Exception: " + e);
				status.onStatus(AdmobEvent.REWARDED_FAILED_TO_LOAD, e);
			}
		} else
			status.onStatus(AdmobEvent.REWARDED_FAILED_TO_LOAD, "Extension is not initialized!");
	}

	public static function showRewarded():Void {
		if (_inited) {
			try {
				_showRewarded();
			} catch (e:Dynamic) {
				trace("showRewarded Exception: " + e);
				status.onStatus(AdmobEvent.REWARDED_FAILED_TO_SHOW, e);
			}
		} else
			status.onStatus(AdmobEvent.REWARDED_FAILED_TO_SHOW, "Extension is not initialized!");
	}

	/**
		Sets volume for Interstitial and Rewarded ads, if sets to 0 might get less ads, cause some advertisers don't allow muted ads.
		@param	vol 0.0 - 1.0 (-1 for muted)
	**/
	public static function setVolume(vol:Float):Void {
		if (_inited) {
			try {
				_setVolume(vol);
			} catch (e:Dynamic) {
				trace("setVolume Exception: " + e);
				status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, e);
			}
		} else
			status.onStatus(AdmobEvent.WHAT_IS_GOING_ON, "Extension is not initialized!");
	}

	public static function hasConsentForPurpose(purpose:Int = 0):Int {
		var hasorwhat:Int = -1;
		if (_inited) {
			try {
				hasorwhat = _hasConsentForPurpose(purpose);
			} catch (e:Dynamic) {
				trace("hasConsentForPurpose Exception: " + e);
			}
		}

		return hasorwhat;
	}

	// check what kind of consent has been granted
	public static function getConsent():String {
		var consent:String = "";
		if (_inited) {
			try {
				consent = _getConsent();
			} catch (e:Dynamic) {
				trace("getConsent Exception: " + e);
			}
		}

		return consent;
	}

	public static function isPrivacyOptionsRequired():Int {
		var required:Int = -1;
		if (_inited) {
			try {
				required = _isPrivacyOptionsRequired();
			} catch (e:Dynamic) {
				trace("showPrivacyOptions Exception: " + e);
			}
		}

		return required;
	}

	public static function showPrivacyOptionsForm():Void {
		if (_inited) {
			try {
				_showPrivacyOptionsForm();
			} catch (e:Dynamic) {
				trace("showPrivacyOptions Exception: " + e);
			}
		}
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
