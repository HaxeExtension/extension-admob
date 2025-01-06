package extension.admob;

//https://support.google.com/admob/answer/9760862#consent-policies
//https://iabeurope.eu/iab-europe-transparency-consent-framework-policies/#A_Purposes
enum abstract AdmobConsent(String) from String to String
{
	final FULL = "11111111111"; //full consent has been granted, admob should have no problems showing ads
	final ZERO = "00000000000"; //user did not consent
	final PERSONALIZED = "11110010110"; //enough consent has been granted for personalized ads, most likely will never happen, because user has to set all the checkboxes manually
	final NON_PERSONALIZED = "11000010110"; //consent to show non-personalized ads was given, there is a small chance that this can happen, because user has to set all the right checkboxes manually
}
