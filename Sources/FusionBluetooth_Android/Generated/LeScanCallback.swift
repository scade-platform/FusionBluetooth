#if os(Android)

import Java
import Android
import AndroidOS
import AndroidApp
import AndroidContent
import AndroidBluetooth

@_silgen_name("Java_FusionBluetooth_1Android_LeScanCallback_onScanResultImpl")
public func LeScanCallback_onScanResultImpl(env: UnsafeMutablePointer<JNIEnv>, obj: JavaObject?, ptr: JavaLong, callbackType: JavaInt, result: JavaObject?) -> Void {
  let _obj = unsafeBitCast(Int(truncatingIfNeeded:ptr), to: LeScanCallback.self)
  
  let _callbackType = callbackType
  let _result = ScanResult?.fromJavaObject(result)
  
  _obj.onScanResult(callbackType: _callbackType, result: _result)
}

#endif