package FusionBluetooth_Android;

class GattCallback extends android.bluetooth.BluetoothGattCallback {
  private long _ptr;
  
  public void onConnectionStateChange(android.bluetooth.BluetoothGatt gatt, int status, int newState) {
    onConnectionStateChangeImpl(_ptr ,gatt ,status ,newState);
  }
  private native void onConnectionStateChangeImpl(long _ptr, android.bluetooth.BluetoothGatt gatt, int status, int newState);
  
  public void onServicesDiscovered(android.bluetooth.BluetoothGatt gatt, int status) {
    onServicesDiscoveredImpl(_ptr ,gatt ,status);
  }
  private native void onServicesDiscoveredImpl(long _ptr, android.bluetooth.BluetoothGatt gatt, int status);
  
  public void onCharacteristicWrite(android.bluetooth.BluetoothGatt gatt, android.bluetooth.BluetoothGattCharacteristic characteristic, int status) {
    onCharacteristicWriteImpl(_ptr ,gatt ,characteristic ,status);
  }
  private native void onCharacteristicWriteImpl(long _ptr, android.bluetooth.BluetoothGatt gatt, android.bluetooth.BluetoothGattCharacteristic characteristic, int status);
  
  public void onCharacteristicRead(android.bluetooth.BluetoothGatt gatt, android.bluetooth.BluetoothGattCharacteristic characteristic, int status) {
    onCharacteristicReadImpl(_ptr ,gatt ,characteristic ,status);
  }
  private native void onCharacteristicReadImpl(long _ptr, android.bluetooth.BluetoothGatt gatt, android.bluetooth.BluetoothGattCharacteristic characteristic, int status);
  
  public void onCharacteristicChanged(android.bluetooth.BluetoothGatt gatt, android.bluetooth.BluetoothGattCharacteristic characteristic) {
    onCharacteristicChangedImpl(_ptr ,gatt ,characteristic);
  }
  private native void onCharacteristicChangedImpl(long _ptr, android.bluetooth.BluetoothGatt gatt, android.bluetooth.BluetoothGattCharacteristic characteristic);
  
}