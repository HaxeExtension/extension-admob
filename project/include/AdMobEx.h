#ifndef ADMOBEX_H
#define ADMOBEX_H


namespace admobex {
	
	
	void init(const char *BannerID, const char *InterstitialID, const char *gravityMode, bool testingAds, bool tagForChildDirectedTreatment);
	void showBanner();
	void hideBanner();
	void refreshBanner();
	bool showInterstitial();
	
}


#endif