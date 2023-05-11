import {
  NativeModules,
  DeviceEventEmitter,
  EmitterSubscription,
} from 'react-native';

export type Device = {
  address: string;
  class: number;
  name: string;
  type: string;
};

type EhmSewooBtType = {
  DiscoverDevices(): void;
  PrintZpl(zpl: string): void;
  StopDiscover(): void;
  ConnectDevice(deviceAddr: string): Promise<boolean>;
  GetDevices(): Promise<Device[]>;
  Disconnect(): void;
};

const EhmSewooBt = NativeModules.EhmSewooBt as EhmSewooBtType;

export default EhmSewooBt;

export type SewooListenerTypes =
  | 'Searching_Start'
  | 'Searching_Stop'
  | 'connecting'
  | 'connected'
  | 'connection_failed'
  | 'disconnecting'
  | 'disconnected'
  | 'battery'
  | 'paperEmpty'
  | 'coverOpen';
export const addListener = (
  listenerType: SewooListenerTypes,
  callback: () => void
) => {
  switch (listenerType) {
    case 'Searching_Start':
      return addSearchingStartListener(callback);
    case 'Searching_Stop':
      return addSearchingStopListener(callback);
    case 'connected':
      return addConnectedListener(callback);
    case 'connecting':
      return addConnectingListener(callback);
    case 'connection_failed':
      return addConnectionFailedListener(callback);
    case 'disconnected':
      return addDisconnectedListener(callback);
    case 'disconnecting':
      return addDisconnectingListener(callback);
    case 'paperEmpty':
      return addPaperEmptyListener(callback);
    case 'coverOpen':
      return addCoverOpenListener(callback);
    case 'battery':
      return addBatteryLowListener(callback);
  }
};

const addSearchingStartListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('Searching_Start', callback);
};

const addSearchingStopListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('Searching_Stop', callback);
};

const addConnectingListener = (callback: () => void): EmitterSubscription => {
  return DeviceEventEmitter.addListener('connecting', callback);
};

const addConnectedListener = (callback: () => void): EmitterSubscription => {
  return DeviceEventEmitter.addListener('connected', callback);
};

const addConnectionFailedListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('connection_failed', callback);
};

const addDisconnectingListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('disconnecting', callback);
};

const addDisconnectedListener = (callback: () => void): EmitterSubscription => {
  return DeviceEventEmitter.addListener('disconnected', callback);
};

const addPaperEmptyListener = (callback: () => void): EmitterSubscription => {
  return DeviceEventEmitter.addListener('paperEmpty', callback);
};

const addBatteryLowListener = (callback: () => void): EmitterSubscription => {
  return DeviceEventEmitter.addListener('battery', callback);
};

const addCoverOpenListener = (callback: () => void): EmitterSubscription => {
  return DeviceEventEmitter.addListener('coverOpen', callback);
};
