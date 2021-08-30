#if os(Android)

import Java
import Android
import AndroidOS
import AndroidApp
import AndroidContent
import AndroidBluetooth

@_silgen_name("Java_FusionBluetooth_1Android_GattCallback_onConnectionStateChangeImpl")
public func GattCallback_onConnectionStateChangeImpl(env: UnsafeMutablePointer<JNIEnv>, obj: JavaObject?, ptr: JavaLong, gatt: JavaObject?, status: JavaInt, newState: JavaInt) -> Void {
  let _obj = unsafeBitCast(Int(truncatingIfNeeded:ptr), to: GattCallback.self)
  
  let _gatt = BluetoothGatt?.fromJavaObject(gatt)
  let _status = status
  let _newState = newState
  
  _obj.onConnectionStateChange(gatt: _gatt, status: _status, newState: _newState)
}
@_silgen_name("Java_FusionBluetooth_1Android_GattCallback_onServicesDiscoveredImpl")
public func GattCallback_onServicesDiscoveredImpl(env: UnsafeMutablePointer<JNIEnv>, obj: JavaObject?, ptr: JavaLong, gatt: JavaObject?, status: JavaInt) -> Void {
  let _obj = unsafeBitCast(Int(truncatingIfNeeded:ptr), to: GattCallback.self)
  
  let _gatt = BluetoothGatt?.fromJavaObject(gatt)
  let _status = status
  
  _obj.onServicesDiscovered(gatt: _gatt, status: _status)
}
@_silgen_name("Java_FusionBluetooth_1Android_GattCallback_onCharacteristicWriteImpl")
public func GattCallback_onCharacteristicWriteImpl(env: UnsafeMutablePointer<JNIEnv>, obj: JavaObject?, ptr: JavaLong, gatt: JavaObject?, characteristic: JavaObject?, status: JavaInt) -> Void {
  let _obj = unsafeBitCast(Int(truncatingIfNeeded:ptr), to: GattCallback.self)
  
  let _gatt = BluetoothGatt?.fromJavaObject(gatt)
  let _characteristic = BluetoothGattCharacteristic?.fromJavaObject(characteristic)
  let _status = status
  
  _obj.onCharacteristicWrite(gatt: _gatt, characteristic: _characteristic, status: _status)
}
@_silgen_name("Java_FusionBluetooth_1Android_GattCallback_onCharacteristicReadImpl")
public func GattCallback_onCharacteristicReadImpl(env: UnsafeMutablePointer<JNIEnv>, obj: JavaObject?, ptr: JavaLong, gatt: JavaObject?, characteristic: JavaObject?, status: JavaInt) -> Void {
  let _obj = unsafeBitCast(Int(truncatingIfNeeded:ptr), to: GattCallback.self)
  
  let _gatt = BluetoothGatt?.fromJavaObject(gatt)
  let _characteristic = BluetoothGattCharacteristic?.fromJavaObject(characteristic)
  let _status = status
  
  _obj.onCharacteristicRead(gatt: _gatt, characteristic: _characteristic, status: _status)
}
@_silgen_name("Java_FusionBluetooth_1Android_GattCallback_onCharacteristicChangedImpl")
public func GattCallback_onCharacteristicChangedImpl(env: UnsafeMutablePointer<JNIEnv>, obj: JavaObject?, ptr: JavaLong, gatt: JavaObject?, characteristic: JavaObject?) -> Void {
  let _obj = unsafeBitCast(Int(truncatingIfNeeded:ptr), to: GattCallback.self)
  
  let _gatt = BluetoothGatt?.fromJavaObject(gatt)
  let _characteristic = BluetoothGattCharacteristic?.fromJavaObject(characteristic)
  
  _obj.onCharacteristicChanged(gatt: _gatt, characteristic: _characteristic)
}

#endif