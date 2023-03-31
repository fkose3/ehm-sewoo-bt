import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import {
  Button,
  FlatList,
  NativeEventEmitter,
  NativeModules,
  StyleSheet,
  Text,
  View,
  PermissionsAndroid,
} from 'react-native';
import * as SewooBt from 'ehm-sewoo-bt';

export default function App() {
  const BluetoothModule = NativeModules.EhmSewooBt;

  const [selectedDevice, setSelectedDevice] = useState('');

  useEffect(() => {});
  return (
    <View style={styles.container}>
      <Text>Open up App.tsx to start working on your app!</Text>

      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
