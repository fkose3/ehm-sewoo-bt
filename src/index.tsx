import {
  NativeModules,
  DeviceEventEmitter,
  EmitterSubscription,
} from 'react-native';

type Device = {
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

export const addSearchingStartListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('Searching_Start', callback);
};

export const addSearchingStopListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('Searching_Stop', callback);
};

export const addConnectingListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('connecting', callback);
};

export const addConnectedListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('connected', callback);
};

export const addConnectionFailedListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('connection_failed', callback);
};

export const addDisconnectingListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('disconnecting', callback);
};

export const addDisconnectedListener = (
  callback: () => void
): EmitterSubscription => {
  return DeviceEventEmitter.addListener('disconnected', callback);
};
