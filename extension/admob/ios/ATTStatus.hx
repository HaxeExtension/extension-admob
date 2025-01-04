package extension.admob.ios;

//https://stackoverflow.com/questions/63499520/app-tracking-transparency-how-does-effect-apps-showing-ads-idfa-ios14/63522856#63522856
enum abstract ATTStatus(String) from String to String
{
	final NOT_DETERMINED = 'NOT_DETERMINED';
	final RESTRICTED = 'RESTRICTED';
	final DENIED = 'DENIED';
	final AUTHORIZED = 'AUTHORIZED';
	final UNKNOWN = 'UNKNOWN';
}
