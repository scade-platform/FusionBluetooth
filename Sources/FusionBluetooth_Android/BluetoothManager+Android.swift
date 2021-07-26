import Java
import Android
import AndroidOS
import AndroidApp
import AndroidContent
import AndroidBluetooth

import FusionBluetooth_Common

public class BluetoothManager {
	typealias BluetoothAdapter = AndroidBluetooth.BluetoothAdapter
	typealias BluetoothDevice = AndroidBluetooth.BluetoothDevice

	private var currentActivity: Activity? { Application.currentActivity }
	
	private var bluetoothAdapter: BluetoothAdapter? = nil
	
	//private var bluetoothReceiver = BluetoothReceiver()	
	
	public required init() {  
		self.bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
	} 	
}

extension BluetoothManager: BluetoothManagerProtocol {

	public func requestAuthorization() {
		currentActivity?.requestPermissions(      
		permissions: [Manifest.permission.ACCESS_FINE_LOCATION], requestCode: 1111)
	}

	public func checkAuthorization() -> Bool {
		guard
			let status = currentActivity?.checkSelfPermission(
			permission: Manifest.permission.ACCESS_FINE_LOCATION),

			status == PackageManagerStatic.PERMISSION_GRANTED
		else {  
			return false
		}

		return true
	}
	
    public func isScanning() -> Bool {
    	if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isDiscovering()
    	} else {
    		return false
    	}
    }
    
	public func checkState(receiver: @escaping (Bool) -> Void) {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		receiver(true)
    	} else {
    		receiver(false)
    	}		
	}
	
	public func discoverDevice(receiver: @escaping (Peripheral?) -> Void) {
		guard checkAuthorization() else {
			receiver(nil)
			return
		}
        	
		 if let apdater = self.bluetoothAdapter, let activity = self.currentActivity {
		 	apdater.startDiscovery()
		 	activity.registerReceiver(receiver: BluetoothReceiver.shared, filter: IntentFilter(action: BluetoothDevice.ACTION_FOUND))
		 	BluetoothReceiver.shared.receiver = receiver
    	} else {
    		receiver(nil)
    	}
	}
	
	public func stopDiscovering() {
		
	}
	
	public func connectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
		
	}
	
	public func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
		
	}
	
	public func receiveMessage(message: @escaping (String) -> Void) {
		
	}
	
    public func sendMessage(message: String) {
    	
    }
}

public class BluetoothReceiver: Object, BroadcastReceiver {
	static let shared = BluetoothReceiver()
	var receiver: ((Peripheral?) -> Void)?
	
	public func onReceive(context: Context?, intent: Intent?) {

		guard let action = intent?.getAction() else { return }
		if action == BluetoothDevice.ACTION_FOUND,
			let device: BluetoothDevice? = intent?.getParcelableExtra(name: BluetoothDevice.EXTRA_DEVICE),
			let deviceHardwareAddress = device?.getAddress() {
				
            let deviceName = device?.getName()            
            
            let peripheral = Peripheral(name: deviceName, uuid: deviceHardwareAddress, isConnected: false)
            receiver?(peripheral)
		}
    }
    
}

