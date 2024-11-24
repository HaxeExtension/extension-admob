#include "admob.hpp"

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CommonCrypto/CommonDigest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>

static AdmobCallback admobCallback = nullptr;
static GADBannerView *bannerView = nil;
static GADInterstitialAd *interstitialAd = nil;
static GADRewardedAd *rewardedAd = nil;
static int currentAlign = 0;

static void alignBanner(GADBannerView *bannerView, int align)
{
	if (!bannerView)
		return;

	UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;

	if (@available(iOS 11.0, *))
		safeAreaInsets = UIApplication.sharedApplication.keyWindow.safeAreaInsets;

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
		admobCallback("BANNER_FAILED_TO_LOAD", [[NSString stringWithFormat:@"Error Code: %ld, Description: %@", (long)error.code, error.localizedDescription] UTF8String]);
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

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
	if (admobCallback)
		admobCallback("BANNER_CLOSED", "Banner closed.");
}

@end

@interface InterstitialDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *_ad;

- (void)loadWithAdUnitID:(const char *)adUnitID;
- (void)show;

@end

@implementation InterstitialDelegate

- (void)loadWithAdUnitID:(const char *)adUnitID
{
	self._ad = nil;

	[GADInterstitialAd loadWithAdUnitID:[NSString stringWithUTF8String:adUnitID] request:[GADRequest request] completionHandler:^(GADInterstitialAd *ad, NSError *error)
	{
		if (error)
		{
			if (admobCallback)
				admobCallback("INTERSTITIAL_FAILED_TO_LOAD", [[error localizedDescription] UTF8String]);
		}
		else
		{
			self._ad = ad;
			self._ad.fullScreenContentDelegate = self;

			if (admobCallback)
				admobCallback("INTERSTITIAL_LOADED", "Interstitial loaded successfully.");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController]];

		if (admobCallback)
			admobCallback("INTERSTITIAL_SHOWED", "Interstitial displayed.");
	}
	else
	{
		if (admobCallback)
			admobCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial ad not ready.");
	}
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	if (admobCallback)
		admobCallback("INTERSTITIAL_DISMISSED", "Interstitial ad dismissed.");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
		admobCallback("INTERSTITIAL_FAILED_TO_SHOW", [[error localizedDescription] UTF8String]);
}

@end

@interface RewardedDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADRewardedAd *_ad;

- (void)loadWithAdUnitID:(const char *)adUnitID;
- (void)show;

@end

@implementation RewardedDelegate

- (void)loadWithAdUnitID:(const char *)adUnitID
{
	self._ad = nil;

	[GADRewardedAd loadWithAdUnitID:[NSString stringWithUTF8String:adUnitID] request:[GADRequest request] completionHandler:^(GADRewardedAd *ad, NSError *error)
	{
		if (error)
		{
			if (admobCallback)
				admobCallback("REWARDED_FAILED_TO_LOAD", [[error localizedDescription] UTF8String]);
		}
		else
		{
			self._ad = ad;
			self._ad.fullScreenContentDelegate = self;

			if (admobCallback)
				admobCallback("REWARDED_LOADED", "Rewarded ad loaded successfully.");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] userDidEarnRewardHandler:^{
			if (admobCallback)
				admobCallback("REWARDED_EARNED", [[NSString stringWithFormat:@"%@:%@", self._ad.adReward.type, self._ad.adReward.amount] UTF8String]);
		}];

		if (admobCallback)
			admobCallback("REWARDED_SHOWED", "Rewarded ad displayed.");
	}
	else
	{
		if (admobCallback)
			admobCallback("REWARDED_FAILED_TO_SHOW", "Rewarded ad not ready.");
	}
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	if (admobCallback)
		admobCallback("REWARDED_DISMISSED", "Rewarded ad dismissed.");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	if (admobCallback)
		admobCallback("REWARDED_FAILED_TO_SHOW", [[error localizedDescription] UTF8String]);
}

@end

