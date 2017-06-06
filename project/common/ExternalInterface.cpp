#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "AdMobEx.h"

using namespace admobex;

AutoGCRoot* intestitialEventHandle = NULL;

static value admobex_init(value *args, int count){
	value on_interstitial_event = args[5];
	intestitialEventHandle = new AutoGCRoot(on_interstitial_event);

	const char* banner_id_str = val_string(args[0]);
	const char* interstitial_id_str = val_string(args[1]);
	const char* gravity_mode_str = val_string(args[2]);
	bool testing_ads = val_bool(args[3]);
	bool child_directed_treatment = val_bool(args[4]);

	init(banner_id_str, interstitial_id_str, gravity_mode_str, testing_ads, child_directed_treatment);

	return alloc_null();
}
DEFINE_PRIM_MULT(admobex_init);

static value admobex_banner_show(){
	showBanner();
	return alloc_null();
}
DEFINE_PRIM(admobex_banner_show,0);

static value admobex_banner_hide(){
	hideBanner();
	return alloc_null();
}
DEFINE_PRIM(admobex_banner_hide,0);

static value admobex_banner_refresh(){
	refreshBanner();
	return alloc_null();
}
DEFINE_PRIM(admobex_banner_refresh,0);


extern "C" void admobex_main () {	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (admobex_main);


static value admobex_interstitial_show(){
	return alloc_bool(showInterstitial());
}
DEFINE_PRIM(admobex_interstitial_show,0);



extern "C" int admobex_register_prims () { return 0; }


extern "C" void reportInterstitialEvent(const char* event)
{
	if(intestitialEventHandle == NULL) return;
//    value o = alloc_empty_object();
//    alloc_field(o,val_id("event"),alloc_string(event));
    val_call1(intestitialEventHandle->get(), alloc_string(event));
}
