#include "admob.h"

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CommonCrypto/CommonDigest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>

static GADBannerView *bannerView = nil;
static GADInterstitialAd *interstitialAd = nil;
static GADRewardedAd *rewardedAd = nil;
static AdmobCallback admobCallback = nullptr;
static int currentAlign = 0;

static void alignBanner(GADBannerView *bannerView, int align)
{
	if (!bannerView)
		return;

	UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.keyWindow.safeAreaInsets;

	CGRect screenBounds = UIScreen.mainScreen.bounds;
	CGFloat bannerWidth = bannerView.bounds.size.width;
	CGFloat bannerHeight = bannerView.bounds.size.height;

	switch (align)
	{
	case 1:
		bannerView.center = screenBounds.size.width > screenBounds.size.height ? CGPointMake(screenBounds.size.width / 2, safeAreaInsets.left + bannerHeight / 2) : CGPointMake(screenBounds.size.width / 2, safeAreaInsets.top + bannerHeight / 2);
		break;
	default:
		bannerView.center = screenBounds.size.width > screenBounds.size.height ? CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - safeAreaInsets.right - bannerHeight / 2) : CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - safeAreaInsets.bottom - bannerHeight / 2);
		break;
	}
}

@interface BannerHelper : NSObject
+ (void)handleOrientationChange;
@end

@implementation BannerHelper
+ (void)handleOrientationChange
{
	if (bannerView)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
  			alignBanner(bannerView, currentAlign);
		});
	}
}
@end

@interface BannerViewDelegate : NSObject <GADBannerViewDelegate>
@end

@implementation BannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
	if (admobCallback)
		admobCallback("BANNER_LOADED", "Banner loaded successfully.");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
	if (admobCallback)
		admobCallback("BANNER_FAILED", [[error localizedDescription] UTF8String]);
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView
{
	if (admobCallback)
		admobCallback("BANNER_CLICKED", "Banner clicked.");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
	if (admobCallback)
		admobCallback("BANNER_OPENED", "Banner is opening.");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView
{
	if (admobCallback)
		admobCallback("BANNER_WILL_CLOSE", "Banner will close.");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
	if (admobCallback)
		admobCallback("BANNER_CLOSED", "Banner closed.");
}

@end

static BannerViewDelegate *bannerDelegate = nil;

static void initMobileAds(bool testingAds, bool childDirected, bool enableRDP)
{
	if (testingAds)
	{
		NSString *UDIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
		const char *cStr = [UDIDString UTF8String];
		unsigned char digest[16];
		CC_MD5(cStr, strlen(cStr), digest);

		NSMutableString *deviceId = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

		for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
			[deviceId appendFormat:@"%02x", digest[i]];

		GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ deviceId ];
	}

	if (childDirected)
		GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = @YES;

	if (enableRDP)
		[NSUserDefaults.standardUserDefaults setBool:YES forKey:@"gad_rdp"];

	if (hasAdmobConsentForPurpose(0) == 1)
	{
		if (@available(iOS 14, *))
		{
			[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
			      [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
				      if (admobCallback)
					      admobCallback("INIT_OK", "AdMob initialized.");
			      }];
			}];

			return;
		}
	}
	else
	{
		[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
			if (admobCallback)
				admobCallback("INIT_OK", "AdMob initialized.");
		}];
	}
}

void initAdmob(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback)
{
	admobCallback = callback;

	UMPRequestParameters *params = [[UMPRequestParameters alloc] init];
	params.tagForUnderAgeOfConsent = childDirected;

	[UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:params completionHandler:^(NSError *_Nullable error)
	{
		if (error)
		{
			if (admobCallback)
				admobCallback("CONSENT_FAIL", "Failed to load consent info.");
		}
		else
		{
			if (UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable)
			{
				[UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *_Nullable form, NSError *_Nullable loadError)
				{
					if (loadError)
					{
						if (admobCallback)
							admobCallback("CONSENT_FAIL", "Failed to load consent form.");
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[form presentFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable error)
							{
								if (error)
								{
									if (admobCallback)
										admobCallback("CONSENT_FAIL", "Consent form error.");
								}
								else
								{
									if (admobCallback)
										admobCallback("CONSENT_FORM_PRESENTED", "Consent form presented successfully.");
								}
							}];
						});
					}
				}];
			}
			else
			{
				if (admobCallback)
					admobCallback("INIT_OK", "Consent form not required.");
			}
		}
	}];

	initMobileAds(testingAds, childDirected, enableRDP);

	if (admobCallback)
		admobCallback("INIT_OK", "AdMob initialized.");
}

