#import <AdMobEx.h>
#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#include <CommonCrypto/CommonDigest.h>

extern "C" void onStatus(const char* code, const char* data);

static const char* INIT_OK = "INIT_OK";
static const char* INIT_FAIL = "INIT_FAIL";
static const char* BANNER_LOADED = "BANNER_LOADED";
static const char* BANNER_FAILED_TO_LOAD = "BANNER_FAILED_TO_LOAD";
static const char* BANNER_OPENED = "BANNER_OPENED";
static const char* BANNER_CLICKED = "BANNER_CLICKED";
static const char* BANNER_CLOSED = "BANNER_CLOSED";
static const char* INTERSTITIAL_LOADED = "INTERSTITIAL_LOADED";
static const char* INTERSTITIAL_FAILED_TO_LOAD = "INTERSTITIAL_FAILED_TO_LOAD";
static const char* INTERSTITIAL_DISMISSED = "INTERSTITIAL_DISMISSED";
static const char* INTERSTITIAL_FAILED_TO_SHOW = "INTERSTITIAL_FAILED_TO_SHOW";
static const char* INTERSTITIAL_SHOWED = "INTERSTITIAL_SHOWED";
static const char* REWARDED_LOADED = "REWARDED_LOADED";
static const char* REWARDED_FAILED_TO_LOAD = "REWARDED_FAILED_TO_LOAD";
static const char* REWARDED_DISMISSED = "REWARDED_DISMISSED";
static const char* REWARDED_FAILED_TO_SHOW = "REWARDED_CACHE_OK";
static const char* REWARDED_SHOWED = "REWARDED_SHOWED";
static const char* REWARDED_EARNED = "REWARDED_EARNED";
static const char* WHAT_IS_GOING_ON = "WHAT_IS_GOING_ON";

static const int BANNER_SIZE_ADAPTIVE = 0; //Anchored adaptive, somewhat default now (a replacement for SMART_BANNER); banner width is fullscreen, height calculated acordingly (might not work well with landscape orientation)
static const int BANNER_SIZE_BANNER = 1; //320x50
//static const int BANNER_SIZE_FLUID = 2; //A dynamically sized banner that matches its parent's width and expands/contracts its height to match the ad's content after loading completes. Android donly?
static const int BANNER_SIZE_FULL_BANNER = 3; //468x60
static const int BANNER_SIZE_LARGE_BANNER = 4; //320x100
static const int BANNER_SIZE_LEADERBOARD = 5; //728x90
static const int BANNER_SIZE_MEDIUM_RECTANGLE = 6; //300x250
//static const int BANNER_SIZE_WIDE_SKYSCRAPER = 7; //160x600, Android donly?

static const int BANNER_ALIGN_TOP = 0x00000030 | 0x00000001;
static const int BANNER_ALIGN_BOTTOM = 0x00000050 | 0x00000001;

static const char* IDFA_AUTORIZED = "IDFA_AUTORIZED";
static const char* IDFA_DENIED = "IDFA_DENIED";
static const char* IDFA_NOT_DETERMINED = "IDFA_NOT_DETERMINED";
static const char* IDFA_RESTRICTED = "IDFA_RESTRICTED";
static const char* IDFA_NOT_SUPPORTED = "IDFA_NOT_SUPPORTED";

@interface BannerListener : NSObject <GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *_banner;
@property(nonatomic, strong) UIViewController *_root;
@property(nonatomic) int _align;

- (id)showWithID:(NSString*)ID withSize:(NSInteger)size withAlign:(NSInteger)align;
- (void)hide;
- (void)align;

@end

@implementation BannerListener

- (id)showWithID:(NSString*)ID withSize:(NSInteger)size withAlign:(NSInteger)align
{
	self = [super init]; //needed???
	if(!self) return nil;
	
	self._root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	//self._root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	
	switch(size)
	{
		case BANNER_SIZE_ADAPTIVE:
		{
			CGRect frame = self._root.view.frame;
			// Here safe area is taken into account, hence the view frame is used after
			// the view has been laid out.
			if(@available(iOS 11.0, *))
			{
				frame = UIEdgeInsetsInsetRect(self._root.view.frame, self._root.view.safeAreaInsets);
			}
			CGFloat viewWidth = frame.size.width;
			
			self._banner = [[GADBannerView alloc] initWithAdSize:GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)];
			break;
		}
		
		case BANNER_SIZE_BANNER:
		{
			self._banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
			break;
		}
		
		case BANNER_SIZE_FULL_BANNER:
		{
			self._banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
			break;
		}
			
		case BANNER_SIZE_LARGE_BANNER:
		{
			self._banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner];
			break;
		}
			
		case BANNER_SIZE_LEADERBOARD:
		{
			self._banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
			break;
		}
			
		case BANNER_SIZE_MEDIUM_RECTANGLE:
		{
			self._banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
			break;
		}
	}
	
	self._align = align;

	self._banner.adUnitID = ID;
	self._banner.rootViewController = self._root;
	
	self._banner.delegate = self;
	[self._banner loadRequest:[GADRequest request]];
	self._banner.translatesAutoresizingMaskIntoConstraints = NO;
	[self._root.view addSubview:self._banner];
	
	return self;
}

