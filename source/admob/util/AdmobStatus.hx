package admob.util;

import openfl.events.EventDispatcher;

/**
 * Admob status
 * @author Pozirk Games (http://www.pozirk.com)
 */
class AdmobStatus extends EventDispatcher
{
	public function onStatus(status:String, data:String = null):Void
	{
		//trace("onStatus: ", status, data);
		var ae:AdmobEvent = new AdmobEvent(status, data);
		this.dispatchEvent(ae);
	}
}