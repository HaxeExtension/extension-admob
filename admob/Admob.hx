package admob;

#if android
typedef Admob = admob.android.AdmobAndroid;
#elseif ios
typedef Admob = admob.ios.AdmobIOS;
#end
