package extension.admob.ios;

enum abstract ATTStatus(String) from String to String
{
	final NOT_DETERMINED = 'NOT_DETERMINED';
	final RESTRICTED = 'RESTRICTED';
	final DENIED = 'DENIED';
	final AUTHORIZED = 'AUTHORIZED';
	final UNKNOWN = 'UNKNOWN';
}
