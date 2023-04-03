package com.ehmsewoobt;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.content.*;
import android.os.AsyncTask;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import com.facebook.react.bridge.*;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.sewoo.jpos.command.ZPLConst;
import com.sewoo.jpos.printer.ZPLPrinter;
import com.sewoo.jpos.request.RequestQueue;
import com.sewoo.port.android.BluetoothPort;
import com.sewoo.request.android.RequestHandler;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Iterator;
import java.util.Vector;

@ReactModule(name = EhmSewooBtModule.NAME)
public class EhmSewooBtModule extends ReactContextBaseJavaModule {
  public static final String NAME = "EhmSewooBt";
  private final ReactApplicationContext reactContext;

  private static final int REQUEST_ENABLE_BT = 2;
  private static final int BT_PRINTER = 1536;

  private BroadcastReceiver discoveryResult;
  private BroadcastReceiver searchFinish;
  private BroadcastReceiver searchStart;
  private BroadcastReceiver connectDevice;

  private Vector<BluetoothDevice> remoteDevices;
  private BluetoothDevice btDev;
  private BluetoothAdapter mBluetoothAdapter;
  private BluetoothPort bluetoothPort;
  private CheckTypesTask BTtask;
  private ExcuteDisconnectBT BTdiscon;
  private ZPLPrinter zplPrinter;
  ArrayAdapter<String> adapter;
  private Thread btThread;
  boolean searchflags;
  private boolean disconnectflags;

  public EhmSewooBtModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;

    adapter = new ArrayAdapter<String>(this.reactContext, android.R.layout.simple_list_item_1);
    searchflags = false;
    disconnectflags = false;
    this.Init_BluetoothSet();
    bluetoothPort = BluetoothPort.getInstance();
    bluetoothPort.SetMacFilter(false);   //not using mac address filtering

