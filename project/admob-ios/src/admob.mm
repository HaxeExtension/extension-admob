#include "admob.hpp"

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CommonCrypto/CommonDigest.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>

//need to update admob-Info.plist from time to time from here: https://developers.google.com/admob/ios/ios14?hl=en

static AdmobCallback _admobCallback = nullptr;
static GADBannerView *_bannerView = nil;
static int _currentAlign = 0;
static char _message[128] = "";//need this to pass message from ios to haxe, local variable gets lost in transition

static void dispatchCallback(const char * event, const char * message) {
	if (_admobCallback) {
		dispatch_async(dispatch_get_main_queue(), ^{
			try {
				_admobCallback(event, message);
 			}
			catch (...) {
				NSLog(@"AdMob: Dispatch callback exception occured");
			}
		});
	}
}

static void alignBanner(GADBannerView *bannerView, int align)
{
	if (!bannerView)
		return;

	// UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;

	// if (@available(iOS 11.0, *))
	//     safeAreaInsets = UIApplication.sharedApplication.keyWindow.safeAreaInsets; // This handles the notch-safe area

	CGRect screenBounds = UIScreen.mainScreen.bounds;
	CGFloat bannerWidth = bannerView.bounds.size.width;
	CGFloat bannerHeight = bannerView.bounds.size.height;

	switch (align)
	{
	case 1:
		// bannerView.center = screenBounds.size.width > screenBounds.size.height ? CGPointMake(screenBounds.size.width / 2, safeAreaInsets.left + bannerHeight / 2) : CGPointMake(screenBounds.size.width / 2, safeAreaInsets.top + bannerHeight / 2);
		bannerView.center = CGPointMake(screenBounds.size.width / 2, bannerHeight / 2);
		break;
	default:
		// bannerView.center = screenBounds.size.width > screenBounds.size.height ? CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - safeAreaInsets.right - bannerHeight / 2) : CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - safeAreaInsets.bottom - bannerHeight / 2);
		bannerView.center = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - bannerHeight / 2);
		break;
	}
}

@interface BannerHelper : NSObject
+ (void)handleOrientationChange;
@end

@implementation BannerHelper
+ (void)handleOrientationChange
{
	if (_bannerView)
	{
        
		dispatch_async(dispatch_get_main_queue(), ^{
  			alignBanner(_bannerView, _currentAlign);
		});
	}
}
@end

@interface BannerViewDelegate : NSObject <GADBannerViewDelegate>
@end

@implementation BannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)_bannerView
{
	dispatchCallback("BANNER_LOADED", "");
}

- (void)bannerView:(GADBannerView *)_bannerView didFailToReceiveAdWithError:(NSError *)error
{
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
	dispatchCallback("BANNER_FAILED_TO_LOAD", _message);
}

- (void)bannerViewDidRecordClick:(GADBannerView *)_bannerView
{
	dispatchCallback("BANNER_CLICKED", "");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)_bannerView
{
	dispatchCallback("BANNER_OPENED", "");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)_bannerView
{
	dispatchCallback("BANNER_CLOSED", "");
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
			[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
			dispatchCallback("INTERSTITIAL_FAILED_TO_LOAD", _message);
		}
		else
		{
			self._ad = ad;
			self._ad.fullScreenContentDelegate = self;

			dispatchCallback("INTERSTITIAL_LOADED", "");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController]];

		dispatchCallback("INTERSTITIAL_SHOWED", "");
	}
	else
	{
		dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial ad not ready.");
	}
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("INTERSTITIAL_CLICKED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("INTERSTITIAL_DISMISSED", "");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
	dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", _message);
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
			[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
			dispatchCallback("REWARDED_FAILED_TO_LOAD", _message);
		}
		else
		{
			self._ad = ad;
			self._ad.fullScreenContentDelegate = self;

			dispatchCallback("REWARDED_LOADED", "");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] userDidEarnRewardHandler:^{
			[[NSString stringWithFormat:@"%@:%d", self._ad.adReward.type, self._ad.adReward.amount.intValue] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
			dispatchCallback("REWARDED_EARNED", _message);
		}];

		dispatchCallback("REWARDED_SHOWED", "");
	}
	else
	{
		dispatchCallback("REWARDED_FAILED_TO_SHOW", "Rewarded ad not ready.");
	}
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("REWARDED_CLICKED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("REWARDED_DISMISSED", "");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
	dispatchCallback("REWARDED_FAILED_TO_SHOW", _message);
}

@end

@interface AppOpenAdDelegate : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADAppOpenAd *_ad;

- (void)loadWithAdUnitID:(const char *)adUnitID;
- (void)show;

@end

@implementation AppOpenAdDelegate

