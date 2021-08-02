package FusionBluetooth_Android;

public class BluetoothReceiver extends android.content.BroadcastReceiver {
  private long _ptr;
  
  public void onReceive(android.content.Context context, android.content.Intent intent) {
  	System.out.print("BluetoothReceiver: onReceive")  
    onReceiveImpl(_ptr ,context ,intent);
  }
  private native void onReceiveImpl(long _ptr, android.content.Context context, android.content.Intent intent);
  
}
