package extension.admob;

enum abstract AdmobBannerSize(Int) from Int to Int
{
	final BANNER = 0; //320x50
	final FULL_BANNER = 2; //468x60
	final LARGE_BANNER = 3; //320x100
	final LEADERBOARD = 4; //728x90
	final MEDIUM_RECTANGLE = 5; //300x250
#if android
	final FLUID = 1; //Android only. A dynamically sized banner that matches its parent's width and expands/contracts its height to match the ad's content after loading completes.
	final WIDE_SKYSCRAPER = 6; //160x600, Android only.
#end
}
