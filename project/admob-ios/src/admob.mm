#include "admob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static GADBannerView *bannerView = nil;
static GADInterstitialAd *interstitialAd = nil;
static GADRewardedAd *rewardedAd = nil;

void initAdmob(bool testingAds, bool childDirected, bool enableRDP)
{
	GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment(childDirected);

	if (testingAds)
		GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ kGADSimulatorID ];

	[GADMobileAds.sharedInstance startWithCompletionHandler:nil];
}

void showAdmobBanner(const char *id, int size, int align)
{
	if (bannerView != nil)
		return;

	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
		bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
		bannerView.adUnitID = [NSString stringWithUTF8String:id];
		bannerView.rootViewController = rootVC;
		[rootVC.view addSubview:bannerView];
		GADRequest *request = [GADRequest request];
		[bannerView loadRequest:request];
	});
}

void hideAdmobBanner()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (bannerView != nil)
		{
			[bannerView removeFromSuperview];
			bannerView = nil;
		}
	});
}

void loadAdmobInterstitial(const char *id)
{
	NSString *adUnitID = [NSString stringWithUTF8String:id];
	GADRequest *request = [GADRequest request];

	[GADInterstitialAd loadWithAdUnitID:adUnitID request:request completionHandler:^(GADInterstitialAd *ad, NSError *error)
	{
		if (error) {
			interstitialAd = nil;
		} else {
			interstitialAd = ad;
		}
	}];
}

void showAdmobInterstitial()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (interstitialAd != nil) {
			UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
			[interstitialAd presentFromRootViewController:rootVC];
		}
	});
}

void loadAdmobRewarded(const char *id)
{
	NSString *adUnitID = [NSString stringWithUTF8String:id];
	GADRequest *request = [GADRequest request];
	[GADRewardedAd loadWithAdUnitID:adUnitID
							 request:request
				   completionHandler:^(GADRewardedAd *ad, NSError *error) {
		if (error) {
			rewardedAd = nil;
		} else {
			rewardedAd = ad;
		}
	}];
}

void showAdmobRewarded()
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (rewardedAd != nil) {
			UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
			[rewardedAd presentFromRootViewController:rootVC
							  userDidEarnRewardHandler:^{
				GADAdReward *reward = rewardedAd.adReward;
			}];
		}
	});
}

void setAdmobVolume(float vol)
{
	GADMobileAds.sharedInstance.applicationVolume = vol;
}

int hasAdmobConsentForPuprpose(int purpose)
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
