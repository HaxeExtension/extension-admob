package com.applovin.mediation;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.applovin.adview.AppLovinIncentivizedInterstitial;
import com.applovin.sdk.AppLovinAd;
import com.applovin.sdk.AppLovinAdClickListener;
import com.applovin.sdk.AppLovinAdDisplayListener;
import com.applovin.sdk.AppLovinAdLoadListener;
import com.applovin.sdk.AppLovinAdRewardListener;
import com.applovin.sdk.AppLovinAdVideoPlaybackListener;
import com.applovin.sdk.AppLovinErrorCodes;
import com.applovin.sdk.AppLovinSdk;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.mediation.MediationAdRequest;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.mediation.MediationRewardedVideoAdAdapter;
import com.google.android.gms.ads.reward.mediation.MediationRewardedVideoAdListener;

import java.util.Map;

public class ApplovinAdapter implements
        MediationRewardedVideoAdAdapter,
        AppLovinAdClickListener,
        AppLovinAdDisplayListener,
        AppLovinAdLoadListener,
        AppLovinAdRewardListener,
        AppLovinAdVideoPlaybackListener {

    private class ApplovinReward implements RewardItem {
        private final String mType;
        private final int mAmount;

        public ApplovinReward(String type, int amount) {
            mType = type;
            mAmount = amount;
        }

        @Override
        public int getAmount() {
            return mAmount;
        }


        @Override
        public String getType() {
            return mType;
        }
    }

    private MediationRewardedVideoAdListener mMediationRewardedVideoAdListener;
    private AppLovinIncentivizedInterstitial mIncent;
    private boolean mInitialized;
    private Activity mActivity;
    private static final boolean loggingEnabled = false;
    private ApplovinReward reward;

    @Override
    public void onDestroy() {

    }

    @Override
    public void onPause() {

    }

    @Override
    public void onResume() {

    }

    @Override
    public void initialize(Context context,
                           MediationAdRequest adRequest,
                           String userId,
                           MediationRewardedVideoAdListener listener,
                           Bundle serverParameters,
                           Bundle networkExtras) {
        mActivity = (Activity) context;
        mMediationRewardedVideoAdListener = listener;

        if (!mInitialized) {
            ALLog("Initializing AppLovin SDK for rewarded video.");
            mIncent = AppLovinIncentivizedInterstitial.create(AppLovinSdk.getInstance(context));
            mInitialized = true;
            mMediationRewardedVideoAdListener.onInitializationSucceeded(this);
        }
    }

    @Override
    public void videoPlaybackBegan(AppLovinAd ad) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Rewarded video playback began.");
            mMediationRewardedVideoAdListener.onVideoStarted(this);
        }
    }

    @Override
    public void videoPlaybackEnded(AppLovinAd ad, double percentViewed, boolean fullyWatched) {
        ALLog("Rewarded video playback ended.");
        if (fullyWatched && reward != null) {
            ALLog("Granting reward for user.");
            mMediationRewardedVideoAdListener.onRewarded(this, reward);
        }

    }

    @Override
    public void userRewardVerified(AppLovinAd ad, Map arg1) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Reward validation successful.");
            final String currencyName = (String) arg1.get("currency");
            final double coinsEarned = Double.parseDouble((String) arg1.get("amount"));
            reward = new ApplovinReward(currencyName, (int) coinsEarned);
        }
    }

    @Override
    public void adReceived(AppLovinAd ad) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Rewarded video loaded.");
            mMediationRewardedVideoAdListener.onAdLoaded(this);
        }
    }

    @Override
    public void failedToReceiveAd(int errorCode) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Rewarded video failed to load: " + errorCode);
            errorCode = errorCode == AppLovinErrorCodes.NO_FILL ?
                    AdRequest.ERROR_CODE_NO_FILL : AdRequest.ERROR_CODE_NETWORK_ERROR;
            mMediationRewardedVideoAdListener.onAdFailedToLoad(this, errorCode);
        }
    }

    @Override
    public void adDisplayed(AppLovinAd ad) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Rewarded video displayed.");
            mMediationRewardedVideoAdListener.onAdOpened(this);
        }
    }

    @Override
    public void adHidden(AppLovinAd ad) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Rewarded video hidden.");
            mMediationRewardedVideoAdListener.onAdClosed(this);
        }
    }

    @Override
    public void adClicked(AppLovinAd ad) {
        if (mMediationRewardedVideoAdListener != null) {
            ALLog("Rewarded video clicked.");
            mMediationRewardedVideoAdListener.onAdClicked(this);
            mMediationRewardedVideoAdListener.onAdLeftApplication(this);
        }
    }

    @Override
    public void userDeclinedToViewAd(AppLovinAd ad) {
        ALLog("User declined to view video.");
    }

    @Override
    public void userOverQuota(AppLovinAd ad, Map arg1) {
        ALLog("User over quota.");
    }

    @Override
    public void userRewardRejected(AppLovinAd ad, Map arg1) {
        ALLog("User reward rejected by AppLovin servers.");
    }

    @Override
    public void validationRequestFailed(AppLovinAd ad, int arg1) {
        ALLog("User could not be validated due to network issue or closed ad early.");
    }

    @Override
    public boolean isInitialized() {
        return mInitialized;
    }

    @Override
    public void loadAd(MediationAdRequest adRequest, Bundle serverParameters, Bundle networkExtras) {
        if (mMediationRewardedVideoAdListener != null) {
            reward = null;
            ALLog("Loading rewarded video.");
            mIncent.preload(this);
        }
    }

    @Override
    public void showVideo() {
        if (mIncent.isAdReadyToDisplay()) {
            ALLog("Showing rewarded video.");
            mIncent.show(mActivity, this, this, this, this);
        }
    }

    private void ALLog(String logMessage) {
        if (loggingEnabled) {
            Log.d("AppLovinAdapter", logMessage);
        }
    }

}