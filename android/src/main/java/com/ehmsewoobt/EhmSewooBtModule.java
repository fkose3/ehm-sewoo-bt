package com.ehmsewoobt;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import androidx.annotation.NonNull;
import com.facebook.react.bridge.*;
import com.facebook.react.module.annotations.ReactModule;
import com.sewoo.jpos.command.ZPLConst;
import com.sewoo.jpos.printer.ZPLPrinter;
import com.sewoo.jpos.request.RequestQueue;
import com.sewoo.port.android.BluetoothPort;
import com.sewoo.port.android.DeviceConnection;

import java.io.IOException;
import java.util.Iterator;
import java.util.Vector;

@ReactModule(name = EhmSewooBtModule.NAME)
public class EhmSewooBtModule extends ReactContextBaseJavaModule {
  public static final String NAME = "EhmSewooBt";
  private ZPLPrinter zplPrinter;
  // instances
  private BluetoothAdapter mBluetoothAdapter;
  private BluetoothPort bluetoothPort;
  private static final int BT_PRINTER = 1536;
  private WritableArray pairedDevicesArrayAdapter;
  private Vector<BluetoothDevice> remoteDevices;


  public EhmSewooBtModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.InitializeModule();
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  public void multiply(double a, double b, Promise promise) {
    promise.resolve(a * b);
  }

  private void InitializeModule()
  {
    bluetoothSetup();

    bluetoothPort = BluetoothPort.getInstance();
    bluetoothPort.SetMacFilter(false);   //not using mac address filtering

  }

  @SuppressLint("MissingPermission")
  @ReactMethod
  private void DiscoverDevices(Promise promise)
  {
    BluetoothDevice pairedDevice;

    clearBtDevData();
    pairedDevicesArrayAdapter = Arguments.createArray();

    Iterator<BluetoothDevice> iter = (mBluetoothAdapter.getBondedDevices()).iterator();

    String key = "";

    while(iter.hasNext())
    {
      pairedDevice = iter.next();
      if(bluetoothPort.isValidAddress(pairedDevice.getAddress()))
      {
        int deviceNum = pairedDevice.getBluetoothClass().getMajorDeviceClass();

        if(deviceNum == BT_PRINTER)
        {
          remoteDevices.add(pairedDevice);

          key = pairedDevice.getName() + "\n" + pairedDevice.getAddress();

          pairedDevicesArrayAdapter.pushString(key);
        }
      }
    }

    promise.resolve(pairedDevicesArrayAdapter);
  }

  @SuppressLint("MissingPermission")
  private void bluetoothSetup()
  {
    mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (mBluetoothAdapter == null)
    {
      // Device does not support Bluetooth
      return;
    }
    if (!mBluetoothAdapter.isEnabled())
    {
      mBluetoothAdapter.enable();
    }
  }

  private void clearBtDevData()
  {
    remoteDevices = new Vector<BluetoothDevice>();
  }

  @ReactMethod
  public void PrintZpl(String deviceAddr, Promise promise) throws IOException, InterruptedException {
    BluetoothDevice btDevice = mBluetoothAdapter.getRemoteDevice(deviceAddr);
    if(btDevice == null)
      return;

    bluetoothPort.connect(deviceAddr);

    zplPrinter = new ZPLPrinter();
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

    bluetoothPort.disconnect();

    promise.resolve(true);
  }
}
