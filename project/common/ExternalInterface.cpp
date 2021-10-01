#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>

#include <string>
#include <vector>

#include <AdMobEx.h>

using namespace admobex;

AutoGCRoot* eventHandle = NULL;

static value admobex_init(value testingAds, value childDirected, value enableRDP, value requestIDFA, value onStatus)
{
	eventHandle = new AutoGCRoot(onStatus);

	init(val_bool(testingAds), val_bool(childDirected), val_bool(enableRDP), val_bool(requestIDFA));

	return alloc_null();
}
DEFINE_PRIM(admobex_init, 5);

static value admobex_banner_show(value id, value size, value align)
{
	showBanner(val_string(id), val_int(size), val_int(align));
	return alloc_null();
}
DEFINE_PRIM(admobex_banner_show, 3);

static value admobex_banner_hide()
{
	hideBanner();
	return alloc_null();
}
DEFINE_PRIM(admobex_banner_hide, 0);

static value admobex_interstitial_load(value id)
{
	loadInterstitial(val_string(id));
	return alloc_null();
}
DEFINE_PRIM(admobex_interstitial_load, 1);

static value admobex_interstitial_show()
{
	showInterstitial();
	return alloc_null();
}
DEFINE_PRIM(admobex_interstitial_show, 0);

static value admobex_rewarded_load(value id)
{
	loadRewarded(val_string(id));
	return alloc_null();
}
DEFINE_PRIM(admobex_rewarded_load, 1);

static value admobex_rewarded_show()
{
	showRewarded();
	return alloc_null();
}
DEFINE_PRIM(admobex_rewarded_show, 0);

static value admobex_set_volume(value vol)
{
	setVolume(val_float(vol));
	return alloc_null();
}
DEFINE_PRIM(admobex_set_volume,1);

extern "C" int admobex_register_prims () { return 0; }

extern "C" void admobex_main()
{
	val_int(0); // Fix Neko init
}
DEFINE_ENTRY_POINT(admobex_main);

extern "C" void onStatus(const char* code, const char* data)
{
	if(data == NULL)
		val_call1(eventHandle->get(), alloc_string(code));
	else
    	val_call2(eventHandle->get(), alloc_string(code), alloc_string(data));
}