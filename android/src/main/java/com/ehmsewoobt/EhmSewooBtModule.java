package com.ehmsewoobt;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.facebook.react.bridge.*;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.sewoo.jpos.command.ZPLConst;
import com.sewoo.jpos.printer.ZPLPrinter;
import com.sewoo.jpos.request.RequestQueue;
import com.sewoo.port.android.BluetoothPort;
import com.sewoo.port.android.DeviceConnection;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.UUID;
import java.util.Vector;

@ReactModule(name = EhmSewooBtModule.NAME)
@SuppressLint("MissingPermission")
public class EhmSewooBtModule extends ReactContextBaseJavaModule {
  public static final String NAME = "EhmSewooBt";
  private static final int BT_PRINTER = 1536;
  private static final UUID SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

  private BluetoothAdapter bluetoothAdapter;
  private BluetoothPort bluetoothPortConnection;
  private BluetoothSocket bluetoothSocket;
  private OutputStream outputStream;
  private InputStream inputStream;
  private ArrayList<BluetoothDevice> remoteDevices = new ArrayList<>();

  private final BroadcastReceiver discoveryResult;
  private final BroadcastReceiver connectDevice;
  private final BroadcastReceiver searchStart;
  private final BroadcastReceiver searchFinish;
  private final ZPLPrinter zplPrinter;
  private final ReactApplicationContext reactContext;
  public String getName() {
    return NAME;
  }


  public EhmSewooBtModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;

    bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    bluetoothPortConnection = BluetoothPort.getInstance();
    zplPrinter = new ZPLPrinter();

