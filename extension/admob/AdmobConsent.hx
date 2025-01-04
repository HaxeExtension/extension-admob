package extension.admob;

enum abstract AdmobConsent(String) from String to String
{
	final FULL = "11111111111";
	final PERSONALIZED = "11110010111";
	final NON_PERSONALIZED = "11000010111";
}
