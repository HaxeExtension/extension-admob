#pragma once

typedef void (*AdmobCallback)(const char *event, const char *value);

void initAdmob(bool testingAds, bool childDirected, bool enableRDP, AdmobCallback callback);
void showAdmobBanner(const char *id, int size, int align);
void hideAdmobBanner();
void loadAdmobInterstitial(const char *id);
void showAdmobInterstitial();
void loadAdmobRewarded(const char *id);
void showAdmobRewarded();
void loadAdmobAppOpen(const char *id);
void showAdmobAppOpen();
bool canAdmobRequestAds();
void setAdmobVolume(float vol);
int hasAdmobConsentForPurpose(int purpose);
const char *getAdmobConsent();
bool isAdmobPrivacyOptionsRequired();
void showAdmobPrivacyOptionsForm();
