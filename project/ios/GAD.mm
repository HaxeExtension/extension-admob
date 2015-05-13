#include <AdMobEx.h>
#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GADInterstitial.h"
extern "C"{
    #import "GoogleMobileAds/GADBannerView.h"
}

@interface InterstitialListener : NSObject <GADInterstitialDelegate> {
    @public
    GADInterstitial         *ad;
}

- (id)initWithID:(const char*)ID;
- (void)show;

@end

@implementation InterstitialListener

- (id)initWithID:(const char*)ID {
    self = [super init];
    NSLog(@"AdMob Init");
    if(!self) return nil;
    ad = [[GADInterstitial alloc] initWithAdUnitID:[NSString stringWithUTF8String:ID] ];
    ad.delegate = self;
    GADRequest *request = [GADRequest request];
    //request.testDevices = @[ GAD_SIMULATOR_ID ];
    //[ad loadRequest:request];
    [ad performSelector:@selector(loadRequest:) withObject:request afterDelay:1];
    return self;
}

- (void)show{
    if (ad != nil && ad.isReady) {
        [ad presentFromRootViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
    }
}

/// Called when an interstitial ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
}

/// Called when an interstitial ad request failed.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Called just before presenting an interstitial.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store).
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

@end

namespace admobex {
	
    static GADBannerView *bannerView;
	static InterstitialListener *interstitialListener;
    static bool bottom;

    static NSString *interstitialID;
	UIViewController *root;
    
	void init(const char *BannerID, const char *__InterstitialID, const char *gravityMode, bool testingAds){
		root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSString *GADID = [[NSString alloc] initWithUTF8String:BannerID];
        NSString *GMODE = [[NSString alloc] initWithUTF8String:gravityMode];

        // BANNER
        bottom=![GMODE isEqualToString:@"TOP"];

        if( [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight )
        {
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        }else{
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }

		bannerView.adUnitID = GADID;
		bannerView.rootViewController = root;

        GADRequest *request = [GADRequest request];
		//request.testDevices = @[ GAD_SIMULATOR_ID ];
		[bannerView loadRequest:request];
        [root.view addSubview:bannerView];
        bannerView.hidden=true;
        // THOSE THREE LINES ARE FOR SETTING THE BANNER BOTTOM ALIGNED
        if(bottom){
            CGRect frame = bannerView.frame;
            frame.origin.y = root.view.bounds.size.height - frame.size.height;
            bannerView.frame=frame;
        }

        // INTERSTITIAL
        interstitialID = [NSString stringWithUTF8String:__InterstitialID];
        interstitialListener = [[InterstitialListener alloc] initWithID:[interstitialID UTF8String]];
    }
    
    void showBanner(){
        bannerView.hidden=false;
    }
    
    void hideBanner(){
        bannerView.hidden=true;
    }
    
	void refreshBanner(){
		[bannerView loadRequest:[GADRequest request]];
	}

    void showInterstitial(){
        if(interstitialListener!=nil) [interstitialListener show];
        interstitialListener = [[InterstitialListener alloc] initWithID:[interstitialID UTF8String]];
    }

}
