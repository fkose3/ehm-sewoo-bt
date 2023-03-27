import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'ehm-sewoo-bt' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const EhmSewooBt = NativeModules.EhmSewooBt
  ? NativeModules.EhmSewooBt
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function connect(): Promise<boolean> {
  return EhmSewooBt.connect();
}

export function disconnect(): Promise<boolean> {
  return EhmSewooBt.disconnect();
}

export function print(zpl: string): Promise<boolean> {
  return EhmSewooBt.print(zpl);
}
