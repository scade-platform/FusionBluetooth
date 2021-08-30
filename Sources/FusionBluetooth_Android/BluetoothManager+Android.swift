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
	var bluetoothGatt: BluetoothGatt?
		
	private var currentActivity: Activity? { Application.currentActivity }
	
	public required init() {  
		self.bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
	} 	
}

extension BluetoothManager: BluetoothManagerProtocol {
	public func startDiscovering(receiver: @escaping (Peripheral?, BMError?) -> Void) {
	    guard isAuthorized() else {
	    	requestAuthorization()
	     	receiver(nil, .unauthorized)
	     	return 
	    }
        guard isSupporting() else { receiver(nil, .unsupported); return }
        guard isEnabled() else { receiver(nil, .notEnabled); return }
        guard !isDiscovering() else { receiver(nil, .discovering); return }

        	
        if let adapter = self.bluetoothAdapter, let bluetoothLeScanner = adapter.getBluetoothLeScanner() {
            self.bluetoothLeScanner = bluetoothLeScanner
            bluetoothLeScanner.startScan(callback: LeScanCallback.shared)
            LeScanCallback.shared.receiver = receiver
    	} else {
    		receiver(nil, .unsupported)
    	}
	}
	
	public func stopDiscovering() {
		let _ = self.bluetoothAdapter?.cancelDiscovery()
		if let bluetoothLeScanner = self.bluetoothLeScanner {
			bluetoothLeScanner.stopScan(callback: LeScanCallback.shared)
		}
	}
	
    public func connectDevice(uuid: String, receiver: @escaping (Peripheral?, BMError?) -> Void) {
		if let bluetoothAdapter = bluetoothAdapter, let device = bluetoothAdapter.getRemoteDevice(address: uuid) {
            if let bluetoothGatt = self.bluetoothGatt {
                bluetoothGatt.close()
                self.bluetoothGatt = nil
            }

            GattCallback.shared.connectReceiver = receiver
            GattCallback.shared.device = device            
            self.bluetoothGatt = device.connectGatt(context: nil, autoConnect: false, callback: GattCallback.shared)
        } else {
            receiver(nil, .notFound)
        }
    }
	
	public func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?, BMError?) -> Void) {
		if let bluetoothGatt = self.bluetoothGatt {
			bluetoothGatt.close()
			self.bluetoothGatt = nil
		}
		
		receiver(nil, .notFound)		
	}

    	
	public func readCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
        if let bluetoothGatt = self.bluetoothGatt {
            GattCallback.shared.readCharacteristicReceiver = receiver
            GattCallback.shared.requestReadCharacteristics(gatt: bluetoothGatt)
        } else {
            receiver(nil)
        }
	}
	
	public func notifyCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
		if let bluetoothGatt = self.bluetoothGatt {
			GattCallback.shared.notifyCharacteristicReceiver = receiver
			GattCallback.shared.requestNotifyCharacteristics(gatt: bluetoothGatt)
		} else {
			receiver(nil)
		}		
	}
    public func writeCharacteristic(uuid: String, data: Data) {
		if let bluetoothGatt = self.bluetoothGatt {
			GattCallback.shared.writeData = data
			GattCallback.shared.requestWriteCharacteristics(gatt: bluetoothGatt)
		}
    } 
}


extension BluetoothManager {
	func requestAuthorization() {
		currentActivity?.requestPermissions(      
		permissions: [Manifest.permission.ACCESS_FINE_LOCATION], requestCode: 1111)
	}
   
	func isAuthorized() -> Bool {
		guard
			let status = currentActivity?.checkSelfPermission(
			permission: Manifest.permission.ACCESS_FINE_LOCATION),

			status == PackageManagerStatic.PERMISSION_GRANTED
		else {  
			return false
		}

		return true
	}
	
    func isSupporting() -> Bool {
    	return self.bluetoothAdapter != nil
    }
    	
    func isDiscovering() -> Bool {
    	if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isDiscovering()
    	} else {
    		return false
    	}
    }
    
	func isEnabled() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.isEnabled()
    	} else {
    		return false
    	}		
	}
	
	
    func enableBluetooth() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.enable()
    	} else {
    		return false
    	}
    }
    
    func disableBluetooth() -> Bool {
	    if let bluetoothApdater = self.bluetoothAdapter {
    		return bluetoothApdater.disable()
    	} else {
    		return false
    	}
    }	
}

public class GattCallback: Object, BluetoothGattCallback {
	static let shared = GattCallback()
	var connectReceiver: ((Peripheral?, BMError?) -> Void)?
	
	typealias DataReceiver = (Data?) -> Void	
  	var readCharacteristicReceiver: DataReceiver?
  	var notifyCharacteristicReceiver: DataReceiver?
  	var writeCharacteristicReceiver: ((Bool) -> Void)?	
  	
	var device: BluetoothDevice?
	var writeData: Data?
	
