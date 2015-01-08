#include <AdMobEx.h>
#import <UIKit/UIKit.h>
#import "GADInterstitial.h"
extern "C"{
    #import "GADBannerView.h"
}

@interface InterstitialListener : NSObject <GADInterstitialDelegate> {
    @public
    GADInterstitial         *ad;
    NSString                *nsID;
    UIViewController        *root;
    bool                    failed;
    
}

- (id)initWithID:(const char*)ID;
- (void)load;
- (void)show;

@end

@implementation InterstitialListener

- (id)initWithID:(const char*)ID {
    self = [super init];
    if(self){
        failed = false;
        root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        nsID = [[NSString alloc] initWithUTF8String:ID];
    }
    return self;
}

- (void)load{
    ad = [[GADInterstitial alloc] init];
    ad.adUnitID = nsID;
    [ad setDelegate:self];
    GADRequest *request = [GADRequest request];
	request.testDevices = @[ GAD_SIMULATOR_ID ];
    [ad loadRequest:request];
}

- (void)show{
    if (ad.isReady){
        [ad presentFromRootViewController:root];
    } else if (failed){
        [self load];
    }
}

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    failed = true;
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial{
    failed = false;
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial{
    NSLog(@"will present");
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial{
    NSLog(@"will dismiss");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial{
    NSLog(@"did dismiss");
	[self load];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial{
    NSLog(@"will leave application");
}

@end



namespace admobex {
	
    static GADBannerView *bannerView;
	static InterstitialListener *interstitial;
    static bool bottom;

    static NSString *interstitialID;
	UIViewController *root;
    
	void init(const char *BannerID, const char *__InterstitialID, const char *gravityMode){
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
		request.testDevices = @[ GAD_SIMULATOR_ID ];
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
        interstitialID = [[NSString alloc] initWithUTF8String:__InterstitialID];
        interstitial = [[InterstitialListener alloc] initWithID:[interstitialID UTF8String]];
        [interstitial load];
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
        [interstitial show];
        interstitial = [[InterstitialListener alloc] initWithID:[interstitialID UTF8String]];
        [interstitial load];
    }

}