void showAdmobBanner(const char *id, int size, int align)
{
	if (bannerView != nil)
		return;

	currentAlign = align;

	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;

		GADAdSize adSize;

		switch (size)
		{
		case 1:
			adSize = GADAdSizeFluid;
			break;
		case 2:
			adSize = GADAdSizeFullBanner;
			break;
		case 3:
			adSize = GADAdSizeLargeBanner;
			break;
		case 4:
			adSize = GADAdSizeLeaderboard;
			break;
		case 5:
			adSize = GADAdSizeMediumRectangle;
			break;
		default:
			adSize = GADAdSizeBanner;
			break;
		}

		bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
		bannerView.adUnitID = [NSString stringWithUTF8String:id];
		bannerView.rootViewController = rootVC;

		if (bannerDelegate == nil)
			bannerDelegate = [[BannerViewDelegate alloc] init];

		bannerView.backgroundColor = UIColor.clearColor;
		bannerView.delegate = bannerDelegate;

		[rootVC.view addSubview:bannerView];

		alignBanner(bannerView, align);

		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[BannerHelper handleOrientationChange];
		}];

		[bannerView loadRequest:[GADRequest request]];
	});
}

void hideAdmobBanner()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (bannerView != nil)
		{
			[bannerView removeFromSuperview];

			bannerView = nil;

			if (admobCallback)
				admobCallback("BANNER_CLOSED", "Banner removed.");
		}
	});
}

void loadAdmobInterstitial(const char *id)
{
	[GADInterstitialAd loadWithAdUnitID:[NSString stringWithUTF8String:id] request:[GADRequest request] completionHandler:^(GADInterstitialAd *ad, NSError *error)
	{
		if (error)
		{
			interstitialAd = nil;

			if (admobCallback)
				admobCallback("INTERSTITIAL_FAILED_TO_LOAD", "Failed to load interstitial.");
		}
		else
		{
			interstitialAd = ad;

			if (admobCallback)
				admobCallback("INTERSTITIAL_LOADED", "Interstitial loaded.");
		}
	}];
}

void showAdmobInterstitial()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (interstitialAd != nil)
		{
			[interstitialAd presentFromRootViewController:UIApplication.sharedApplication.keyWindow.rootViewController];

			if (admobCallback)
				admobCallback("INTERSTITIAL_SHOWED", "Interstitial displayed.");
		}
		else
		{
			if (admobCallback)
				admobCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial not ready.");
		}
	});
}

void loadAdmobRewarded(const char *id)
{
	NSString *adUnitID = [NSString stringWithUTF8String:id];
	GADRequest *request = [GADRequest request];

	[GADRewardedAd loadWithAdUnitID:adUnitID request:request completionHandler:^(GADRewardedAd *ad, NSError *error)
	{
		if (error)
		{
			rewardedAd = nil;

			if (admobCallback)
				admobCallback("REWARDED_FAILED_TO_LOAD", [[error localizedDescription] UTF8String]);
		}
		else
		{
			rewardedAd = ad;

			if (admobCallback)
				admobCallback("REWARDED_LOADED", "Rewarded ad loaded.");
		}
	}];
}

void showAdmobRewarded()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (rewardedAd != nil)
		{
			[rewardedAd presentFromRootViewController:UIApplication.sharedApplication.keyWindow.rootViewController userDidEarnRewardHandler:^{
				if (admobCallback)
				{
					GADAdReward *reward = rewardedAd.adReward;
					NSString *rewardMessage = [NSString stringWithFormat:@"%@:%@", reward.type, reward.amount];
					admobCallback("REWARDED_EARNED", [rewardMessage UTF8String]);
				}
			}];

			if (admobCallback)
				admobCallback("REWARDED_SHOWED", "Rewarded ad displayed.");
		}
		else
		{
			if (admobCallback)
				admobCallback("REWARDED_FAILED_TO_SHOW", "Rewarded ad not ready.");
		}
	});
}

void setAdmobVolume(float vol)
{
	GADMobileAds.sharedInstance.applicationVolume = vol;
}

int hasAdmobConsentForPurpose(int purpose)
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents.length > purpose)
		return [[purposeConsents substringWithRange:NSMakeRange(purpose, 1)] integerValue];

	return -1;
}

const char *getAdmobConsent()
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents.length > 0)
		return [purposeConsents UTF8String];

	return "";
}

bool isAdmobPrivacyOptionsRequired()
{
	return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == UMPPrivacyOptionsRequirementStatusRequired;
}

void showAdmobPrivacyOptionsForm()
{
	[UMPConsentForm presentPrivacyOptionsFormFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable formError)
	{
		if (formError && admobCallback)
			admobCallback("CONSENT_FAIL", [[formError localizedDescription] UTF8String]);
	}];
}
