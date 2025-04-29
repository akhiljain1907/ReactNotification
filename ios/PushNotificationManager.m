//
//  PushNotificationManager.m
//  ReactNotification
//
//  Created by Akhil Jain on 28/01/25.
//

#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(PushNotificationManager, RCTEventEmitter)

RCT_EXTERN_METHOD(scheduleLocalNotification)

@end

