package org.haxe.extension;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.provider.Settings.Secure;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import com.google.android.gms.ads.appopen.*;
import com.google.android.gms.ads.initialization.*;;
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

		consentInformation = UserMessagingPlatform.getConsentInformation(mainContext);

		consentInformation.requestConsentInfoUpdate(mainActivity, new ConsentRequestParameters.Builder().setTagForUnderAgeOfConsent(childDirected).build(), new ConsentInformation.OnConsentInfoUpdateSuccessListener()
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
									}
								});
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

				for (byte b : MessageDigest.getInstance("MD5").digest(Secure.getString(mainActivity.getContentResolver(), Secure.ANDROID_ID).getBytes()))
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
				adContainer.setGravity(align);

				AdSize adSize;

				switch (size)
				{
					case 1:
						adSize = AdSize.FLUID;
						break;
					case 2:
						adSize = AdSize.FULL_BANNER;
						break;
					case 3:
						adSize = AdSize.LARGE_BANNER;
						break;
					case 4:
						adSize = AdSize.LEADERBOARD;
						break;
					case 5:
						adSize = AdSize.MEDIUM_RECTANGLE;
						break;
					case 6:
						adSize = AdSize.WIDE_SKYSCRAPER;
						break;
					default:
						adSize = AdSize.BANNER;
						break;
				}

				adView = new AdView(mainActivity);
				adView.setAdUnitId(id);
				adView.setAdSize(adSize);
				adView.setAdListener(new AdListener()
				{
					@Override
					public void onAdLoaded()
					{
						if (callback != null)
							callback.call("onStatus", new Object[] { "BANNER_LOADED", "" });

						adView.setVisibility(View.VISIBLE);
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

	public static void loadInterstitial(final String id)
	{
		InterstitialAd.load(mainActivity, id, new AdRequest.Builder().build(), new InterstitialAdLoadCallback()
		{
			@Override
			public void onAdLoaded(InterstitialAd interstitialAd)
			{
				interstitial = interstitialAd;

				interstitial.setFullScreenContentCallback(new FullScreenContentCallback()
				{
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

	public static void showInterstitial()
	{
		if (interstitial != null)
			mainActivity.runOnUiThread(() -> interstitial.show(mainActivity));
		else if (callback != null)
			callback.call("onStatus", new Object[] { "INTERSTITIAL_FAILED_TO_SHOW", "You need to load interstitial ad first!" });
	}

	public static void loadRewarded(final String id)
	{
		RewardedAd.load(mainActivity, id, new AdRequest.Builder().build(), new RewardedAdLoadCallback()
		{
			@Override
			public void onAdLoaded(RewardedAd rewardedAd)
			{
				rewarded = rewardedAd;

				rewarded.setFullScreenContentCallback(new FullScreenContentCallback()
				{
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

	public static void loadAppOpen(final String id)
	{
		AppOpenAd.load(mainContext, id, new AdRequest.Builder().build(), new AppOpenAd.AppOpenAdLoadCallback()
		{
			@Override
			public void onAdLoaded(AppOpenAd ad)
			{
				appOpen = ad;
				appOpen.setFullScreenContentCallback(new FullScreenContentCallback()
				{
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

	public static void showAppOpen()
	{
		if (appOpen != null)
			mainActivity.runOnUiThread(mainActivity.runOnUiThread(() -> appOpen.show(mainActivity));
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
