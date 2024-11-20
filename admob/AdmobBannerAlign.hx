package admob;

#if android
/**
 * @see https://developer.android.com/reference/android/view/Gravity
 */
enum abstract AdmobBannerAlign(Int) from Int to Int
{
	final BOTTOM = 0x00000050 | 0x00000001; // BOTTOM | CENTER_HORIZONTAL
	final TOP = 0x00000030 | 0x00000001; // TOP | CENTER_HORIZONTAL
}
#elseif ios
enum abstract AdmobBannerAlign(Int) from Int to Int
{
	final BOTTOM = 0;
	final TOP = 1;
}
#end
