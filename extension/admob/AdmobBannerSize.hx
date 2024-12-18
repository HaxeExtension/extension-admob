package extension.admob;

enum abstract AdmobBannerSize(Int) from Int to Int
{
	final BANNER = 0;
	final FLUID = 1;
	final FULL_BANNER = 2;
	final LARGE_BANNER = 3;
	final LEADERBOARD = 4;
	final MEDIUM_RECTANGLE = 5;
	#if android
	final WIDE_SKYSCRAPER = 6;
	#end
}
