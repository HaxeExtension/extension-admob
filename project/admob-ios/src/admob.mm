#include "admob.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>

static GADBannerView *bannerView = nil;
static GADInterstitialAd *interstitialAd = nil;
static GADRewardedAd *rewardedAd = nil;
static AdmobCallback admobCallback = nullptr;

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
    
    GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = @(childDirected);
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    
    if (admobCallback) admobCallback("INIT_OK", "AdMob initialized.");
}

void showAdmobBanner(const char *id, int size, int align)
{
    if (bannerView != nil)
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
        bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
        bannerView.adUnitID = [NSString stringWithUTF8String:id];
        bannerView.rootViewController = rootVC;
        [rootVC.view addSubview:bannerView];
        
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
    return 1;
}

const char *getAdmobConsent()
{
    return "CONSENTED";
}

bool isAdmobPrivacyOptionsRequired()
{
    return false;
}

void showAdmobPrivacyOptionsForm()
{
}
