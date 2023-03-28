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

export function multiply(a: number, b: number): Promise<number> {
  return EhmSewooBt.multiply(a, b);
}

export function connect(): Promise<boolean> {
  return EhmSewooBt.connect();
}

export function disconnect(): Promise<void> {
  return EhmSewooBt.disconnect();
}

export function print(zpl: string): Promise<void> {
  return EhmSewooBt.print(zpl);
}

export class SewooPrinter {
  static discoverDevices(): Promise<string[]> {
    return EhmSewooBt.DiscoverDevices();
  }

  static printZpl(deviceAddr: string): Promise<boolean> {
    return EhmSewooBt.PrintZpl(deviceAddr);
  }
}