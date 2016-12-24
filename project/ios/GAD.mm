#include <AdMobEx.h>
#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GADInterstitial.h"
extern "C"{
    #import "GoogleMobileAds/GADBannerView.h"
}

extern "C" void reportInterstitialEvent (const char* event);
static const char* ADMOB_LEAVING = "LEAVING";
static const char* ADMOB_FAILED = "FAILED";
static const char* ADMOB_CLOSED = "CLOSED";
static const char* ADMOB_DISPLAYING = "DISPLAYING";
static const char* ADMOB_LOADED = "LOADED";
static const char* ADMOB_LOADING = "LOADING";

////////////////////////////////////////////////////////////////////////

static bool _admobexChildDirected;

GADRequest *_admobexGetGADRequest(){
    GADRequest *request = [GADRequest request];
    if(_admobexChildDirected){
        NSLog(@"AdMobEx: enabling COPPA support");
        [request tagForChildDirectedTreatment:YES];
    }
    return request;        
}

////////////////////////////////////////////////////////////////////////

@interface InterstitialListener : NSObject <GADInterstitialDelegate> {
    @public
    GADInterstitial         *ad;
}

- (id)initWithID:(NSString*)ID;
- (void)show;
- (bool)isReady;

@end

@implementation InterstitialListener

- (id)initWithID:(NSString*)ID {
    self = [super init];
    if(!self) return nil;
    ad = [[GADInterstitial alloc] initWithAdUnitID:ID];
    ad.delegate = self;
    GADRequest *request = _admobexGetGADRequest();
    request.testDevices = @[ kGADSimulatorID ];
    [ad performSelector:@selector(loadRequest:) withObject:request afterDelay:1];
    NSLog(@"AdMob Loading Interstitial");
    reportInterstitialEvent(ADMOB_LOADING);
    return self;
}

- (bool)isReady{
    return (ad != nil && ad.isReady);
}

- (void)show{
    if (![self isReady]) return;
    [ad presentFromRootViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
}

/// Called when an interstitial ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
    reportInterstitialEvent(ADMOB_LOADED);
}

/// Called when an interstitial ad request failed.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
    reportInterstitialEvent(ADMOB_FAILED);
}

/// Called just before presenting an interstitial.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
    reportInterstitialEvent(ADMOB_DISPLAYING);
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
    reportInterstitialEvent(ADMOB_CLOSED);
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store).
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
    reportInterstitialEvent(ADMOB_LEAVING);
}

@end

namespace admobex {
	
    static GADBannerView *bannerView;
	static InterstitialListener *interstitialListener;
    static bool bottom;

    static NSString *interstitialID;
	UIViewController *root;
    
	void init(const char *__BannerID, const char *__InterstitialID, const char *gravityMode, bool testingAds, bool tagForChildDirectedTreatment){
		root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSString *GMODE = [NSString stringWithUTF8String:gravityMode];
        NSString *bannerID = [NSString stringWithUTF8String:__BannerID];
        interstitialID = [NSString stringWithUTF8String:__InterstitialID];
        _admobexChildDirected = tagForChildDirectedTreatment;

        if(testingAds){
            interstitialID = @"ca-app-pub-3940256099942544/4411468910"; // ADMOB GENERIC TESTING INTERSTITIAL
            bannerID = @"ca-app-pub-3940256099942544/2934735716"; // ADMOB GENERIC TESTING BANNER
        }

        // BANNER
        bottom=![GMODE isEqualToString:@"TOP"];

        if( [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight )
        {
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        }else{
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }

		bannerView.adUnitID = bannerID;
		bannerView.rootViewController = root;

        GADRequest *request = _admobexGetGADRequest();
		request.testDevices = @[ kGADSimulatorID ];
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
        interstitialListener = [[InterstitialListener alloc] initWithID:interstitialID];
    }
    
    void showBanner(){
        bannerView.hidden=false;
    }
    
    void hideBanner(){
        bannerView.hidden=true;
    }
    
	void refreshBanner(){
		[bannerView loadRequest:_admobexGetGADRequest()];
	}

    bool showInterstitial(){
        if(interstitialListener==nil) return false;
        if(![interstitialListener isReady]) return false;
        [interstitialListener show];
        interstitialListener = [[InterstitialListener alloc] initWithID:interstitialID];
        return true;
    }


}
