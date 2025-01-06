package extension.admob;

enum abstract AdmobBannerSize(Int) from Int to Int
{
	final ADAPTIVE = 0; //Anchored adaptive, (a replacement for SMART_BANNER), banner width is fullscreen, height calculated acordingly (might not work well in landscape orientation)
	final BANNER = 1; //320x50
	final FULL_BANNER = 2; //468x60
	final LARGE_BANNER = 3; //320x100
	final LEADERBOARD = 4; //728x90
	final MEDIUM_RECTANGLE = 5; //300x250
	final FLUID = 6; //A dynamically sized banner that matches its parent's width and expands/contracts its height to match the ad's content after loading completes.
	//final WIDE_SKYSCRAPER = 7; //mediation only, not currently supportred by Google Mobile Ads network: https://developers.google.com/android/reference/com/google/android/gms/ads/AdSize#public-static-final-adsize-wide_skyscraper
}