- (void)hide
{
	self._banner.hidden = true;
	//[self._banner removeFromSuperView];
	self._banner.delegate = nil;
	[self._banner release];
}

- (void)align
{
	CGRect bounds = self._root.view.bounds;
	if(@available(iOS 11.0, *))
	{
		CGRect safeAreaFrame = self._root.view.safeAreaLayoutGuide.layoutFrame;
		if(!CGSizeEqualToSize(CGSizeZero, safeAreaFrame.size))
		{
			bounds = safeAreaFrame;
		}
	}
	
	CGFloat centerX = CGRectGetMidX(bounds);
	CGPoint bannerPos = CGPointMake(centerX, 0);
	if(self._align == BANNER_ALIGN_TOP)
	{
		CGFloat top = CGRectGetMinY(bounds) + CGRectGetMidY(self._banner.bounds);
		bannerPos = CGPointMake(centerX, top);
		self._banner.center = bannerPos;
	}
	else
	{
		CGFloat bottom = CGRectGetMaxY(bounds) - CGRectGetMidY(self._banner.bounds);
		bannerPos = CGPointMake(centerX, bottom);
		self._banner.center = bannerPos;
	}
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)banner {
	//NSLog(@"bannerViewDidReceiveAd");
	[self align];
	onStatus(BANNER_LOADED, nil);
}

- (void)bannerView:(GADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
  //NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
  onStatus(BANNER_FAILED_TO_LOAD, [[error localizedDescription] UTF8String]);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)banner {
  //NSLog(@"bannerViewDidRecordImpression");
  [self align]; //repeat align here because might not alaways work at bannerViewDidReceiveAd
  onStatus(BANNER_OPENED, nil);
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)banner {
  //NSLog(@"bannerViewWillPresentScreen");
  onStatus(BANNER_CLICKED, nil);
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)banner {
  //NSLog(@"bannerViewWillDismissScreen");
  onStatus(BANNER_CLOSED, nil);
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)banner {
  //NSLog(@"bannerViewDidDismissScreen");
}

@end

@interface InterstitialListener : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *_ad;

- (id)loadWithAdUnitID:(NSString*)ID;
- (void)show;

@end

@implementation InterstitialListener

- (id)loadWithAdUnitID:(NSString*)ID
{
	self = [super init];
	if(!self) return nil;
	
	GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:ID
		request:request
		completionHandler:^(GADInterstitialAd *ad, NSError *error)
		{
			if(error != nil)
			{
				//NSLog(@"AdMob failed to load interstitial ad with error: %@", [error localizedDescription]);
				onStatus(INTERSTITIAL_FAILED_TO_LOAD, [[error localizedDescription] UTF8String]);
			}
			else
			{
				self._ad = ad;
				self._ad.fullScreenContentDelegate = self;
				
				onStatus(INTERSTITIAL_LOADED, nil);
			}
		}
	];
	
	return self;
}

- (void)show
{
	if(self._ad != nil)
	{
		[self._ad presentFromRootViewController:[[[[UIApplication sharedApplication] delegate] window] rootViewController]];
		//[self._ad presentFromRootViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
	}
	else
	{
		onStatus(INTERSTITIAL_FAILED_TO_SHOW, "Load interstitial ad first.");
	}
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    //NSLog(@"Ad did fail to present full screen content.");
	onStatus(INTERSTITIAL_FAILED_TO_SHOW, [[error localizedDescription] UTF8String]);
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    //NSLog(@"Ad did present full screen content.");
	onStatus(INTERSTITIAL_SHOWED, nil);
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
   //NSLog(@"Ad did dismiss full screen content.");
   onStatus(INTERSTITIAL_DISMISSED, nil);
}

@end

@interface RewardedListener : NSObject <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADRewardedAd *_ad;

- (id)loadWithAdUnitID:(NSString*)ID;
- (void)show;

@end

@implementation RewardedListener

- (id)loadWithAdUnitID:(NSString*)ID
{
	self = [super init];
	if(!self) return nil;
	
	GADRequest *request = [GADRequest request];
	[GADRewardedAd loadWithAdUnitID:ID
		request:request
		completionHandler:^(GADRewardedAd *ad, NSError *error)
		{
			if(error != nil)
			{
			  //NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
			  onStatus(REWARDED_FAILED_TO_LOAD, [[error localizedDescription] UTF8String]);
			  return;
			}
			else
			{
				self._ad = ad;
				self._ad.fullScreenContentDelegate = self;
				
				//NSLog(@"Rewarded ad loaded.");
				
				onStatus(REWARDED_LOADED, nil);
			}
		}
	];
	
	return self;
}

