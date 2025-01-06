package;

class Main extends lime.app.Application
{
#if android
	//these are test ids from here: https://developers.google.com/admob/android/test-ads
	private static final APP_OPEN_ID:String = "ca-app-pub-3940256099942544/9257395921";
	private static final REWARDED_ID:String = "ca-app-pub-3940256099942544/5224354917";
	private static final INTERSTITIAL_ID:String = "ca-app-pub-3940256099942544/1033173712";
	private static final ADAPTIVE_BANNER_ID:String = "ca-app-pub-3940256099942544/9214589741";
	private static final BANNER_ID:String = "ca-app-pub-3940256099942544/6300978111";
#elseif ios
	//https://developers.google.com/ad-manager/mobile-ads-sdk/ios/test-ads
	private static final APP_OPEN_ID:String = "/21775744923/example/app-open";
	private static final REWARDED_ID:String = "/21775744923/example/rewarded";
	private static final INTERSTITIAL_ID:String = "/21775744923/example/interstitial";
	private static final ADAPTIVE_BANNER_ID:String = "/21775744923/example/adaptive-banner";
	private static final BANNER_ID:String = "/21775744923/example/fixed-size-banner";
#end

	public function onCallback(event:String, message:String)
	{
		switch(event)
		{
			case AdmobEvent.INIT_OK:
				extension.admob.Admob.setVolume(0.5);
				trace("isPrivacyOptionsRequired", extension.admob.Admob.isPrivacyOptionsRequired());
				trace("getConsent", extension.admob.Admob.getConsent());
				trace("hasConsentForPurpose", extension.admob.Admob.hasConsentForPurpose(0));
				extension.admob.Admob.loadAppOpen(APP_OPEN_ID);
				
			case AdmobEvent.APP_OPEN_LOADED:
				extension.admob.Admob.showAppOpen();
				
			case AdmobEvent.APP_OPEN_DISMISSED, AdmobEvent.APP_OPEN_FAILED_TO_LOAD, AdmobEvent.APP_OPEN_FAILED_TO_SHOW:
				extension.admob.Admob.loadRewarded(REWARDED_ID);

			case AdmobEvent.REWARDED_LOADED:
				extension.admob.Admob.showRewarded();

			case AdmobEvent.REWARDED_DISMISSED, AdmobEvent.REWARDED_FAILED_TO_LOAD, AdmobEvent.REWARDED_FAILED_TO_SHOW:
				extension.admob.Admob.loadInterstitial(INTERSTITIAL_ID);

			case AdmobEvent.INTERSTITIAL_LOADED:
				extension.admob.Admob.showInterstitial();

			case AdmobEvent.INTERSTITIAL_DISMISSED, AdmobEvent.INTERSTITIAL_FAILED_TO_LOAD, AdmobEvent.INTERSTITIAL_FAILED_TO_SHOW:
				extension.admob.Admob.showBanner(ADAPTIVE_BANNER_ID);
				//extension.admob.Admob.showBanner(BANNER_ID, AdmobBannerSize.BANNER, AdmobBannerAlign.TOP);

			case AdmobEvent.APP_OPEN_CLICKED, AdmobEvent.INTERSTITIAL_CLICKED, AdmobEvent.REWARDED_CLICKED, AdmobEvent.BANNER_CLICKED:
				trace("DINHEIRO!");

			case AdmobEvent.REWARDED_EARNED:
				trace("REWARD EARNED");
		}

		trace(event, message);
	}

	public override function onWindowCreate():Void
	{
		extension.admob.Admob.setCallback(onCallback);
		extension.admob.Admob.init(true); //It feels like in iOS, you still need to set test mode even with test ids for all the ads variants to work
	}

	public override function render(context:lime.graphics.RenderContext):Void
	{
		switch (context.type)
		{
			case CAIRO:
				context.cairo.setSourceRGB(0.75, 1, 0);
				context.cairo.paint();
			case CANVAS:
				context.canvas2D.fillStyle = '#BFFF00';
				context.canvas2D.fillRect(0, 0, window.width, window.height);
			case DOM:
				context.dom.style.backgroundColor = '#BFFF00';
			case FLASH:
				context.flash.graphics.beginFill(0xBFFF00);
				context.flash.graphics.drawRect(0, 0, window.width, window.height);
			case OPENGL | OPENGLES | WEBGL:
				context.webgl.clearColor(0.75, 1, 0, 1);
				context.webgl.clear(context.webgl.COLOR_BUFFER_BIT);
			default:
		}
	}
}
