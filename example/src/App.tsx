import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  Button,
  FlatList,
  TouchableOpacity,
} from 'react-native';
import { SewooPrinter } from 'ehm-sewoo-bt';

export default function App() {
  const [btDevices, setDevices] = React.useState<
    { deviceAddr?: string; deviceName?: string }[]
  >([]);
  const [selectedDevice, setSelectedDevice] = React.useState('');
  const discoverDevices = async () => {
    const devices = await SewooPrinter.discoverDevices();

    const parsedDevices = devices.map((device) => {
      const splitted = device.split('\n');

      return { deviceAddr: splitted[0], deviceName: splitted[1] };
    });

    setDevices(parsedDevices);
  };

  const printZpl = async () => {
    await SewooPrinter.printZpl(selectedDevice);
  };

  console.log('burdayız');
  return (
    <View style={styles.container}>
      <View style={{ height: 30 }} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
