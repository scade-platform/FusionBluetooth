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

	var bluetoothAdapter: BluetoothAdapter? = nil
	private var currentActivity: Activity? { Application.currentActivity }
	private var connectThread: ConnectThread?
	
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
	
    public func isDiscovering() -> Bool {
    	if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isDiscovering()
    	} else {
    		return false
    	}
    }
    
	public func isCentralPoweredOn() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isEnabled()
    	} else {
    		return false
    	}		
	}
	
	public func startDiscovering(receiver: @escaping (Peripheral?) -> Void) {
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
    	print("Pavlo connectDevice uuid = \(uuid) deviceArray count = \(BluetoothReceiver.shared.deviceArray.count)")        if let device = BluetoothReceiver.shared.deviceArray.first(where: { "\($0.getAddress())" == uuid }) {			connectThread = ConnectThread(manager: self)
			connectThread?.connect(device: device, receiver: receiver)        } else {            receiver(nil)        }            }
	
	public func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
    	print("Pavlo disconnectDevice uuid = \(uuid) deviceArray count = \(BluetoothReceiver.shared.deviceArray.count)")	
		if let device = BluetoothReceiver.shared.deviceArray.first(where: { "\($0.getAddress())" == uuid }), let connectThread = self.connectThread {
			connectThread.disconnect(device: device, receiver: receiver)
		} else {
			receiver(nil)
		}
	}
	
	public func receiveMessage(message: @escaping (String) -> Void) {
		
	}
	
    public func sendMessage(message: String) {
    	
    }
}

public class BluetoothReceiver: Object, BroadcastReceiver {
	static let shared = BluetoothReceiver()
	var receiver: ((Peripheral?) -> Void)?
	var deviceArray: [BluetoothDevice] = []
		
    public func onReceive(context: Context?, intent: Intent?) {        guard let action = intent?.getAction() else { return }        if action == BluetoothDevice.ACTION_FOUND,            let device: BluetoothDevice = intent?.getParcelableExtra(name: BluetoothDevice.EXTRA_DEVICE) {            let deviceHardwareAddress = device.getAddress()            let deviceName = device.getName()            var isConnected = false            if BluetoothDevice.ACTION_ACL_CONNECTED == action {                isConnected = true            }                        if !self.deviceArray.contains(device) {                self.deviceArray.append(device)                let peripheral = Peripheral(name: deviceName, uuid: deviceHardwareAddress, isConnected: isConnected)
                print("Pavlo OnReceive = deviceName = \(deviceName), uuid = \(deviceHardwareAddress), isConnected = \(isConnected)")                receiver?(peripheral)            }        }    }
}

private class ConnectThread {    typealias BluetoothSocket = AndroidBluetooth.BluetoothSocket    var manager: BluetoothManager?    var socket: BluetoothSocket?    var connectedDevice: BluetoothDevice?    var thrd: Thread? = nil
            public init(manager: BluetoothManager) {        
        self.manager = manager
    }        private func run(device: BluetoothDevice, receiver: ((Peripheral?) -> Void)?) {
    	guard let socket = socket else {
    		receiver?(nil) 
    		return 
    	}
    	
    	print("Pavlo run thread device uuid = \(device.getAddress())")
		manager?.bluetoothAdapter?.cancelDiscovery()
             socket.connect()
        
        if socket.isConnected() {
        	print("Pavlo run thread connected device uuid = \(device.getAddress())")
        	self.connectedDevice = device
        	let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: true)
        	receiver?(peripheral)
        } else {
        	print("Pavlo run thread failed connected device uuid = \(device.getAddress())")
        	receiver?(nil)
        	socket.close()
        	self.thrd?.cancel()
        }
    }
    
    func connect(device: BluetoothDevice, receiver: ((Peripheral?) -> Void)?) {
        let uuid = UUID.fromString(name: device.getAddress())        self.socket = device.createRfcommSocketToServiceRecord(uuid: uuid)
            
    	self.thrd = Thread(block: { [weak self] in self!.run(device: device, receiver: receiver) })
    	print("Pavlo connect uuid = \(uuid)")        self.thrd?.start()
    }
    
    func disconnect(device: BluetoothDevice, receiver: ((Peripheral?) -> Void)?) {
        print("Pavlo disconnect uuid = \(device.getAddress()) isConnected = \(socket?.isConnected())")
    	guard let socket = socket, let connectedDevice = self.connectedDevice, connectedDevice.getAddress() == device.getAddress(), socket.isConnected() else {
    		receiver?(nil) 
    		return 
    	}
    	
        let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: false)
        receiver?(peripheral)
        
    	socket.close()
    	self.thrd?.cancel()
    }}