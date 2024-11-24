package admob;

enum abstract AdmobConsent(String) from String to String
{
	final FULL = '1111111111';
	final PERSONALIZED = '1111001011';
	final NON_PERSONALIZED = '1100001011';
}
