package admob;

enum abstract AdmobBannerSize(Int) from Int to Int
{
	final ADAPTIVE = 0;
	final BANNER = 1;
	final FLUID = 2;
	final FULL_BANNER = 3;
	final LARGE_BANNER = 4;
	final LEADERBOARD = 5;
	final MEDIUM_RECTANGLE = 6;
	#if android
	final WIDE_SKYSCRAPER = 7;
	#end
}
