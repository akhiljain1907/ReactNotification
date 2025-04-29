import React, { useEffect, useState } from 'react';
import { View, Text, Button, NativeModules, NativeEventEmitter, StyleSheet } from 'react-native';
import { CampaignClassic } from "@adobe/react-native-aepcampaignclassic";
import {
  MobileCore,
  Lifecycle,
  Signal,
  Event,
  Identity,
  LogLevel,
  PrivacyStatus,
} from '@adobe/react-native-aepcore';

const App = (): React.JSX.Element => {
  const [deviceToken, setDeviceToken] = useState<string | null>(null);
  const [notificationData, setNotificationData] = useState<any>(null);
  const [tappedNotificationData, setTappedNotificationData] = useState<any>(null);
  const [notificationTapped, setNotificationTapped] = useState<boolean>(false);

  useEffect(() => {
    console.log('NativeModules:', NativeModules);

    const { PushNotificationManager } = NativeModules;
    if (!PushNotificationManager) {
      console.error('PushNotificationManager is undefined!');
      return;
    }

    // iOS event emitter
    const iosEmitter = new NativeEventEmitter(PushNotificationManager);
    const tokenSubscription = iosEmitter.addListener('onDeviceTokenReceived', (data) => {
      console.log('Received Device Token:', data.deviceToken);
      setDeviceToken(data.deviceToken);
      console.log('Registered device api is  called with token:', data.deviceToken);
      CampaignClassic.registerDeviceWithToken(data.deviceToken, 'akhiljain@adobe.com');
    });

    const notificationSubscription = iosEmitter.addListener('onNotificationReceived', (data) => {
      console.log('Notification Received Event:', data);
      if (!notificationTapped) {
        setNotificationData(data);
      }
    });

    const tapSubscription = iosEmitter.addListener('onNotificationTapped', (data) => {
      console.log('Notification Tapped Event:', data);
      setNotificationTapped(true);
      setTappedNotificationData(data);
    });

    return () => {
      tokenSubscription.remove();
      notificationSubscription.remove();
      tapSubscription.remove();
    };
  }, []);

  const scheduleNotification = () => {
    const { PushNotificationManager } = NativeModules;
    if (PushNotificationManager) {
      PushNotificationManager.scheduleLocalNotification();
    } else {
      console.error('PushNotificationManager is undefined!');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.tokenText}>
        {deviceToken ? `Device Token:\n${deviceToken}` : 'Waiting for device token...'}
      </Text>
      {notificationData && (
        <Text style={styles.notificationText}>
          {`Notification Received: ${JSON.stringify(notificationData)}`}
        </Text>
      )}
      {tappedNotificationData && (
        <Text style={[styles.notificationText, styles.tappedText]}>
          {`Notification Tapped: ${JSON.stringify(tappedNotificationData)}`}
        </Text>
      )}
      <Button title="Schedule Notification" onPress={scheduleNotification} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
    paddingHorizontal: 20,
  },
  tokenText: {
    fontSize: 16,
    color: 'black',
    textAlign: 'center',
    marginBottom: 20,
  },
  notificationText: {
    fontSize: 14,
    color: 'blue',
    textAlign: 'center',
    marginBottom: 20,
  },
  tappedText: {
    color: 'green',
    marginTop: 10,
  },
});

export default App;
