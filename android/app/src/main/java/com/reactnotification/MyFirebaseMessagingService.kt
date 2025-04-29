package com.reactnotification

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    companion object {
        private const val TAG = "MyFirebaseMessaging"
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "New token: $token")
        // You can send this token to your React Native app
        sendTokenToReactNative(token)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d(TAG, "From: ${remoteMessage.from}")
    }

    private fun sendTokenToReactNative(token: String) {
        val reactContext = applicationContext as? MainApplication
        reactContext?.let {
            it.reactNativeHost
                .reactInstanceManager
                .currentReactContext
                ?.getJSModule(com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                ?.emit("onDeviceTokenReceived", token)
        }
    }
} 