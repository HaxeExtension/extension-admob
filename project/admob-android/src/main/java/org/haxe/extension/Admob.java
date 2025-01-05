package org.haxe.extension;

import android.content.Context;
import android.content.SharedPreferences;
import android.provider.Settings;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowMetrics;
import android.widget.RelativeLayout;
import com.google.android.gms.ads.appopen.*;
import com.google.android.gms.ads.initialization.*;
import com.google.android.gms.ads.interstitial.*;
import com.google.android.gms.ads.rewarded.*;
import com.google.android.gms.ads.*;
import com.google.android.ump.*;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

//https://developers.google.com/admob/android/quick-start?hl=en

public class Admob extends Extension
{
	private static AdView adView;
	private static RelativeLayout adContainer;
	private static InterstitialAd interstitial;
	private static RewardedAd rewarded;
	private static AppOpenAd appOpen;
	private static ConsentInformation consentInformation;
	private static HaxeObject callback;

	public static void init(final boolean testingAds, final boolean childDirected, final boolean enableRDP, HaxeObject callback)
	{
		Admob.callback = callback;
		
		//> use this to debug GDPR
		/*ConsentDebugSettings debugSettings = new ConsentDebugSettings.Builder(mainContext)
			.setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
			.addTestDeviceHashedId("[TEST_DEVICE_ID]")
			.build();

		ConsentRequestParameters params = new ConsentRequestParameters
			.Builder()
			.setConsentDebugSettings(debugSettings)
			.build();*/
		//<

		consentInformation = UserMessagingPlatform.getConsentInformation(mainContext);

		consentInformation.requestConsentInfoUpdate(mainActivity, new ConsentRequestParameters.Builder().setTagForUnderAgeOfConsent(childDirected).build() /*params*/, new ConsentInformation.OnConsentInfoUpdateSuccessListener()
		{
			public void onConsentInfoUpdateSuccess()
			{
				if (consentInformation.isConsentFormAvailable() && consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.REQUIRED)
				{
					UserMessagingPlatform.loadConsentForm(mainActivity, new UserMessagingPlatform.OnConsentFormLoadSuccessListener()
					{
						@Override
						public void onConsentFormLoadSuccess(ConsentForm consentForm)
						{
							mainActivity.runOnUiThread(new Runnable()
							{
								public void run()
								{
									consentForm.show(mainActivity, new ConsentForm.OnConsentFormDismissedListener()
									{
										@Override
										public void onConsentFormDismissed(FormError formError)
										{
											if (formError == null && callback != null)
												callback.call("onStatus", new Object[]{ "CONSENT_SUCCESS", "Consent form dismissed successfully." });
											else if (callback != null)
												callback.call("onStatus", new Object[]{ "CONSENT_FAIL", formError.getMessage() });

											initMobileAds(testingAds, childDirected, enableRDP);
										}
									});
								}
							});
						}
					}, new UserMessagingPlatform.OnConsentFormLoadFailureListener()
					{
						@Override
						public void onConsentFormLoadFailure(FormError loadError)
						{
							if (callback != null)
								callback.call("onStatus", new Object[]{ "CONSENT_FAIL", loadError.getMessage() });

							initMobileAds(testingAds, childDirected, enableRDP);
						}
					});
				}
				else
				{
					if (callback != null)
						callback.call("onStatus", new Object[]{ "CONSENT_NOT_REQUIRED", "Consent form not required or available." });

					initMobileAds(testingAds, childDirected, enableRDP);
				}
			}
		}, new ConsentInformation.OnConsentInfoUpdateFailureListener()
		{
			public void onConsentInfoUpdateFailure(FormError requestError)
			{
				if (callback != null)
					callback.call("onStatus", new Object[]{ "CONSENT_FAIL", requestError.getMessage() });

				initMobileAds(testingAds, childDirected, enableRDP);
			}
		});
	}

