package org.haxe.extension;

import android.os.Bundle;
import com.applovin.sdk.AppLovinSdk;

public class ApplovinEx extends Extension {
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		AppLovinSdk.initializeSdk(Extension.mainContext);
	}
}