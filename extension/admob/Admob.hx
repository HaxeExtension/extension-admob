package extension.admob;

#if android
typedef Admob = extension.admob.android.AdmobAndroid;
#elseif ios
typedef Admob = extension.admob.ios.AdmobIOS;
#end