	var readChars: [BluetoothGattCharacteristic] = []
	var notifyChars: [BluetoothGattCharacteristic] = []
	var writeChars: [BluetoothGattCharacteristic] = []		
	
    public func onConnectionStateChange(gatt: BluetoothGatt?, status: Int32, newState: Int32) {
    	guard let device = device else {
    		connectReceiver?(nil, .notFound)
    		return
    	}
    	
        if newState == BluetoothProfileStatic.STATE_CONNECTED {
        	let _ = gatt?.discoverServices()
        } else if (newState == BluetoothProfileStatic.STATE_DISCONNECTED) {
        	let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: false)
        	connectReceiver?(peripheral, nil)            
        } else {
        	connectReceiver?(nil, .notFound)
        }        
    }
    
    public func onServicesDiscovered(gatt: BluetoothGatt?, status: Int32) {
        if status == BluetoothGatt.GATT_SUCCESS, let gatt = gatt, let services = gatt.getServices(), let device = device {
        	readChars = []
        	notifyChars = []
        	writeChars = []
        	
            for gattService in services {
                if let gattService = gattService, let characteristics = gattService.getCharacteristics() {
                    for gattCharacteristic in characteristics {
                    	guard let gattCharacteristic = gattCharacteristic else { continue }

                        if (gattCharacteristic.getProperties() & (BluetoothGattCharacteristic.PROPERTY_WRITE | BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE)) != 0 {
                            writeChars.append(gattCharacteristic)
                        } else if (gattCharacteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_READ) != 0 {
                        	readChars.append(gattCharacteristic)
                        } else if (gattCharacteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0 {
                            notifyChars.append(gattCharacteristic)
                        }
                    }
                }
            }
            
            let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: true)
            connectReceiver?(peripheral, nil)
        }
    }
    
	public func onCharacteristicWrite(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?, status: Int32) {
    	if let gatt = gatt {
    		requestWriteCharacteristics(gatt: gatt)
			writeCharacteristicReceiver?(true)
    	} else {
			writeCharacteristicReceiver?(false)
    	}
	}
	    
    public func onCharacteristicRead(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?, status: Int32) {
    	if let gatt = gatt, let bytes = characteristic?.getValue() {
    		requestReadCharacteristics(gatt: gatt)
    		let readValue = Data(bytes: bytes, count: bytes.count)
    		readCharacteristicReceiver?(readValue)
    	} else {
			readCharacteristicReceiver?(nil)    		
    	}
	}
	
	public func onCharacteristicChanged(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?) {
    	if let gatt = gatt, let bytes = characteristic?.getValue() {
    		requestNotifyCharacteristics(gatt: gatt)
    		let readValue = Data(bytes: bytes, count: bytes.count)
			notifyCharacteristicReceiver?(readValue)
    	} else {
			notifyCharacteristicReceiver?(nil)
    	}
	}
}

extension GattCallback {
	func requestReadCharacteristics(gatt: BluetoothGatt) {
		guard readChars.count > 0 else { return }
		if !gatt.readCharacteristic(characteristic: readChars[readChars.count - 1]) {
			readChars.removeLast()
			requestReadCharacteristics(gatt: gatt)
		} else {
			readChars.removeLast()
		}		
	}
	
	func requestNotifyCharacteristics(gatt: BluetoothGatt) {
		guard notifyChars.count > 0 else { return }
		let _ = gatt.setCharacteristicNotification(characteristic: notifyChars[notifyChars.count - 1], enable: true)
		if !gatt.readCharacteristic(characteristic: notifyChars[notifyChars.count - 1]) {
			notifyChars.removeLast()
			requestNotifyCharacteristics(gatt: gatt)
		} else {
			notifyChars.removeLast()	
		}		
	}
	
	func requestWriteCharacteristics(gatt: BluetoothGatt) {
		guard let writeData = writeData, writeChars.count > 0 else { return }
		let writeChar = writeChars[writeChars.count - 1]
		let _ = writeChar.setValue(value: writeData.map{Int8(bitPattern: $0)})		
		if !gatt.writeCharacteristic(characteristic: writeChar) {
			writeChars.removeLast()
			requestWriteCharacteristics(gatt: gatt)
		} else {
			writeChars.removeLast()	
		}		
	}	
}

public class LeScanCallback: Object, ScanCallback {
	static let shared = LeScanCallback()
	var receiver: ((Peripheral?, BMError?) -> Void)?
	var deviceArray: [BluetoothDevice] = []
	
	public func onScanResult(callbackType: Int32, result: ScanResult?) {
		guard let result = result, let device = result.getDevice() else { receiver?(nil, .notFound); return }
        let deviceHardwareAddress = device.getAddress()
        let deviceName = device.getName()
        
        if !self.deviceArray.contains(device) {
            self.deviceArray.append(device)
            let peripheral = Peripheral(name: deviceName, uuid: deviceHardwareAddress, isConnected: false)

            receiver?(peripheral, nil)
        }
	}
}