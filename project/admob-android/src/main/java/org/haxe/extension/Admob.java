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
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.gms.ads.OnUserEarnedRewardListener;

import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.ConsentForm;
import com.google.android.ump.FormError;
import com.google.android.ump.UserMessagingPlatform;

import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;

/*
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.

	You can access additional references from the Extension class,
	depending on your needs:

	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)

	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.

	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class Admob extends Extension
{
	public static boolean inited = false;
	public static AdView adView;
	public static RelativeLayout adContainer;
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
				ConsentRequestParameters params = new ConsentRequestParameters.Builder()
					.setTagForUnderAgeOfConsent(childDirected)
					.build();

				consentInformation = UserMessagingPlatform.getConsentInformation(mainContext);
				consentInformation.requestConsentInfoUpdate(mainActivity, params, new ConsentInformation.OnConsentInfoUpdateSuccessListener()
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
									consentForm.show(mainActivity, new ConsentForm.OnConsentFormDismissedListener()
									{
										@Override
										public void onConsentFormDismissed(FormError formError)
										{
											if (formError == null && callback != null)
												callback.call("onStatus", new Object[]{"CONSENT_SUCCESS", "Consent form dismissed successfully."});
											else if (callback != null)
												callback.call("onStatus", new Object[]{"CONSENT_FAIL", formError.getMessage()});

											initMobileAds(testingAds, childDirected, enableRDP);
										}
									});
								}
							}, new UserMessagingPlatform.OnConsentFormLoadFailureListener()
							{
								@Override
								public void onConsentFormLoadFailure(FormError loadError)
								{
									if (callback != null)
										callback.call("onStatus", new Object[]{"CONSENT_FAIL", loadError.getMessage()});

									initMobileAds(testingAds, childDirected, enableRDP);
								}
							});
						}
						else
						{
							if (callback != null)
								callback.call("onStatus", new Object[]{"CONSENT_NOT_REQUIRED", "Consent form not required or available."});

							initMobileAds(testingAds, childDirected, enableRDP);
						}
					}
				}, new ConsentInformation.OnConsentInfoUpdateFailureListener()
				{
					public void onConsentInfoUpdateFailure(FormError requestError)
					{
						if (callback != null)
							callback.call("onStatus", new Object[]{"CONSENT_FAIL", requestError.getMessage()});

						initMobileAds(testingAds, childDirected, enableRDP);
					}
				});
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
			List<String> testDeviceIds = new ArrayList<>();
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
				if (callback != null) 
					callback.call("onStatus", new Object[]{"INIT_OK", "Version " + MobileAds.getVersion()});
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
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
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

	public static void loadRewarded(final String id)
	{
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
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
}
