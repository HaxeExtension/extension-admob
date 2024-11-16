package org.haxe.extension;

import android.provider.Settings.Secure;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import androidx.annotation.NonNull;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentForm;
import com.google.android.ump.FormError;
import com.google.android.ump.UserMessagingPlatform;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Admob extends Extension
{
	public static final String INIT_OK = "INIT_OK";
	public static final String CONSENT_FAIL = "CONSENT_FAIL";
	public static final String BANNER_LOADED = "BANNER_LOADED";
	public static final String BANNER_FAILED_TO_LOAD = "BANNER_FAILED_TO_LOAD";
	public static final String BANNER_OPENED = "BANNER_OPENED";
	public static final String BANNER_CLICKED = "BANNER_CLICKED";
	public static final String BANNER_CLOSED = "BANNER_CLOSED";
	public static final String INTERSTITIAL_LOADED = "INTERSTITIAL_LOADED";
	public static final String INTERSTITIAL_FAILED_TO_LOAD = "INTERSTITIAL_FAILED_TO_LOAD";
	public static final String INTERSTITIAL_DISMISSED = "INTERSTITIAL_DISMISSED";
	public static final String INTERSTITIAL_FAILED_TO_SHOW = "INTERSTITIAL_FAILED_TO_SHOW";
	public static final String INTERSTITIAL_SHOWED = "INTERSTITIAL_SHOWED";
	public static final String REWARDED_LOADED = "REWARDED_LOADED";
	public static final String REWARDED_FAILED_TO_LOAD = "REWARDED_FAILED_TO_LOAD";
	public static final String REWARDED_DISMISSED = "REWARDED_DISMISSED";
	public static final String REWARDED_FAILED_TO_SHOW = "REWARDED_FAILED_TO_SHOW";
	public static final String REWARDED_SHOWED = "REWARDED_SHOWED";
	public static final String REWARDED_EARNED = "REWARDED_EARNED";
	public static final String WHAT_IS_GOING_ON = "WHAT_IS_GOING_ON";

	public static final int BANNER_SIZE_ADAPTIVE = 0; // Anchored adaptive, somewhat default now (a replacement for SMART_BANNER); banner width is fullscreen, height calculated acordingly (might not work well with landscape orientation)
	public static final int BANNER_SIZE_BANNER = 1; // 320x50
	public static final int BANNER_SIZE_FLUID = 2; // A dynamically sized banner that matches its parent's width and expands/contracts its height to match the ad's content after loading completes.
	public static final int BANNER_SIZE_FULL_BANNER = 3; // 468x60
	public static final int BANNER_SIZE_LARGE_BANNER = 4; // 320x100
	public static final int BANNER_SIZE_LEADERBOARD = 5; // 728x90
	public static final int BANNER_SIZE_MEDIUM_RECTANGLE = 6; // 300x250
	public static final int BANNER_SIZE_WIDE_SKYSCRAPER = 7; // 160x600

	public static bool inited = false;
	public static AdView banner;
	public static RelativeLayout rl;
	public static AdSize bannerSize;
	public static InterstitialAd interstitial;
	public static RewardedAd rewarded;
	public static ConsentInformation consentInformation;
	public static HaxeObject callback;

	public static void init(final boolean testingAds, final boolean childDirected, final boolean enableRDP, HaxeObject callback)
	{
		Admob.callback = callback;

		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				ConsentRequestParameters params = new ConsentRequestParameters.Builder().setTagForUnderAgeOfConsent(childDirected).build();

				consentInformation = UserMessagingPlatform.getConsentInformation(mainContext);
				consentInformation.requestConsentInfoUpdate(mainActivity, params, (ConsentInformation.OnConsentInfoUpdateSuccessListener)() -> {
					UserMessagingPlatform.loadAndShowConsentFormIfRequired(mainActivity, (ConsentForm.OnConsentFormDismissedListener) loadAndShowError -> {
						if (loadAndShowError != null)
							callback.call("onStatus", new Object[] {CONSENT_FAIL, String.format("%s: %s", loadAndShowError.getErrorCode(), loadAndShowError.getMessage())});

						initMobileAds(testingAds, childDirected, enableRDP);
					});
				}, (ConsentInformation.OnConsentInfoUpdateFailureListener) requestConsentError ->
				{
					callback.call("onStatus", new Object[] {CONSENT_FAIL, String.format("%s: %s", requestConsentError.getErrorCode(), requestConsentError.getMessage())});

					initMobileAds(testingAds, childDirected, enableRDP);
				});

				if (consentInformation.canRequestAds())
					initMobileAds(testingAds, childDirected, enableRDP);
			}
		});
	}

	public static void initMobileAds(final boolean testingAds, final boolean childDirected, final boolean enableRDP)
	{
		if (inited)
			return;

		inited = true;

		RequestConfiguration.Builder configuration = new RequestConfiguration.Builder();

		if (testingAds)
		{
			List<String> testDeviceIds = new ArrayList<String>();
			testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);
			testDeviceIds.add(md5(Secure.getString(mainActivity.getContentResolver(), Secure.ANDROID_ID)).toUpperCase());
			configuration.setTestDeviceIds(testDeviceIds);
		}

		if (childDirected)
			configuration.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE);

		if (enableRDP)
		{
			SharedPreferences.Editor editor = mainActivity.getPreferences(Context.MODE_PRIVATE).edit();
			editor.putInt("gad_rdp", 1);
			editor.commit();
		}

		MobileAds.setRequestConfiguration(configuration.build());

		MobileAds.initialize(mainContext, new OnInitializationCompleteListener()
		{
			@Override
			public void onInitializationComplete(InitializationStatus initializationStatus)
			{
				Log.d("AdmobEx", MobileAds.getVersion().toString());

				callback.call("onStatus", new Object[] {INIT_OK, ""});
			}
		});
	}

	public static void showBanner(final String id, final int size, final int align) {
		if (banner != null) {
			//Log.d("AdmobEx", BANNER_FAILED_TO_LOAD+"Hide previous banner first!");
			callback.call("onStatus", new Object[] {
				BANNER_FAILED_TO_LOAD,
				"Hide previous banner first!"
			});
			return;
		}

		mainActivity.runOnUiThread(new Runnable() {
			public void run() {
				rl = new RelativeLayout(mainActivity);
				rl.setGravity(align);

				banner = new AdView(mainActivity);
				banner.setAdUnitId(id);

				AdSize adSize = AdSize.INVALID;
				switch (size) {
					case BANNER_SIZE_ADAPTIVE:
						adSize = getAdSize();
						break; // Get right size for adaptive banner
					case BANNER_SIZE_BANNER:
						adSize = AdSize.BANNER;
						break;
					case BANNER_SIZE_FLUID:
						adSize = AdSize.FLUID;
						break;
					case BANNER_SIZE_FULL_BANNER:
						adSize = AdSize.FULL_BANNER;
						break;
					case BANNER_SIZE_LARGE_BANNER:
						adSize = AdSize.LARGE_BANNER;
						break;
					case BANNER_SIZE_LEADERBOARD:
						adSize = AdSize.LEADERBOARD;
						break;
					case BANNER_SIZE_MEDIUM_RECTANGLE:
						adSize = AdSize.MEDIUM_RECTANGLE;
						break;
					case BANNER_SIZE_WIDE_SKYSCRAPER:
						adSize = AdSize.WIDE_SKYSCRAPER;
						break;
				}

				banner.setAdSize(adSize);
				banner.setAdListener(new AdListener() {
					@Override
					public void onAdLoaded() {
						// Code to be executed when an ad finishes loading.
						//Log.d("AdmobEx", BANNER_LOADED);
						callback.call("onStatus", new Object[] {
							BANNER_LOADED,
							""
						});
						banner.setVisibility(View.VISIBLE); //To fix this problem, if it is still valid: https://groups.google.com/forum/#!topic/google-admob-ads-sdk/avwVXvBt_sM
					}

					@Override
					public void onAdFailedToLoad(LoadAdError adError) {
						// Code to be executed when an ad request fails.
						//Log.d("AdmobEx", BANNER_FAILED_TO_LOAD+adError.toString());
						callback.call("onStatus", new Object[] {
							BANNER_FAILED_TO_LOAD,
							adError.toString()
						});
					}

					@Override
					public void onAdOpened() {
						// Code to be executed when an ad opens an overlay that
						// covers the screen.
						//Log.d("AdmobEx", BANNER_OPENED);
						callback.call("onStatus", new Object[] {
							BANNER_OPENED,
							""
						}); //ie shown
					}

					@Override
					public void onAdClicked() {
						// Code to be executed when the user clicks on an ad.
						//Log.d("AdmobEx", BANNER_CLICKED);
						callback.call("onStatus", new Object[] {
							BANNER_CLICKED,
							""
						});
					}

					@Override
					public void onAdClosed() {
						// Code to be executed when the user is about to return
						// to the app after tapping on an ad.
						//Log.d("AdmobEx", BANNER_CLOSED);
						callback.call("onStatus", new Object[] {
							BANNER_CLOSED,
							""
						});
					}
				});

				RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
				mainActivity.addContentView(rl, params);
				rl.addView(banner);
				rl.bringToFront();

				AdRequest adRequest = new AdRequest.Builder().build();
				banner.loadAd(adRequest);
			}
		});
	}

	public static void hideBanner() {
		if (banner != null) {
			mainActivity.runOnUiThread(new Runnable() {
				public void run() {
					banner.setVisibility(View.INVISIBLE);
					ViewGroup parent = (ViewGroup) rl.getParent();
					parent.removeView(rl);
					rl.removeView(banner);
					banner.destroy();
					banner = null;
					rl = null;
				}
			});
		}
	}

	public static void loadInterstitial(final String id) {
		mainActivity.runOnUiThread(new Runnable() {
			public void run() {
				AdRequest adRequest = new AdRequest.Builder().build();

				InterstitialAd.load(mainActivity, id, adRequest, new InterstitialAdLoadCallback() {
					@Override
					public void onAdLoaded(@NonNull InterstitialAd interstitialAd) {
						// The interstitial reference will be null until
						// an ad is loaded.
						interstitial = interstitialAd;
						interstitial.setFullScreenContentCallback(new FullScreenContentCallback() {
							@Override
							public void onAdDismissedFullScreenContent() {
								// Called when fullscreen content is dismissed.
								//Log.d("AdmobEx", INTERSTITIAL_DISMISSED);
								callback.call("onStatus", new Object[] {
									INTERSTITIAL_DISMISSED,
									""
								});
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError) {
								// Called when fullscreen content failed to show.
								//Log.d("AdmobEx", INTERSTITIAL_FAILED_TO_SHOW+adError.toString());
								callback.call("onStatus", new Object[] {
									INTERSTITIAL_FAILED_TO_SHOW,
									adError.toString()
								});
							}

							@Override
							public void onAdShowedFullScreenContent() {
								// Called when fullscreen content is shown.
								// Make sure to set your reference to null so you don't
								// show it a second time.
								//Log.d("AdmobEx", INTERSTITIAL_SHOWED);
								interstitial = null;
								callback.call("onStatus", new Object[] {
									INTERSTITIAL_SHOWED,
									""
								});
							}
						});

						//Log.d("AdmobEx", INTERSTITIAL_LOADED);
						callback.call("onStatus", new Object[] {
							INTERSTITIAL_LOADED,
							""
						});
					}

					@Override
					public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
						// Handle the error
						//Log.d("AdmobEx", INTERSTITIAL_FAILED_TO_LOAD+loadAdError.getMessage());
						interstitial = null;
						callback.call("onStatus", new Object[] {
							INTERSTITIAL_FAILED_TO_LOAD,
							loadAdError.getMessage()
						});
					}
				});
			}
		});
	}

	public static void showInterstitial() {
		if (interstitial != null) {
			mainActivity.runOnUiThread(new Runnable() {
				public void run() {
					interstitial.show(mainActivity);
				}
			});
		} else {
			//Log.d("AdmobEx", INTERSTITIAL_FAILED_TO_SHOW+"You need to load interstitial ad first!");
			callback.call("onStatus", new Object[] {
				INTERSTITIAL_FAILED_TO_SHOW,
				"You need to load interstitial ad first!"
			});
		}
	}

	public static void loadRewarded(final String id)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				RewardedAd.load(mainActivity, id, new AdRequest.Builder().build(), new RewardedAdLoadCallback()
				{
					@Override
					public void onAdLoaded(@NonNull RewardedAd rewardedAd)
					{
						rewarded = rewardedAd;

						rewarded.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdDismissedFullScreenContent()
							{
								callback.call("onStatus", new Object[] {REWARDED_DISMISSED, ""});
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								callback.call("onStatus", new Object[] {REWARDED_FAILED_TO_SHOW, adError.toString()});
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								rewarded = null;
								callback.call("onStatus", new Object[] {REWARDED_SHOWED, ""});
							}
						});

						callback.call("onStatus", new Object[] {REWARDED_LOADED, ""});
					}

					@Override
					public void onAdFailedToLoad(@NonNull LoadAdError loadAdError)
					{
						rewarded = null;
						callback.call("onStatus", new Object[] {REWARDED_FAILED_TO_LOAD, loadAdError.getMessage()});
					}
				});
			}
		});
	}

	public static void showRewarded()
	{
		if (rewarded != null)
		{
			mainActivity.runOnUiThread(new Runnable()
			{
				public void run()
				{
					rewarded.show(mainActivity, new OnUserEarnedRewardListener()
					{
						@Override
						public void onUserEarnedReward(@NonNull RewardItem rewardItem)
						{
							callback.call("onStatus", new Object[] {REWARDED_EARNED, rewardItem.getType() + ":" + String.valueOf(rewardItem.getAmount())});
						}
					});
				}
			});
		}
		else
		{
			callback.call("onStatus", new Object[] {REWARDED_FAILED_TO_SHOW, "You need to load rewarded ad first!"});
		}
	}

	public static void setVolume(final float vol)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				if (vol > 0)
				{
					MobileAds.setAppMuted(false);
					MobileAds.setAppVolume(vol);
				}
				else
					MobileAds.setAppMuted(true);
			}
		});
	}

	public static int hasConsentForPurpose(final int purpose)
	{
		String purposeConsents = getConsent();

		if (purposeConsents.length() > purpose)
			return Character.getNumericValue(purposeConsents.charAt(purpose));

		return -1;
	}

	public static String getConsent()
	{
		return PreferenceManager.getDefaultSharedPreferences(mainContext).getString("IABTCF_PurposeConsents", "");
	}

	public static bool isPrivacyOptionsRequired()
	{
		return consentInformation != null && consentInformation.getPrivacyOptionsRequirementStatus() == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED;
	}

	public static void showPrivacyOptionsForm()
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				UserMessagingPlatform.showPrivacyOptionsForm(mainActivity, formError -> {
					if (formError != null)
						callback.call("onStatus", new Object[] {CONSENT_FAIL, String.format("%s: %s", formError.getErrorCode(), formError.getMessage())});
				});
			}
		});
	}

	private static AdSize getAdSize()
	{
		DisplayMetrics outMetrics = new DisplayMetrics();
		mainActivity.getWindowManager().getDefaultDisplay().getMetrics(outMetrics);
		return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(mainContext, (int)(outMetrics.widthPixels / outMetrics.density));
	}

	private static String md5(String s)
	{
		MessageDigest digest;

		try
		{
			digest = MessageDigest.getInstance("MD5");
			digest.update(s.getBytes(), 0, s.length());
			String hexDigest = new java.math.BigInteger(1, digest.digest()).toString(16);

			if (hexDigest.length() >= 32)
				return hexDigest;
			else
				return "00000000000000000000000000000000".substring(hexDigest.length()) + hexDigest;
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}

		return "";
	}
}
