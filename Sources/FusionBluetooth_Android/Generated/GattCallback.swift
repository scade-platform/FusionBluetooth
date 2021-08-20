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

#endif