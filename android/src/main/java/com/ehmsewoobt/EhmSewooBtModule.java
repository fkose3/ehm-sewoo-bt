package com.ehmsewoobt;

import android.bluetooth.BluetoothDevice;
import android.content.*;
import android.os.AsyncTask;
import android.widget.ArrayAdapter;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.facebook.react.bridge.*;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.sewoo.jpos.printer.ZPLPrinter;
import com.sewoo.port.android.WiFiPort;
import com.sewoo.request.android.RequestHandler;
import com.sewoo.jpos.request.RequestQueue;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

@ReactModule(name = EhmSewooBtModule.NAME)
public class EhmSewooBtModule extends ReactContextBaseJavaModule {
  public static final String NAME = "EhmSewooBt";
  private final ReactApplicationContext reactContext;

  private WiFiPort wifiPort;
  private Thread wfThread;
  private BroadcastReceiver connectDevice;
  private ExecuteDisconnectWF BTdiscon;
  private ZPLPrinter zplPrinter;
  ArrayAdapter<String> adapter;
  boolean searchflags;
  private boolean disconnectflags;

  public EhmSewooBtModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;

    adapter = new ArrayAdapter<String>(this.reactContext, android.R.layout.simple_list_item_1);
    searchflags = false;
    disconnectflags = false;
    this.Init_WifiSet();
    zplPrinter = new ZPLPrinter();
  }

  public void Init_WifiSet()
  {

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
            if(wifiPort.isConnected())
              wifiPort.disconnect();
          } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
          } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
          }

          if((wfThread != null) && (wfThread.isAlive()))
          {
            wfThread.interrupt();
            wfThread = null;
          }

          ConnectionFailedDevice();

          //Toast.makeText(getApplicationContext(), "BlueTooth Disconnect", Toast.LENGTH_SHORT).show();
        }
      }
    };

   }

  public void ConnectionFailedDevice()
  {

  }

  @NonNull
  @NotNull
  @Override
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void PrintZpl(String zpl) throws UnsupportedEncodingException {
    RequestQueue.getInstance().addRequest(zpl.getBytes());
  }

  @ReactMethod
  private void ConnectDevice(String deviceAddr, Promise promise)
  {
    try {
      wifiConn(deviceAddr);
      promise.resolve(true);
    } catch (IOException e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  private void Disconnect()
  {
    ExcuteDisconnect();
  }

  private void sendEvent(
                         String eventName,
                         @Nullable WritableMap params) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, params);
  }

  private void wifiConn(String ipAddr) throws IOException
  {
    new connWF().execute(ipAddr);
  }

  class connWF extends AsyncTask<String, Void, Integer>
  {

    @Override
    protected void onPreExecute()
    {

      sendEvent("connecting", null);
      super.onPreExecute();
    }

    @Override
    protected Integer doInBackground(String... params)
    {
      Integer retVal = null;
      try
      {	// ip
        wifiPort.connect(params[0]);
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
      if(result.intValue() == 0)	//Connection success.
      {
        RequestHandler rh = new RequestHandler();
        wfThread = new Thread(rh);
        wfThread.start();

        sendEvent("connected", null);
      }
      else	//Connection failed.
      {
        //TODO:  disconnect
      }

      super.onPostExecute(result);
    }
  }


  public void DisconnectDevice()
  {
    try {
      if(wifiPort.isConnected())
        wifiPort.disconnect();

      if((wfThread != null) && (wfThread.isAlive()))
      {
        wfThread.interrupt();
        wfThread = null;
      }

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
    BTdiscon = new ExecuteDisconnectWF();
    BTdiscon.execute();
  }
  private class ExecuteDisconnectWF extends AsyncTask<Void, Void, Void>{


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
      if(wifiPort.isConnected())
        wifiPort.disconnect();

      if((wfThread != null) && (wfThread.isAlive()))
      {
        wfThread.interrupt();
        wfThread = null;
      }

    } catch (IOException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    } catch (InterruptedException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
  }

  @Override
  public void initialize()
  {

  }

}