    addPairedDevices();
    zplPrinter = new ZPLPrinter();
  }

  public void Init_BluetoothSet()
  {
    bluetoothSetup();

    connectDevice = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if(BluetoothDevice.ACTION_ACL_CONNECTED.equals(action))
        {
          //Toast.makeText(getApplicationContext(), "BlueTooth Connect", Toast.LENGTH_SHORT).show();
        }
        else if(BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action))
        {
          try {
            if(bluetoothPort.isConnected())
              bluetoothPort.disconnect();
          } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
          } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
          }

          if((btThread != null) && (btThread.isAlive()))
          {
            btThread.interrupt();
            btThread = null;
          }

          ConnectionFailedDevice();

          //Toast.makeText(getApplicationContext(), "BlueTooth Disconnect", Toast.LENGTH_SHORT).show();
        }
      }
    };

    discoveryResult = new BroadcastReceiver()
    {
      @Override
      public void onReceive(Context context, Intent intent)
      {
        String key;
        boolean bFlag = true;
        BluetoothDevice btDev;
        BluetoothDevice remoteDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

        if(remoteDevice != null)
        {
          int devNum = remoteDevice.getBluetoothClass().getMajorDeviceClass();

          if(devNum != BT_PRINTER)
            return;

          if(remoteDevice.getBondState() != BluetoothDevice.BOND_BONDED)
          {
            key = remoteDevice.getName() +"\n["+remoteDevice.getAddress()+"]";
          }
          else
          {
            key = remoteDevice.getName() +"\n["+remoteDevice.getAddress()+"] [Paired]";
          }
          if(bluetoothPort.isValidAddress(remoteDevice.getAddress()))
          {
            for(int i = 0; i < remoteDevices.size(); i++)
            {
              btDev = remoteDevices.elementAt(i);
              if(remoteDevice.getAddress().equals(btDev.getAddress()))
              {
                bFlag = false;
                break;
              }
            }
            if(bFlag)
            {
              remoteDevices.add(remoteDevice);
              adapter.add(key);
            }
          }
        }
      }
    };

    this.reactContext.registerReceiver(discoveryResult, new IntentFilter(BluetoothDevice.ACTION_FOUND));

    searchStart = new BroadcastReceiver()
    {
      @Override
      public void onReceive(Context context, Intent intent)
      {
        //Toast.makeText(mainView, "블루투스 기기 검색 시작", Toast.LENGTH_SHORT).show();
      }
    };
    this.reactContext.registerReceiver(searchStart, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED));

    searchFinish = new BroadcastReceiver()
    {
      @Override
      public void onReceive(Context context, Intent intent)
      {
        searchflags = true;
      }
    };
    this.reactContext.registerReceiver(searchFinish, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED));
  }

  public void ConnectionFailedDevice()
  {

  }

  private void bluetoothSetup()
  {
    // Initialize
    clearBtDevData();

    mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (mBluetoothAdapter == null)
    {
      // Device does not support Bluetooth
      return;
    }
    if (!mBluetoothAdapter.isEnabled())
    {
      Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);

      this.getCurrentActivity().startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
    }
  }

  private void clearBtDevData()
  {
    remoteDevices = new Vector<BluetoothDevice>();
  }

  @NonNull
  @NotNull
  @Override
  public String getName() {
    return NAME;
  }


  @ReactMethod
  public void DiscoverDevices()
  {
      BTtask = new CheckTypesTask();
      BTtask.execute();
  }

  @ReactMethod
  public void PrintZpl(String zpl) throws UnsupportedEncodingException
  {
    RequestQueue.getInstance().addRequest(zpl.getBytes());
  }

  @ReactMethod
  public void StopDiscover()
  {
    searchflags = true;
    mBluetoothAdapter.cancelDiscovery();
  }

  @ReactMethod
  private void ConnectDevice(String deviceAddr, Promise promise)
  {
    try {
      btConn(mBluetoothAdapter.getRemoteDevice(deviceAddr));
      promise.resolve(true);
    } catch (IOException e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  private void GetDevices(Promise promise)
  {
    WritableArray app_list = new WritableNativeArray();
    for (BluetoothDevice bt : remoteDevices) {
      BluetoothClass bluetoothClass = bt.getBluetoothClass(); // get class of bluetooth device
      WritableMap info = new WritableNativeMap();
      info.putString("address", bt.getAddress());
      info.putDouble("class", bluetoothClass.getDeviceClass()); // 1664
      info.putString("name", bt.getName());
      info.putString("type", "paired");
      app_list.pushMap(info);
    }

    promise.resolve(app_list);
  }
  @ReactMethod
  private void Disconnect()
  {
    ExcuteDisconnect();
  }

  private void addPairedDevices()
  {
    BluetoothDevice pairedDevice;
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

          key = pairedDevice.getName() +"\n["+pairedDevice.getAddress()+"] [Paired]";
          adapter.add(key);
        }
      }
    }
  }


  private void sendEvent(
                         String eventName,
                         @Nullable WritableMap params) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, params);
  }

  private class CheckTypesTask extends AsyncTask<Void, Void, Void> {

    @Override
    protected void onPreExecute(){
      sendEvent("Searching_Start", null);

      SearchingBTDevice();
      super.onPreExecute();
    };

    @Override
    protected Void doInBackground(Void... params) {
      // TODO Auto-generated method stub
      try {
        while(true)
        {
          if(searchflags)
            break;

          Thread.sleep(100);
        }
      } catch (InterruptedException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
      return null;
    }

    @Override
    protected void onPostExecute(Void result){
      sendEvent("Searching_Stop", null);

      searchflags = false;
      super.onPostExecute(result);
    };
  }

  private void SearchingBTDevice()
  {
    adapter.clear();
    adapter.notifyDataSetChanged();

    clearBtDevData();
    mBluetoothAdapter.startDiscovery();
  }

  private void btConn(final BluetoothDevice btDev) throws IOException
  {
    new connBT().execute(btDev);
  }

  class connBT extends AsyncTask<BluetoothDevice, Void, Integer>
  {
    String str_temp = "";

    @Override
    protected void onPreExecute()
    {
      sendEvent("connecting", null);
      super.onPreExecute();
    }

    @Override
    protected Integer doInBackground(BluetoothDevice... params)
    {
      Integer retVal = null;

      try
      {
        bluetoothPort.connect(params[0]);
        str_temp = params[0].getAddress();

        retVal = Integer.valueOf(0);
      }
      catch (IOException e)
      {
        e.printStackTrace();
        retVal = Integer.valueOf(-1);
      }

      return retVal;
    }

    @Override
    protected void onPostExecute(Integer result)
    {

      if(result.intValue() == 0)	// Connection success.
      {
        RequestHandler rh = new RequestHandler();
        btThread = new Thread(rh);
        btThread.start();


        reactContext.registerReceiver(connectDevice, new IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED));
        reactContext.registerReceiver(connectDevice, new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED));

        sendEvent("connected", null);
      }
      else	// Connection failed.
      {
        sendEvent("connection_failed", null);
      }
      super.onPostExecute(result);
    }
  }

  public void DisconnectDevice()
  {
    try {
      bluetoothPort.disconnect();

      this.reactContext.unregisterReceiver(connectDevice);

      if((btThread != null) && (btThread.isAlive()))
        btThread.interrupt();

      disconnectflags = true;

    } catch (IOException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    } catch (InterruptedException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
  }

  public void ExcuteDisconnect()
  {
    BTdiscon = new ExcuteDisconnectBT();
    BTdiscon.execute();
  }

  private class ExcuteDisconnectBT extends AsyncTask<Void, Void, Void>{

    @Override
    protected void onPreExecute(){
      sendEvent("disconnecting", null);
      super.onPreExecute();
    };

    @Override
    protected Void doInBackground(Void... params) {
      // TODO Auto-generated method stub
      try {
        DisconnectDevice();

        while(true)
        {
          if(disconnectflags)
            break;

          Thread.sleep(100);
        }
      } catch (InterruptedException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
      return null;
    }

    @Override
    protected void onPostExecute(Void result){
      sendEvent("disconnected", null);
      disconnectflags = false;
      super.onPostExecute(result);
    };
  }

  @Override
  public void onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy();
    try {

      if(bluetoothPort.isConnected())
      {
        bluetoothPort.disconnect();
        this.reactContext.unregisterReceiver(connectDevice);
      }

    } catch (IOException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    } catch (InterruptedException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }

    if((btThread != null) && (btThread.isAlive()))
    {
      btThread.interrupt();
      btThread = null;
    }

    this.reactContext.unregisterReceiver(searchFinish);
    this.reactContext.unregisterReceiver(searchStart);
    this.reactContext.unregisterReceiver(discoveryResult);
  }

  @Override
  public void initialize()
  {

  }

}