    discoveryResult = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        BluetoothDevice remoteDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        if (remoteDevice != null) {
          int devNum = remoteDevice.getBluetoothClass().getMajorDeviceClass();
          if (devNum == BT_PRINTER) {
            String key;
            if (remoteDevice.getBondState() != BluetoothDevice.BOND_BONDED) {
              key = remoteDevice.getName() + "\n[" + remoteDevice.getAddress() + "]";
            } else {
              key = remoteDevice.getName() + "\n[" + remoteDevice.getAddress() + "] [Paired]";
            }
            if (bluetoothAdapter.checkBluetoothAddress(remoteDevice.getAddress())) {
              if (!remoteDevices.contains(remoteDevice)) {
                remoteDevices.add(remoteDevice);
              }
              sendBluetoothEvent("deviceFound", getDeviceInfo(remoteDevice));
            }
          }
        }
      }
    };

    connectDevice = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
          sendBluetoothEvent("connected", null);
        } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
          try {
            if (outputStream != null) {
              outputStream.close();
            }
            if (inputStream != null) {
              inputStream.close();
            }
            if (bluetoothSocket != null) {
              bluetoothSocket.close();
            }
          } catch (IOException e) {
            e.printStackTrace();
          }
          sendBluetoothEvent("disconnected", null);
        }
      }
    };

    searchStart = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        sendBluetoothEvent("searchStarted", null);
      }
    };

    searchFinish = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        sendBluetoothEvent("searchFinished", null);
      }
    };

    registerBluetoothBroadcastReceivers();
  }

  private void registerBluetoothBroadcastReceivers() {
    IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
    reactContext.registerReceiver(discoveryResult, filter);

    filter = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED);
    reactContext.registerReceiver(searchStart, filter);

    filter = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
    reactContext.registerReceiver(searchFinish, filter);

    filter = new IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED);
    reactContext.registerReceiver(connectDevice, filter);

    filter = new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED);
    reactContext.registerReceiver(connectDevice, filter);
  }

  private void unregisterBluetoothBroadcastReceivers() {
    reactContext.unregisterReceiver(discoveryResult);
    reactContext.unregisterReceiver(searchStart);
    reactContext.unregisterReceiver(searchFinish);
    reactContext.unregisterReceiver(connectDevice);
  }

  @ReactMethod
  public void findDevices() {
    remoteDevices.clear();
    if (bluetoothAdapter.isEnabled()) {
      if (bluetoothAdapter.isDiscovering()) {
        bluetoothAdapter.cancelDiscovery();
      }
      bluetoothAdapter.startDiscovery();
    }
  }

  @ReactMethod
  public void cancelDiscovery() {
    if (bluetoothAdapter.isEnabled()) {
      bluetoothAdapter.cancelDiscovery();
    }
  }

  @ReactMethod
  public void connectToDevice(String address, Promise promise) {
    BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
    try {
      bluetoothSocket = device.createRfcommSocketToServiceRecord(SPP_UUID);
      bluetoothSocket.connect();
      inputStream = bluetoothSocket.getInputStream();
      outputStream = bluetoothSocket.getOutputStream();
      bluetoothPortConnection.connect(device);
      sendBluetoothEvent("connected", null);
      promise.resolve(null);
    } catch (IOException e) {
      sendBluetoothEvent("connectionFailed", e.getMessage());
      promise.reject(e);
    }
  }

  @ReactMethod
  public void disconnectFromDevice() {
    try {
      if (outputStream != null) {
        outputStream.close();
      }
      if (inputStream != null) {
        inputStream.close();
      }
      if (bluetoothSocket != null) {
        bluetoothSocket.close();
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    sendBluetoothEvent("disconnected", null);
  }

  private WritableMap getDeviceInfo(BluetoothDevice device) {
    WritableMap deviceInfo = Arguments.createMap();
    deviceInfo.putString("name", device.getName());
    deviceInfo.putString("address", device.getAddress());
    deviceInfo.putInt("bondState", device.getBondState());
    deviceInfo.putInt("deviceClass", device.getBluetoothClass().getDeviceClass());
    deviceInfo.putInt("majorDeviceClass", device.getBluetoothClass().getMajorDeviceClass());
    return deviceInfo;
  }

  private void sendBluetoothEvent(String eventName, @Nullable Object data) {
    WritableMap params = Arguments.createMap();
    params.putString("eventName", eventName);
    if (data != null) {
      if (data instanceof WritableMap) {
        params.putMap("data", (WritableMap) data);
      } else {
        params.putString("data", data.toString());
      }
    }
    reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit("BluetoothEvent", params);
  }

  @ReactMethod
  public void PrintZpl(String deviceAddr, Promise promise) throws IOException, InterruptedException {

    zplPrinter.setupPrinter(ZPLConst.ROTATION_180, ZPLConst.SENSE_CONTINUOUS, 384, 480);

    zplPrinter.startPage();
    zplPrinter.setInternationalFont(0);


    zplPrinter.printText(ZPLConst.FONT_A, ZPLConst.ROTATION_0, 15, 12, 0, 0, "FontA 0123");
    zplPrinter.printText(ZPLConst.FONT_B, ZPLConst.ROTATION_0, 15, 12, 0, 30, "FontB 0123");
    zplPrinter.printText(ZPLConst.FONT_C, ZPLConst.ROTATION_0, 15, 12, 0, 60, "FontC 0123");
    zplPrinter.printText(ZPLConst.FONT_D, ZPLConst.ROTATION_0, 15, 12, 0, 90, "FontD 0123");
    zplPrinter.printText(ZPLConst.FONT_E, ZPLConst.ROTATION_0, 15, 12, 0, 120, "FontE 0123");
    zplPrinter.printText(ZPLConst.FONT_F, ZPLConst.ROTATION_0, 15, 12, 0, 160, "FontF 0123");
    zplPrinter.printText(ZPLConst.FONT_G, ZPLConst.ROTATION_0, 15, 12, 0, 210, "FontG 01");
    zplPrinter.printText(ZPLConst.FONT_H, ZPLConst.ROTATION_0, 15, 12, 0, 300, "FontH 01234567");

    zplPrinter.endPage(1);

    promise.resolve(true);
  }

  @Override
  public void onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy();
    unregisterBluetoothBroadcastReceivers();
  }
}
