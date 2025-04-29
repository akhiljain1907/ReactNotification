//
//  PushNotificationManager.swift
//  MyApp
//
//  Created by Akhil Jain on 28/01/25.
//

import Foundation
import React
import UserNotifications

@objc(PushNotificationManager)
class PushNotificationManager: RCTEventEmitter {
  static var sharedInstance: PushNotificationManager?

  override init() {
    super.init()
    PushNotificationManager.sharedInstance = self
  }

  override func supportedEvents() -> [String]! {
    return ["onDeviceTokenReceived", "onNotificationReceived", "onNotificationTapped"]
  }

  @objc func sendDeviceTokenToReactNative(_ token: String) {
    sendEvent(withName: "onDeviceTokenReceived", body: ["deviceToken": token])
  }

  @objc func handleNotificationReceived(_ notification: UNNotification) {
   
    print("DEBUG: handleNotificationReceived called")
    let content = notification.request.content
    let userInfo = content.userInfo
    
    let notificationData: [String: Any] = [
      "title": content.title,
      "body": content.body,
      "data": userInfo,
      "id": notification.request.identifier
    ]
    
    sendEvent(withName: "onNotificationReceived", body: notificationData)
  }

  @objc func handleNotificationTapped(_ notification: UNNotification) {
    print("DEBUG: handleNotificationTapped called")
    
    let content = notification.request.content
    let userInfo = content.userInfo
    
    let notificationData: [String: Any] = [
      "title": content.title,
      "body": content.body,
      "data": userInfo,
      "id": notification.request.identifier
    ]
    
    sendEvent(withName: "onNotificationTapped", body: notificationData)
  }

  @objc(scheduleLocalNotification)
  func scheduleLocalNotification() {
    print("Scheduling notification...")
    DispatchQueue.main.async {
      let content = UNMutableNotificationContent()
      content.title = "Scheduled Notification"
      content.body = "This notification was scheduled from React Native."
      content.sound = .default
      
      // Add category identifier if needed
      content.categoryIdentifier = "DEFAULT"

      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
      let request = UNNotificationRequest(identifier: "ScheduledNotification", content: content, trigger: trigger)

      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          print("Error scheduling local notification: \(error)")
        } else {
          print("Local notification scheduled successfully")
          
          // Verify notification center delegate
          print("Notification Center Delegate:", UNUserNotificationCenter.current().delegate as Any)
        }
      }
    }
  }

  override static func moduleName() -> String! {
    return "PushNotificationManager"
  }

  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  override func constantsToExport() -> [AnyHashable : Any]! {
    return [:]
  }
}

