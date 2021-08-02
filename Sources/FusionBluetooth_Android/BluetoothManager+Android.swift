import Java
import Android
import AndroidOS
import AndroidApp
import AndroidContent
import AndroidBluetooth

import FusionBluetooth_Common
import Foundation

public class BluetoothManager {
	typealias BluetoothAdapter = AndroidBluetooth.BluetoothAdapter
	typealias BluetoothDevice = AndroidBluetooth.BluetoothDevice

	private var currentActivity: Activity? { Application.currentActivity }	
	private var bluetoothAdapter: BluetoothAdapter? = nil

	
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
    		receiver(bluetoothApdater.isEnabled())
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
		 	if apdater.startDiscovery() {
		 		let filter = IntentFilter()
		 		filter.addAction(action: BluetoothDevice.ACTION_FOUND)
		 		filter.addAction(action: BluetoothDevice.ACTION_ACL_CONNECTED)
		 		filter.addAction(action: BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED)
		 		filter.addAction(action: BluetoothDevice.ACTION_ACL_DISCONNECTED)
		 		
		 		activity.registerReceiver(receiver: BluetoothReceiver.shared, filter: filter)
		 		BluetoothReceiver.shared.receiver = receiver
		 	} else {
		 		receiver(nil)
		 	}
		 	
    	} else {
    		receiver(nil)
    	}
	}
	
	public func stopDiscovering() {
		self.bluetoothAdapter?.cancelDiscovery()
	}
	
	public func connectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
		let conThread = ConnectThread()
		
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
			let device: BluetoothDevice = intent?.getParcelableExtra(name: BluetoothDevice.EXTRA_DEVICE) {
			let deviceHardwareAddress = device.getAddress()	
            let deviceName = device.getName()
            var isConnected = false
            if BluetoothDevice.ACTION_ACL_CONNECTED == action {
            	isConnected = true
	        }
            
            let peripheral = Peripheral(name: deviceName, uuid: deviceHardwareAddress, isConnected: isConnected)
            receiver?(peripheral)
		}
    }    
}

//public class ConnectThread: Java.Thread {
//	typealias BluetoothSocket = BluetoothSocket
//	typealias BluetoothDevice = AndroidBluetooth.BluetoothDevice
//	var socket: BluetoothSocket?
//	var device: BluetoothDevice?
//
//	public init(device: BluetoothDevice, uuidString: String) {
//		let uuid = UUID(uuidString: uuidString)
//		self.socket = device.createRfcommSocketToServiceRecord(uuid: uuid)       
//  	}
//  	
//  	public func run() {
//  		//self.bluetoothAdapter.cancelDiscovery()
//		self.socket.connect()
//   }
//
//   public func cancel() {
//       self.socket.close()
//   }
//}

class ConnectThread {
	typealias BluetoothSocket = AndroidBluetooth.BluetoothSocket

	var socket: BluetoothSocket?
	var device: BluetoothDevice?
    var thrd: Thread? = nil
    
    public init(device: BluetoothDevice, uuidString: String) {
        let uuid = UUID.fromString(name: uuidString)
        self.socket = device.createRfcommSocketToServiceRecord(uuid: uuid) 
        
        self.thrd = Thread(block: { [weak self] in self!.run() })
        self.thrd!.start()
    }
    
    private func run() {
	    self.socket?.connect()
    }
}

