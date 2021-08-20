package FusionBluetooth_Android;

class GattCallback extends android.bluetooth.BluetoothGattCallback {
  private long _ptr;
  
  public void onConnectionStateChange(android.bluetooth.BluetoothGatt gatt, int status, int newState) {
    onConnectionStateChangeImpl(_ptr ,gatt ,status ,newState);
  }
  private native void onConnectionStateChangeImpl(long _ptr, android.bluetooth.BluetoothGatt gatt, int status, int newState);
  
}