- (void)loadWithAdUnitID:(const char *)adUnitID
{
	self._ad = nil;

	[GADAppOpenAd loadWithAdUnitID:[NSString stringWithUTF8String:adUnitID] request:[GADRequest request] completionHandler:^(GADAppOpenAd *ad, NSError *error)
	{
		if (error)
		{
			[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
			dispatchCallback("APP_OPEN_FAILED_TO_LOAD", _message);
		}
		else
		{
			self._ad = ad;
			self._ad.fullScreenContentDelegate = self;

			dispatchCallback("APP_OPEN_LOADED", "");
		}
	}];
}

- (void)show
{
	if (self._ad != nil && [self._ad canPresentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController] error:nil])
	{
		[self._ad presentFromRootViewController:[UIApplication.sharedApplication.keyWindow rootViewController]];

		dispatchCallback("APP_OPEN_SHOWED", "");
	}
	else
	{
		dispatchCallback("APP_OPEN_FAILED_TO_SHOW", "App Open ad not ready.");
	}
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("APP_OPEN_CLICKED", "");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
	dispatchCallback("APP_OPEN_DISMISSED", "");
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
	[[NSString stringWithFormat:@"Error Code: %zd, Description: %@", error.code, error.localizedDescription] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
	dispatchCallback("APP_OPEN_FAILED_TO_SHOW", _message);
}

@end

static BannerViewDelegate *bannerDelegate = nil;
static InterstitialDelegate *interstitialDelegate = nil;
static RewardedDelegate *rewardedDelegate = nil;
static AppOpenAdDelegate *appOpenDelegate = nil;

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

	[[NSString stringWithFormat:@"%zd.%zd.%zd",
							GADMobileAds.sharedInstance.versionNumber.majorVersion,
							GADMobileAds.sharedInstance.versionNumber.minorVersion,
							GADMobileAds.sharedInstance.versionNumber.patchVersion] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
	if (@available(iOS 14.0, *))
	{
		int purpose = hasAdmobConsentForPurpose(0);

		if (purpose == 1 || purpose == -1)
		{
			[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status)
			{
				/*if (_admobCallback)
				{
					switch (status)
					{
					case ATTrackingManagerAuthorizationStatusNotDetermined:
						_admobCallback("ATT_STATUS", "NOT_DETERMINED");
						break;
					case ATTrackingManagerAuthorizationStatusRestricted:
						_admobCallback("ATT_STATUS", "RESTRICTED");
						break;
					case ATTrackingManagerAuthorizationStatusDenied:
						_admobCallback("ATT_STATUS", "DENIED");
						break;
					case ATTrackingManagerAuthorizationStatusAuthorized:
						_admobCallback("ATT_STATUS", "AUTHORIZED");
						break;
					}
				}*/

				[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status2)
				{					
					switch (status)
					{
					case ATTrackingManagerAuthorizationStatusNotDetermined:
						dispatchCallback("ATT_STATUS", "NOT_DETERMINED");
						break;
					case ATTrackingManagerAuthorizationStatusRestricted:
						dispatchCallback("ATT_STATUS", "RESTRICTED");
						break;
					case ATTrackingManagerAuthorizationStatusDenied:
						dispatchCallback("ATT_STATUS", "DENIED");
						break;
					case ATTrackingManagerAuthorizationStatusAuthorized:
						dispatchCallback("ATT_STATUS", "AUTHORIZED");
						break;
					}
					
					dispatchCallback("INIT_OK", _message);
				}];
			}];
		}
		else
		{
			[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
			{
				dispatchCallback("INIT_OK", _message);
			}];
		}
	}
	else
	{
		[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
		{
			dispatchCallback("INIT_OK", _message);
		}];
	}
}

//https://support.google.com/admob/answer/10115027?hl=en&sjid=6409788409933810109-AP
void initAdmob(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback)
{
	_admobCallback = callback;

	UMPRequestParameters *params = [[UMPRequestParameters alloc] init];

	params.tagForUnderAgeOfConsent = childDirected;
	
	//>> use this to debug GDPR
	/*[UMPConsentInformation.sharedInstance reset];
	UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
	debugSettings.testDeviceIdentifiers = @[ @"[TEST_DEVICE_ID]" ];
	debugSettings.geography = UMPDebugGeographyEEA;
	params.debugSettings = debugSettings;*/
	//<<

	[UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:params completionHandler:^(NSError *_Nullable error)
	{
		if (error)
		{
			[[NSString stringWithFormat:@"Consent Info Error: %@ (Code: %zd)", error.localizedDescription, error.code] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
			dispatchCallback("CONSENT_FAIL", _message);

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
						[[NSString stringWithFormat:@"Consent Form Load Error: %@ (Code: %zd)", loadError.localizedDescription, loadError.code] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
						dispatchCallback("CONSENT_FAIL", _message);

						initMobileAds(testingAds, childDirected, enableRDP);
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[form presentFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable error)
							{
								if (loadError)
								{
									[[NSString stringWithFormat:@"Consent Form Load Error: %@ (Code: %zd)", loadError.localizedDescription, loadError.code] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
									dispatchCallback("CONSENT_FAIL", _message);
								}
								else 
									dispatchCallback("CONSENT_SUCCESS", "Consent form dismissed successfully.");

								initMobileAds(testingAds, childDirected, enableRDP);
							}];
						});
					}
				}];
			}
			else
			{
				dispatchCallback("CONSENT_NOT_REQUIRED", "Consent form not required or available.");

				initMobileAds(testingAds, childDirected, enableRDP);
			}
		}
	}];
}

