package extension.admob;

//https://support.google.com/admob/answer/9760862#consent-policies
//https://iabeurope.eu/iab-europe-transparency-consent-framework-policies/#A_Purposes
enum abstract AdmobConsent(String) from String to String
{
	final FULL = "11111111111"; //full consent has been granted, admob should have no problems showing ads
	final PERSONALIZED = "11110010111"; //enough consent has been granted for personalized ads, most likely will never happen, because user has to set all the checkboxes manually, and also for ads to work user has to consent to all the vendors
	final NON_PERSONALIZED = "11000010111"; //consent to show non-personalized ads was given, there are little chances this can happen, because user has to set all the right checkboxes manually, and also for ads to work user has to consent to all the vendors
}
