package extension.admob;

//constants are taken from https://developer.android.com/reference/android/view/Gravity
//you can use your own value for Android, if need more flexibility
enum abstract AdmobBannerAlign(Int) from Int to Int
{
#if android
	final BOTTOM = 0x00000050 | 0x00000001; // BOTTOM | CENTER_HORIZONTAL
	final TOP = 0x00000030 | 0x00000001; // TOP | CENTER_HORIZONTAL
#elseif ios
	final BOTTOM = 0;
	final TOP = 1;
#end
}
