#pragma once

#include <string>
#include <vector>

void initAdmob(bool testingAds, bool childDirected, bool enableRDP);
void showAdmobBanner(const char *id, int size, int align);
void hideAdmobBanner();
void loadAdmobInterstitial(const char *id);
void showAdmobInterstitial();
void loadAdmobRewarded(const char *id);
void showAdmobRewarded();
void setAdmobVolume(float vol);
int hasAdmobConsentForPuprpose(int purpose);
const char *getAdmobConsent();
int isAdmobPrivacyOptionsRequired();
void showAdmobPrivacyOptionsForm();
