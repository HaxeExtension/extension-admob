#include "admob.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CommonCrypto/CommonDigest.h>

static GADBannerView *bannerView = nil;
static GADInterstitialAd *interstitialAd = nil;
static GADRewardedAd *rewardedAd = nil;
static AdmobCallback admobCallback = nullptr;

static void initMobileAds(bool testingAds, bool childDirected, bool enableRDP, bool requestIDFA)
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

        GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[deviceId];
    }

    if (childDirected)
    {
        GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = @YES;
    }

    if (enableRDP)
    {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"gad_rdp"];
    }

    if (requestIDFA)
    {
        if (@available(iOS 14, *))
        {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status)
            {
                [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
                {
                    if (admobCallback) admobCallback("INIT_OK", "AdMob initialized.");
                }];
            }];
            return;
        }
    }

    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
    {
        if (admobCallback) admobCallback("INIT_OK", "AdMob initialized.");
    }];
}

void initAdmob(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback)
{
    admobCallback = callback;

    UMPRequestParameters *params = [[UMPRequestParameters alloc] init];
    params.tagForUnderAgeOfConsent = childDirected;
    
    [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:params
        completionHandler:^(NSError * _Nullable error) {
            if (error) {
                if (admobCallback) admobCallback("CONSENT_FAIL", "Failed to load consent info.");
            } else {
                if (UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable) {
                    [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *_Nullable form, NSError *_Nullable loadError) {
                        if (loadError) {
                            if (admobCallback) admobCallback("CONSENT_FAIL", "Failed to load consent form.");
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [form presentFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController
                                                    completionHandler:^(NSError * _Nullable error) {
                                    if (error) {
                                        if (admobCallback) admobCallback("CONSENT_FAIL", "Consent form error.");
                                    } else {
                                        if (admobCallback) admobCallback("CONSENT_FORM_PRESENTED", "Consent form presented successfully.");
                                    }
                                }];
                            });
                        }
                    }];
                } else {
                    if (admobCallback) admobCallback("INIT_OK", "Consent form not required.");
                }
            }
        }];
    
    initMobileAds(testingAds, childDirected, enableRDP, false);

    if (admobCallback) admobCallback("INIT_OK", "AdMob initialized.");
}

void showAdmobBanner(const char *id, int size, int align)
{
    if (bannerView != nil)
        return;

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
        [rootVC.view addSubview:bannerView];

        CGRect screenBounds = UIScreen.mainScreen.bounds;

        CGFloat bannerWidth = bannerView.bounds.size.width;
        CGFloat bannerHeight = bannerView.bounds.size.height;

        switch (align)
        {
            case 1:
                bannerView.center = CGPointMake(screenBounds.size.width / 2, bannerHeight / 2);
                break;
            default:
                bannerView.center = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height - bannerHeight / 2);
                break;
        }

        GADRequest *request = [GADRequest request];

        [bannerView loadRequest:request];
        
        if (admobCallback) admobCallback("BANNER_LOADED", "Banner request loaded.");
    });
}

void hideAdmobBanner()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bannerView != nil) {
            [bannerView removeFromSuperview];
            bannerView = nil;
            if (admobCallback) admobCallback("BANNER_CLOSED", "Banner removed.");
        }
    });
}

void loadAdmobInterstitial(const char *id)
{
    NSString *adUnitID = [NSString stringWithUTF8String:id];
    GADRequest *request = [GADRequest request];

    [GADInterstitialAd loadWithAdUnitID:adUnitID request:request completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            interstitialAd = nil;
            if (admobCallback) admobCallback("INTERSTITIAL_FAILED_TO_LOAD", "Failed to load interstitial.");
        } else {
            interstitialAd = ad;
            if (admobCallback) admobCallback("INTERSTITIAL_LOADED", "Interstitial loaded.");
        }
    }];
}

void showAdmobInterstitial()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (interstitialAd != nil) {
            UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
            [interstitialAd presentFromRootViewController:rootVC];
            if (admobCallback) admobCallback("INTERSTITIAL_SHOWED", "Interstitial displayed.");
        } else {
            if (admobCallback) admobCallback("INTERSTITIAL_FAILED_TO_SHOW", "Interstitial not ready.");
        }
    });
}

void loadAdmobRewarded(const char *id)
{
    NSString *adUnitID = [NSString stringWithUTF8String:id];
    GADRequest *request = [GADRequest request];

    [GADRewardedAd loadWithAdUnitID:adUnitID request:request completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            rewardedAd = nil;
            if (admobCallback) admobCallback("REWARDED_FAILED_TO_LOAD", "Failed to load rewarded ad.");
        } else {
            rewardedAd = ad;
            if (admobCallback) admobCallback("REWARDED_LOADED", "Rewarded ad loaded.");
        }
    }];
}

void showAdmobRewarded()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (rewardedAd != nil) {
            UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
            [rewardedAd presentFromRootViewController:rootVC userDidEarnRewardHandler:^{
                GADAdReward *reward = rewardedAd.adReward;
                if (admobCallback) admobCallback("REWARDED_EARNED", "Reward earned.");
            }];
            if (admobCallback) admobCallback("REWARDED_SHOWED", "Rewarded ad displayed.");
        } else {
            if (admobCallback) admobCallback("REWARDED_FAILED_TO_SHOW", "Rewarded ad not ready.");
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
    UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;

    [UMPConsentForm presentPrivacyOptionsFormFromViewController:rootVC
        completionHandler:^(NSError *_Nullable formError)
        {
            if (formError && admobCallback)
            {
                admobCallback("CONSENT_FAIL", [[formError localizedDescription] UTF8String]);
            }
        }
    ];
}