- (void)show
{
	if(self._ad != nil)
	{
		[self._ad presentFromRootViewController:[[[[UIApplication sharedApplication] delegate] window] rootViewController]
			userDidEarnRewardHandler:^
			{
				GADAdReward *reward = self._ad.adReward;
				NSString *ebat = [NSString stringWithFormat:@"%@:%d", reward.type, reward.amount.intValue];
				onStatus(REWARDED_EARNED, [ebat UTF8String]);
			}
		];
	}
	else
	{
		onStatus(REWARDED_FAILED_TO_SHOW, "Load rewarded ad first.");
	}
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    //NSLog(@"Ad did fail to present full screen content.");
	onStatus(REWARDED_FAILED_TO_SHOW, [[error localizedDescription] UTF8String]);
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    //NSLog(@"Ad did present full screen content.");
	onStatus(REWARDED_SHOWED, nil);
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
   //NSLog(@"Ad did dismiss full screen content.");
   onStatus(REWARDED_DISMISSED, nil);
}

@end

namespace admobex
{	
	static BannerListener *_bannerListener;
	static InterstitialListener *_interstitialListener;
	static RewardedListener *_rewardedListener;
	static NSString *statusIDFA = @"";
	
	void init(bool testingAds, bool childDirected, bool enableRDP, bool requestIDFA)
	{
		//NSLog(@"Init1 %d %d %d %d", testingAds, childDirected, enableRDP, requestIDFA);
		
		//> set testing devices
        if(testingAds == true)
		{	
			//> from here: https://stackoverflow.com/questions/24760150/how-to-get-a-hashed-device-id-for-testing-admob-on-ios
			NSString *UDIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
			const char *cStr = [UDIDString UTF8String];
			unsigned char digest[16];
			CC_MD5( cStr, strlen(cStr), digest );

			NSMutableString *deviceId = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

			for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
				[deviceId appendFormat:@"%02x", digest[i]];
			//<
			
			NSLog(@"Test device %@, %@", UDIDString, deviceId);
			
			GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[deviceId];
        }
		//<
		
		//> set COPPA
		if(childDirected == true)
		{
			//NSLog(@"Init child");
			[GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:YES];
		}
		//<
		
		//> set CCPA
		if(enableRDP == true)
		{
			//NSLog(@"Init RDP");
			[NSUserDefaults.standardUserDefaults setBool:YES forKey:@"gad_rdp"];
		}
		//<

		//> iOS14+ perosnalized ads dialog
		if(requestIDFA == true)
		{
			if(@available(iOS 14, *))
			{
				//NSLog(@"Requesting IDFA");
				
				[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status)
				{
					switch(status)
					{
					  case ATTrackingManagerAuthorizationStatusAuthorized:
						//NSLog(@"IDFA authorized!");
						statusIDFA = @(IDFA_AUTORIZED);
						break;
					  case ATTrackingManagerAuthorizationStatusDenied:
						//NSLog(@"IDFA denied!");
						statusIDFA = @(IDFA_DENIED);
						break;
					  case ATTrackingManagerAuthorizationStatusNotDetermined:
						//NSLog(@"IDFA not determined!");
						statusIDFA = @(IDFA_NOT_DETERMINED);
						break;
					  case ATTrackingManagerAuthorizationStatusRestricted:
						//NSLog(@"IDFA restricted!");
						statusIDFA = @(IDFA_RESTRICTED);
						break;
					}
					
					[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
					{
						//onStatus(INIT_OK, [statusIDFA UTF8String]); //it's crasing here...
					}];
				}];
				
				//onStatus(INIT_OK, [statusIDFA UTF8String]); //hope it's always ok
				
				return;
			}
			else
			{
				//onStatus(IDFA_NOT_SUPPORTED, nil);
				statusIDFA = @(IDFA_NOT_SUPPORTED);
			}
		}
		//<

		[[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status)
		{
			onStatus(INIT_OK, [statusIDFA UTF8String]); //hope it's always ok
		}];
    }

    void showBanner(const char *ID, int size, int align)
	{
		if(_bannerListener != nil)
		{
			onStatus(BANNER_FAILED_TO_LOAD, "Hide previous banner first!");
			return;
		}
		
		NSString *SID = [NSString stringWithUTF8String:ID];
       _bannerListener = [[BannerListener alloc] showWithID:SID withSize:size withAlign:align];
    }
    
    void hideBanner()
	{
        [_bannerListener hide];
		[_bannerListener release];
		_bannerListener = nil;
    }
	
	void loadInterstitial(const char *ID)
	{
		NSString *SID = [NSString stringWithUTF8String:ID];
		_interstitialListener = [[InterstitialListener alloc] loadWithAdUnitID:SID];
	}

    void showInterstitial()
	{
		if(_interstitialListener != nil)
		{
			[_interstitialListener show];
		}
		else
		{
			onStatus(INTERSTITIAL_FAILED_TO_SHOW, "You need to load interstitial ad first!");
		}
    }
	
	void loadRewarded(const char *ID)
	{
		NSString *SID = [NSString stringWithUTF8String:ID];
		_rewardedListener = [[RewardedListener alloc] loadWithAdUnitID:SID];
	}

    void showRewarded()
	{
		if(_rewardedListener != nil)
		{
			[_rewardedListener show];
		}
		else
		{
			onStatus(REWARDED_FAILED_TO_SHOW, "You need to load rewarded ad first!");
		}
    }
	
	void setVolume(float vol)
	{
		NSLog(@"setVolume %f", vol);
		
        GADMobileAds.sharedInstance.applicationVolume = vol;
    }
}