	public static void initMobileAds(final boolean testingAds, final boolean childDirected, final boolean enableRDP)
	{
		RequestConfiguration.Builder configuration = new RequestConfiguration.Builder();

		if (testingAds)
		{
			List<String> testDeviceIds = new ArrayList<>();

			if (Build.FINGERPRINT.startsWith("google/sdk_gphone") || Build.FINGERPRINT.contains("generic") || Build.FINGERPRINT.contains("emulator") || Build.MODEL.contains("Emulator") || Build.MODEL.contains("Android SDK built for x86") || Build.MANUFACTURER.contains("Google") || Build.PRODUCT.contains("sdk_gphone") || Build.BRAND.startsWith("generic") || Build.DEVICE.startsWith("generic"))
				testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);

			try
			{
				StringBuilder hexString = new StringBuilder();

				for (byte b : MessageDigest.getInstance("MD5").digest(Settings.Secure.getString(mainActivity.getContentResolver(), Settings.Secure.ANDROID_ID).getBytes()))
					hexString.append(String.format("%02x", b));

				testDeviceIds.add(hexString.toString().toUpperCase());
			}
			catch (NoSuchAlgorithmException e)
			{
				e.printStackTrace();
			}

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
				if (callback != null) 
					callback.call("onStatus", new Object[]{ "INIT_OK", MobileAds.getVersion().toString() });
			}
		});
	}

	public static void showBanner(final String id, final int size, final int align)
	{
		if (adView != null)
		{
			if (callback != null)
				callback.call("onStatus", new Object[] { "BANNER_FAILED_TO_LOAD", "Hide previous banner first!" });

			return;
		}

		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				adView = new AdView(mainActivity);
				adView.setAdUnitId(id);

				switch (size)
				{
					case 1:
						adView.setAdSize(AdSize.BANNER);
						break;
					case 2:
						adView.setAdSize(AdSize.FULL_BANNER);
						break;
					case 3:
						adView.setAdSize(AdSize.LARGE_BANNER);
						break;
					case 4:
						adView.setAdSize(AdSize.LEADERBOARD);
						break;
					case 5:
						adView.setAdSize(AdSize.MEDIUM_RECTANGLE);
						break;
					case 6:
						adView.setAdSize(AdSize.FLUID);
						break;
					default:
						adView.setAdSize(getAdSize());
						break;
				}

				adView.setAdListener(new AdListener()
				{
					@Override
					public void onAdLoaded()
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "BANNER_LOADED", "" });

						adView.setVisibility(View.VISIBLE); //to fix this problem, if it is still valid: https://groups.google.com/forum/#!topic/google-admob-ads-sdk/avwVXvBt_sM
					}

					@Override
					public void onAdFailedToLoad(LoadAdError adError)
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "BANNER_FAILED_TO_LOAD", adError.toString() });
					}

					@Override
					public void onAdOpened()
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "BANNER_OPENED", "" });
					}

					@Override
					public void onAdClicked()
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "BANNER_CLICKED", "" });
					}

					@Override
					public void onAdClosed()
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "BANNER_CLOSED", "" });
					}
				});

				adContainer.setGravity(align);
				adContainer.addView(adView);

				adView.loadAd(new AdRequest.Builder().build());
			}
		});
	}

	public static void hideBanner()
	{
		if (adView != null)
		{
			mainActivity.runOnUiThread(new Runnable()
			{
				public void run()
				{
					adContainer.removeView(adView);
					adView.destroy();
					adView = null;
				}
			});
		}
	}

	public static void loadInterstitial(final String id, final boolean immersiveModeEnabled)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				InterstitialAd.load(mainContext, id, new AdRequest.Builder().build(), new InterstitialAdLoadCallback()
				{
					@Override
					public void onAdLoaded(InterstitialAd interstitialAd)
					{
						interstitial = interstitialAd;
						interstitial.setImmersiveMode(immersiveModeEnabled);
						interstitial.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdClicked()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "INTERSTITIAL_CLICKED", "" });
							}
							
							@Override
							public void onAdDismissedFullScreenContent()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "INTERSTITIAL_DISMISSED", "" });
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "INTERSTITIAL_FAILED_TO_SHOW", adError.toString() });
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "INTERSTITIAL_SHOWED", "" });

								interstitial = null;
							}
						});

						if (callback != null)
							callback.call("onStatus", new Object[] { "INTERSTITIAL_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError loadAdError)
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "INTERSTITIAL_FAILED_TO_LOAD", loadAdError.getMessage() });

						interstitial = null;
					}
				});
			}
		});
	}

	public static void showInterstitial()
	{
		if (interstitial != null)
		{
			mainActivity.runOnUiThread(new Runnable()
			{
				public void run()
				{
					interstitial.show(mainActivity);
				}
			});
		}
		else
		{
			if (callback != null)
				callback.call("onStatus", new Object[] { "INTERSTITIAL_FAILED_TO_SHOW", "You need to load interstitial ad first!" });
		}
	}

	public static void loadRewarded(final String id, final boolean immersiveModeEnabled)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				RewardedAd.load(mainContext, id, new AdRequest.Builder().build(), new RewardedAdLoadCallback()
				{
					@Override
					public void onAdLoaded(RewardedAd rewardedAd)
					{
						rewarded = rewardedAd;
						rewarded.setImmersiveMode(immersiveModeEnabled);
						rewarded.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdClicked()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "REWARDED_CLICKED", "" });
							}
							
							@Override
							public void onAdDismissedFullScreenContent()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "REWARDED_DISMISSED", "" });
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "REWARDED_FAILED_TO_SHOW", adError.toString() });
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "REWARDED_SHOWED", "" });

								rewarded = null;
							}
						});

						callback.call("onStatus", new Object[] { "REWARDED_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError loadAdError)
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "REWARDED_FAILED_TO_LOAD", loadAdError.getMessage() });

						rewarded = null;
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
						public void onUserEarnedReward(RewardItem rewardItem)
						{
							if (callback != null)
								callback.call("onStatus", new Object[] { "REWARDED_EARNED", rewardItem.getType() + ":" + String.valueOf(rewardItem.getAmount())});
						}
					});
				}
			});
		}
		else if (callback != null)
			callback.call("onStatus", new Object[] { "REWARDED_FAILED_TO_SHOW", "You need to load rewarded ad first!" });
	}

	public static void loadAppOpen(final String id, final boolean immersiveModeEnabled)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			@Override
			public void run()
			{
				AppOpenAd.load(mainContext, id, new AdRequest.Builder().build(), new AppOpenAd.AppOpenAdLoadCallback()
				{
					@Override
					public void onAdLoaded(AppOpenAd ad)
					{
						appOpen = ad;
						appOpen.setImmersiveMode(immersiveModeEnabled);
						appOpen.setFullScreenContentCallback(new FullScreenContentCallback()
						{
							@Override
							public void onAdClicked()
							{
								if (callback != null)
									callback.call("onStatus", new Object[] { "APP_OPEN_CLICKED", "" });
							}
							
							@Override
							public void onAdDismissedFullScreenContent()
							{
								if (callback != null)
									callback.call("onStatus", new Object[]{ "APP_OPEN_DISMISSED", "" });
							}

							@Override
							public void onAdFailedToShowFullScreenContent(AdError adError)
							{
								if (callback != null)
									callback.call("onStatus", new Object[]{ "APP_OPEN_FAILED_TO_SHOW", adError.toString() });
							}

							@Override
							public void onAdShowedFullScreenContent()
							{
								if (callback != null)
									callback.call("onStatus", new Object[]{"APP_OPEN_SHOWED", ""});

								appOpen = null;
							}
						});

						if (callback != null)
							callback.call("onStatus", new Object[]{ "APP_OPEN_LOADED", "" });
					}

					@Override
					public void onAdFailedToLoad(LoadAdError loadAdError)
					{
						if (callback != null)
							callback.call("onStatus", new Object[]{ "APP_OPEN_FAILED_TO_LOAD", loadAdError.getMessage() });

						appOpen = null;
					}
				});
			}
		});
	}

	public static void showAppOpen()
	{
		if (appOpen != null)
			mainActivity.runOnUiThread(() -> appOpen.show(mainActivity));
		else if (callback != null)
			callback.call("onStatus", new Object[]{ "APP_OPEN_FAILED_TO_SHOW", "You need to load App Open Ad first!" });
	}

	public static void setVolume(final float vol)
	{
		if (vol > 0)
		{
			MobileAds.setAppMuted(false);
			MobileAds.setAppVolume(vol);
		}
		else
			MobileAds.setAppMuted(true);
	}

	//https://support.google.com/admob/answer/9760862
	//https://iabeurope.eu/iab-europe-transparency-consent-framework-policies/#A_Purposes
	public static int hasConsentForPurpose(final int purpose)
	{
		String purposeConsents = getConsent();

		if (purposeConsents.length() > purpose)
			return Character.getNumericValue(purposeConsents.charAt(purpose));

		return -1;
	}

	public static String getConsent()
	{
		return mainContext.getSharedPreferences(packageName + "_preferences", Context.MODE_PRIVATE).getString("IABTCF_PurposeConsents", "");
	}

	public static boolean isPrivacyOptionsRequired()
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
					if (formError != null && callback != null)
						callback.call("onStatus", new Object[] { "CONSENT_FAIL", String.format("%s: %s", formError.getErrorCode(), formError.getMessage())});
				});
			}
		});
	}
	
	//> copy/paste from https://developers.google.com/admob/android/banner/anchored-adaptive
	private static AdSize getAdSize()
	{
		DisplayMetrics displayMetrics = mainActivity.getResources().getDisplayMetrics();
		int adWidthPixels = displayMetrics.widthPixels;

		if (VERSION.SDK_INT >= VERSION_CODES.R)
		{
			WindowMetrics windowMetrics = mainActivity.getWindowManager().getCurrentWindowMetrics();
			adWidthPixels = windowMetrics.getBounds().width();
		}

		float density = displayMetrics.density;
		int adWidth = (int) (adWidthPixels / density);
		
		return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(mainActivity, adWidth);
	}
	//<

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		if (adContainer == null)
		{
			adContainer = new RelativeLayout(mainActivity);

			mainActivity.addContentView(adContainer, new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
		}
	}

	@Override
	public void onPause()
	{
		if (adView != null)
			adView.pause();

		super.onPause();
	}

	@Override
	public void onResume()
	{
		super.onResume();

		if (adView != null)
			adView.resume();
	}
}