static BannerViewDelegate *bannerDelegate = nil;
static InterstitialDelegate *interstitialDelegate = nil;
static RewardedDelegate *rewardedDelegate = nil;

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

	if (@available(iOS 14, *))
	{
		if (hasAdmobConsentForPurpose(0) == 1)
		{
			[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status)
			{
				if (admobCallback)
				{
					NSString *statusString;
				
					switch (status)
					{
						case ATTrackingManagerAuthorizationStatusNotDetermined:
							statusString = @"NOT_DETERMINED";
							break;
						case ATTrackingManagerAuthorizationStatusRestricted:
							statusString = @"RESTRICTED";
							break;
						case ATTrackingManagerAuthorizationStatusDenied:
							statusString = @"DENIED";
							break;
						case ATTrackingManagerAuthorizationStatusAuthorized:
							statusString = @"AUTHORIZED";
							break;
						default:
							statusString = @"UNKNOWN";
							break;
					}

					admobCallback("ATT_STATUS", [statusString UTF8String]);
				}

				[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
				{
					if (admobCallback)
						admobCallback("INIT_OK", [[NSString stringWithFormat:@"%ld.%ld.%ld", (long)GADMobileAds.sharedInstance.versionNumber.majorVersion, (long)GADMobileAds.sharedInstance.versionNumber.minorVersion, (long)GADMobileAds.sharedInstance.versionNumber.patchVersion] UTF8String]);
				}];
			}];
		}
		else
		{
			[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
			{
				if (admobCallback)
					admobCallback("INIT_OK", [[NSString stringWithFormat:@"%ld.%ld.%ld", (long)GADMobileAds.sharedInstance.versionNumber.majorVersion, (long)GADMobileAds.sharedInstance.versionNumber.minorVersion, (long)GADMobileAds.sharedInstance.versionNumber.patchVersion] UTF8String]);
			}];
		}
	}
	else
	{
		[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
		{
			if (admobCallback)
				admobCallback("INIT_OK", [[NSString stringWithFormat:@"%ld.%ld.%ld", (long)GADMobileAds.sharedInstance.versionNumber.majorVersion, (long)GADMobileAds.sharedInstance.versionNumber.minorVersion, (long)GADMobileAds.sharedInstance.versionNumber.patchVersion] UTF8String]);
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
				admobCallback("CONSENT_FAIL", [[NSString stringWithFormat:@"Consent Info Error: %@ (Code: %ld)", error.localizedDescription, (long)error.code] UTF8String]);

			initMobileAds(testingAds, childDirected, enableRDP);
		}
		else
		{
			if (UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable && UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatusRequired)
			{
				[UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *_Nullable form, NSError *_Nullable loadError)
				{
					if (loadError)
					{
						if (admobCallback)
							admobCallback("CONSENT_FAIL", [[NSString stringWithFormat:@"Consent Form Load Error: %@ (Code: %ld)", loadError.localizedDescription, (long)loadError.code] UTF8String]);

						initMobileAds(testingAds, childDirected, enableRDP);
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[form presentFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable error)
							{
								if (admobCallback && loadError)
									admobCallback("CONSENT_FAIL", [[NSString stringWithFormat:@"Consent Form Load Error: %@ (Code: %ld)", loadError.localizedDescription, (long)loadError.code] UTF8String]);
								else if (admobCallback)
									admobCallback("CONSENT_SUCCESS", "Consent form dismissed successfully.");

								initMobileAds(testingAds, childDirected, enableRDP);
							}];
						});
					}
				}];
			}
			else
			{
				if (admobCallback)
					admobCallback("CONSENT_NOT_REQUIRED", "Consent form not required or available.");

				initMobileAds(testingAds, childDirected, enableRDP);
			}
		}
	}];
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

		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
		{
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
	if (!interstitialDelegate)
		interstitialDelegate = [[InterstitialDelegate alloc] init];

	[interstitialDelegate loadWithAdUnitID:id];
}

void showAdmobInterstitial()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (interstitialDelegate)
			[interstitialDelegate show];
		else if (admobCallback)
			admobCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial Delegate is not initialized.");
	});
}

void loadAdmobRewarded(const char *id)
{
	if (!rewardedDelegate)
		rewardedDelegate = [[RewardedDelegate alloc] init];

	[rewardedDelegate loadWithAdUnitID:id];
}

void showAdmobRewarded()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (rewardedDelegate)
			[rewardedDelegate show];
		else if (admobCallback)
			admobCallback("REWARDED_FAILED_TO_SHOW", "Rewarded Delegate is not initialized.");
	});
}

void setAdmobVolume(float vol)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (vol > 0)
		{
			GADMobileAds.sharedInstance.applicationMuted = false;
			GADMobileAds.sharedInstance.applicationVolume = vol;
		}
		else
			GADMobileAds.sharedInstance.applicationMuted = true;
	});
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
