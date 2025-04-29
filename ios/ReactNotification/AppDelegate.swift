import UIKit
import React
import AEPCore
import AEPCampaignClassic
import React_RCTAppDelegate
import ReactAppDependencyProvider

@main
class AppDelegate: RCTAppDelegate, UNUserNotificationCenterDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    MobileCore.initialize(appId: "3149c49c3910/0f12baf27522/launch-c219c0fa9543")
    
    MobileCore.setPrivacyStatus(.optedIn)
    MobileCore.setLogLevel(.debug)
    
    // Set the delegate BEFORE requesting authorization
    UNUserNotificationCenter.current().delegate = self
    
    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        } else {
            print("Push notifications permission denied")
        }
    }

    // Add debug print to verify delegate is set
    print("Notification Delegate Set:", UNUserNotificationCenter.current().delegate != nil)
    
    self.moduleName = "ReactNotification"
    self.dependencyProvider = RCTAppDependencyProvider()

    // You can add your custom initial props in the dictionary below.
    // They will be passed down to the ViewController used by React Native.
    self.initialProps = [:]

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
  }

  
  // Handle notifications when the app is in the foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      print("willPresent called for notification:", notification.request.content.title)
      PushNotificationManager.sharedInstance?.handleNotificationReceived(notification)
      completionHandler([.alert, .sound, .badge])
  }
  
//  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
//    print("Here")
//    return UIBackgroundFetchResult.newData
//  }
  
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("Here")
    completionHandler(.newData)
  }

  
  // Handle notification when user taps on it
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      print("didReceive called for notification:", response.notification.request.content.title)
      PushNotificationManager.sharedInstance?.handleNotificationTapped(response.notification)
      completionHandler()
  }

  // Called when the app successfully registers for remote notifications
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      // Convert the device token to a string (hex format)
      let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
      print("Device Token: \(tokenString)")
//    CampaignClassic.registerDevice(token: deviceToken, userKey: "akhil-ios", additionalParameters: nil)
      // Send device token to React Native
      PushNotificationManager.sharedInstance?.sendDeviceTokenToReactNative(tokenString)
  }

  // Called when registration for remote notifications fails
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register for remote notifications: \(error.localizedDescription)")
  }

  
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    self.bundleURL()
  }

  override func bundleURL() -> URL? {
#if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
