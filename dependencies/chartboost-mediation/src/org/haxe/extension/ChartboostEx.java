package org.haxe.extension;

import android.os.Bundle;

import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.CBLocation;
import com.chartboost.sdk.ChartboostDelegate;

public class ChartboostEx extends Extension {
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

        Chartboost.startWithAppId(Extension.mainActivity, "::ENV_CHARTBOOST_APP_ID::", "::ENV_CHARTBOOST_APP_SIGNATURE::");
        Chartboost.onCreate(Extension.mainActivity);
	}

    public void onStart() {
        Chartboost.onStart(Extension.mainActivity);
    }

    public void onResume() {
        Chartboost.onResume(Extension.mainActivity);
    }

    public void onPause() {
        Chartboost.onPause(Extension.mainActivity);
    }

    public void onStop() {
        Chartboost.onStop(Extension.mainActivity);
    }

    public void onDestroy() {
        Chartboost.onDestroy(Extension.mainActivity);
    }

    @Override
    public boolean onBackPressed() {
        // If an interstitial is on screen, close it.
        if (Chartboost.onBackPressed())
            return true;
        else
            return super.onBackPressed();
    }
}