#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "AdMobEx.h"

using namespace admobex;


static value admobex_init(value banner_id,value interstitial_id, value gravity_mode, value testing_ads){
	init(val_string(banner_id),val_string(interstitial_id), val_string(gravity_mode), val_bool(testing_ads));
	return alloc_null();
}
DEFINE_PRIM(admobex_init,4);

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
