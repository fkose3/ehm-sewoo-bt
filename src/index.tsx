import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'ehm-sewoo-bt' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const BluetoothModule = NativeModules.EhmSewooBt
  ? NativeModules.EhmSewooBt
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const BluetoothEventEmitter = new NativeEventEmitter(NativeModules.EhmSewooBt);

export type EventNames =
  | 'connected'
  | 'disconnected'
  | 'searchStarted'
  | 'searchFinished'
  | 'connectionFailed'
  | 'deviceFound';

export type SewooDeviceInfo = {
  name?: string;
  address?: string;
  bondState?: number;
  deviceClass?: number;
  majorDeviceClass?: number;
  message?: string;
};

export type BluetoothEvent = {
  eventName: EventNames;
  data?: {
    name?: string;
    address?: string;
    bondState?: number;
    deviceClass?: number;
    majorDeviceClass?: number;
    message?: string;
  };
};

type BluetoothDevice = {
  name?: string;
  address?: string;
  bondState?: number;
  deviceClass?: number;
  majorDeviceClass?: number;
};

type BluetoothModuleType = {
  findDevices(): void;
  cancelDiscovery(): void;
  connectToDevice(address: string): Promise<void>;
  disconnectFromDevice(): void;
  printText(text: string): Promise<void>;
  printImage(imagePath: string): Promise<void>;
  getConnectedDevice(): Promise<BluetoothDevice | null>;
  addListener(eventType: 'connected', listener: () => void): void;
  addListener(eventType: 'disconnected', listener: () => void): void;
  addListener(eventType: 'searchStarted', listener: () => void): void;
  addListener(eventType: 'searchFinished', listener: () => void): void;
  addListener(eventType: 'deviceFound', listener: () => void): void;
  addListener(
    eventType: 'connectionFailed',
    listener: (message: string) => void
  ): void;
  removeListeners(): void;
};

export default class SewooPrinter {
  private eventSubscriptions: any[];

  constructor() {
    this.eventSubscriptions = [];

    BluetoothEventEmitter.addListener(
      'BluetoothEvent',
      (event: BluetoothEvent) => {
        switch (event.eventName) {
          case 'connected':
            this.emit('connected');
            break;
          case 'disconnected':
            this.emit('disconnected');
            break;
          case 'searchStarted':
            this.emit('searchStarted');
            break;
          case 'searchFinished':
            this.emit('searchFinished');
            break;
          case 'connectionFailed':
            this.emit('connectionFailed', event.data?.message);
            break;
        }
      }
    );
  }

  private emit(eventType: string, arg?: any) {
    this.eventSubscriptions.forEach((eventSubscription) => {
      if (eventSubscription.eventType === eventType) {
        eventSubscription.listener(arg);
      }
    });
  }

  addListener(eventType: string, listener: any) {
    this.eventSubscriptions.push({ eventType, listener });
  }

  removeListeners() {
    this.eventSubscriptions = [];
  }

  findDevices() {
    BluetoothModule.findDevices();
  }

  cancelDiscovery() {
    BluetoothModule.cancelDiscovery();
  }

  connectToDevice(address: string) {
    return BluetoothModule.connectToDevice(address);
  }

  disconnectFromDevice() {
    BluetoothModule.disconnectFromDevice();
  }

  printZpl(deviceAddr: string): Promise<boolean> {
    return BluetoothModule.PrintZpl(deviceAddr);
  }

  async getConnectedDevice(): Promise<BluetoothDevice | null> {
    const deviceInfo = await BluetoothModule.getConnectedDevice();
    if (deviceInfo) {
      return {
        name: deviceInfo.name,
        address: deviceInfo.address,
        bondState: deviceInfo.bondState,
        deviceClass: deviceInfo.deviceClass,
        majorDeviceClass: deviceInfo.majorDeviceClass,
      };
    }
    return null;
  }
}