void showAdmobBanner(const char *id, int size, int align)
{
	if (_bannerView != nil)
	{
		dispatchCallback("BANNER_FAILED_TO_LOAD", "Hide previous banner first!");

		return;
	}

	_currentAlign = align;

	dispatch_async(dispatch_get_main_queue(), ^{

		UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;

		GADAdSize adSize;

		switch (size)
		{
		case 1:
			adSize = GADAdSizeBanner;
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
		case 6:
			adSize = GADAdSizeFluid;
		default:
			CGRect frame = rootVC.view.frame;
			if (@available(iOS 11.0, *))
				frame = UIEdgeInsetsInsetRect(rootVC.view.frame, rootVC.view.safeAreaInsets);
			CGFloat viewWidth = frame.size.width;
			adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
			
			break;
		}

		_bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
		_bannerView.adUnitID = [NSString stringWithUTF8String:id];
		_bannerView.rootViewController = rootVC;

		if (bannerDelegate == nil)
			bannerDelegate = [[BannerViewDelegate alloc] init];

		_bannerView.backgroundColor = UIColor.clearColor;
		_bannerView.delegate = bannerDelegate;

		[rootVC.view addSubview:_bannerView];

		alignBanner(_bannerView, align);

		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
		{
			[BannerHelper handleOrientationChange];
		}];

		[_bannerView loadRequest:[GADRequest request]];
	});
}

void hideAdmobBanner()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_bannerView != nil)
		{
			[_bannerView removeFromSuperview];
			_bannerView = nil;
		}
	});
}

void loadAdmobInterstitial(const char *id)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!interstitialDelegate)
			interstitialDelegate = [[InterstitialDelegate alloc] init];

		[interstitialDelegate loadWithAdUnitID:id];
	});
}

void showAdmobInterstitial()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (interstitialDelegate)
			[interstitialDelegate show];
		else 
			dispatchCallback("INTERSTITIAL_FAILED_TO_SHOW", "You need to load interstitial ad first!");
	});
}

void loadAdmobRewarded(const char *id)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!rewardedDelegate)
			rewardedDelegate = [[RewardedDelegate alloc] init];

		[rewardedDelegate loadWithAdUnitID:id];
	});
}

void showAdmobRewarded()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (rewardedDelegate)
			[rewardedDelegate show];
		else 
			dispatchCallback("REWARDED_FAILED_TO_SHOW", "You need to load rewarded ad first!");
	});
}

void loadAdmobAppOpen(const char *id)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!appOpenDelegate)
			appOpenDelegate = [[AppOpenAdDelegate alloc] init];

		[appOpenDelegate loadWithAdUnitID:id];
	});
}

void showAdmobAppOpen()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (appOpenDelegate)
			[appOpenDelegate show];
		else 
			dispatchCallback("APP_OPEN_FAILED_TO_SHOW", "You need to load App Open Ad first!");
	});
}

void setAdmobVolume(float vol)
{
	if (vol > 0)
	{
		GADMobileAds.sharedInstance.applicationMuted = false;
		GADMobileAds.sharedInstance.applicationVolume = vol;
	}
	else
		GADMobileAds.sharedInstance.applicationMuted = true;
}

int hasAdmobConsentForPurpose(int purpose)
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents == nil || purposeConsents.length == 0)
		return -1;

	if (purpose >= purposeConsents.length)
		return -1;

	return [[purposeConsents substringWithRange:NSMakeRange(purpose, 1)] integerValue];
}

const char *getAdmobConsent()
{
	NSString *purposeConsents = [NSUserDefaults.standardUserDefaults stringForKey:@"IABTCF_PurposeConsents"];

	if (purposeConsents.length > 0)
	{
		[purposeConsents getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
		return _message;
	}

	return "";
}

bool isAdmobPrivacyOptionsRequired()
{
	return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == UMPPrivacyOptionsRequirementStatusRequired;
}

void showAdmobPrivacyOptionsForm()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[UMPConsentForm presentPrivacyOptionsFormFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController completionHandler:^(NSError *_Nullable formError)
		{
			 if (formError)
			 {
				 
				 [[NSString stringWithFormat:@"Consent Form Error: %@ (Code: %zd)", formError.localizedDescription, formError.code] getCString:_message maxLength:sizeof(_message) encoding:NSUTF8StringEncoding];
				 dispatchCallback("CONSENT_FAIL", _message);
			 }
		}];
	});
}
