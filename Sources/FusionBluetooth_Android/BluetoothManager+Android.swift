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

	var bluetoothAdapter: BluetoothAdapter?
	var bluetoothLeScanner: BluetoothLeScanner?	
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
   
	public func isAuthorized() -> Bool {
		guard
			let status = currentActivity?.checkSelfPermission(
			permission: Manifest.permission.ACCESS_FINE_LOCATION),

			status == PackageManagerStatic.PERMISSION_GRANTED
		else {  
			return false
		}

		return true
	}
	
    public func isSupporting() -> Bool {
    	return self.bluetoothAdapter != nil
    }
    	
    public func isDiscovering() -> Bool {
    	if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isDiscovering()
    	} else {
    		return false
    	}
    }
    
	public func isEnabled() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isEnabled()
    	} else {
    		return false
    	}		
	}
	
	public func startDiscovering(receiver: @escaping (Peripheral?) -> Void) {
		guard isAuthorized() else {
			receiver(nil)
			return
		}
        	
        if let adapter = self.bluetoothAdapter, let bluetoothLeScanner = adapter.getBluetoothLeScanner() {
            self.bluetoothLeScanner = bluetoothLeScanner
            bluetoothLeScanner.startScan(callback: LeScanCallback.shared)
            LeScanCallback.shared.receiver = receiver
    	} else {
    		receiver(nil)
    	}
	}
	
	public func stopDiscovering() {
		let _ = self.bluetoothAdapter?.cancelDiscovery()
	}
	
    public func connectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
        if let device = BluetoothReceiver.shared.deviceArray.first(where: { "\($0.getAddress())" == uuid }) {
			connectThread = ConnectThread(manager: self)
			connectThread?.connect(device: device, receiver: receiver)
        } else {
            receiver(nil)
        }        
    }
	
	public func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
		if let device = BluetoothReceiver.shared.deviceArray.first(where: { "\($0.getAddress())" == uuid }), let connectThread = self.connectThread {
			connectThread.disconnect(device: device, receiver: receiver)
		} else {
			receiver(nil)
		}
	}
	
    public func enableBluetooth() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.enable()
    	} else {
    		return false
    	}
    }
    
    public func disableBluetooth() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.disable()
    	} else {
    		return false
    	}
    }    
    	
	public func readCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
		
	}
	
	public func notifyCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
	
	}
    public func writeCharacteristic(uuid: String, data: Data) {
    	
    }
    
    public func listenToStateEvents(receiver: @escaping (DeviceState) -> Void) {
    }    
}

public class LeScanCallback: Object, ScanCallback {
	static let shared = LeScanCallback()
	var receiver: ((Peripheral?) -> Void)?
	var deviceArray: [BluetoothDevice] = []
	
	public func onScanResult(callbackType: Int32, result: ScanResult?) {
		guard let result = result, let device = result.getDevice() else { return }
        let deviceHardwareAddress = device.getAddress()
        let deviceName = device.getName()
        
        if !self.deviceArray.contains(device) {
            self.deviceArray.append(device)
            let peripheral = Peripheral(name: deviceName, uuid: deviceHardwareAddress, isConnected: false)

            receiver?(peripheral)
        }
	}
}

public class BluetoothReceiver: Object, BroadcastReceiver {
	static let shared = BluetoothReceiver()
	var receiver: ((Peripheral?) -> Void)?
	var deviceArray: [BluetoothDevice] = []
		
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
            
            if !self.deviceArray.contains(device) {
                self.deviceArray.append(device)
                let peripheral = Peripheral(name: deviceName, uuid: deviceHardwareAddress, isConnected: isConnected)

                receiver?(peripheral)
            }
        }
    }
}

private class ConnectThread {
    typealias BluetoothSocket = AndroidBluetooth.BluetoothSocket

    var manager: BluetoothManager?
    var socket: BluetoothSocket?
    var connectedDevice: BluetoothDevice?
    var thrd: Thread? = nil
        
	let MY_UUID = "00001101-0000-1000-8000-00805F9B34FB"
	
    public init(manager: BluetoothManager) {
        self.manager = manager
    }
    
    private func run(device: BluetoothDevice, receiver: ((Peripheral?) -> Void)?) {
    	var myUuid = UUID.fromString(name: MY_UUID)
    	let gotUuids = device.fetchUuidsWithSdp()

    	if gotUuids, device.getUuids().count > 0, let parcelUuid = device.getUuids()[0], let uuid = parcelUuid.getUuid() {
			myUuid = uuid
    	}
    	
    	guard let socket = device.createInsecureRfcommSocketToServiceRecord(uuid: myUuid) else {
    		receiver?(nil) 
    		return     		
    	}
    	self.socket = socket
		let _ = manager?.bluetoothAdapter?.cancelDiscovery()

        socket.connect()
        
        if socket.isConnected() {
        	self.connectedDevice = device
        	let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: true)
        	receiver?(peripheral)
        } else {
        	receiver?(nil)
        	socket.close()
        	self.thrd?.cancel()
        }
    }
    
    func connect(device: BluetoothDevice, receiver: ((Peripheral?) -> Void)?) {            
    	self.thrd = Thread(block: { [weak self] in self!.run(device: device, receiver: receiver) })

        self.thrd?.start()
    }
    
    func disconnect(device: BluetoothDevice, receiver: ((Peripheral?) -> Void)?) {
    	guard let socket = socket, let connectedDevice = self.connectedDevice, connectedDevice.getAddress() == device.getAddress(), socket.isConnected() else {
    		receiver?(nil) 
    		return 
    	}
    	
        let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: false)
        receiver?(peripheral)
        
    	socket.close()
    	self.thrd?.cancel()
    }
}