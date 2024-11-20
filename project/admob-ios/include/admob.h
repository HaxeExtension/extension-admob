#include <string>
#include <vector>

namespace admob
{	
	void init(bool testingAds, bool childDirected, bool enableRDP);
	void initMobileAds(bool testingAds, bool childDirected, bool enableRDP, bool requestIDFA);
	void showBanner(const char *id, int size, int align);
	void hideBanner();
	void loadInterstitial(const char *id);
	void showInterstitial();
	void loadRewarded(const char* id);
	void showRewarded();
	void setVolume(float vol);
	void setVolume(float vol);
	int hasConsentForPuprpose(int purpose);
	const char* getConsent();
	int isPrivacyOptionsRequired();
	void showPrivacyOptionsForm();
}
