package FusionBluetooth_Android;

class LeScanCallback extends android.bluetooth.le.ScanCallback {
  private long _ptr;
  
  public void onScanResult(int callbackType, android.bluetooth.le.ScanResult result) {
    onScanResultImpl(_ptr ,callbackType ,result);
  }
  private native void onScanResultImpl(long _ptr, int callbackType, android.bluetooth.le.ScanResult result);
  
}