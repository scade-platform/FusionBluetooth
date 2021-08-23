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
		if let bluetoothLeScanner = self.bluetoothLeScanner {
			bluetoothLeScanner.stopScan(callback: LeScanCallback.shared)
		}
	}
	
    public func connectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
    	print("Pavlo connectDevice uuid = \(uuid)")
        if let device = LeScanCallback.shared.deviceArray.first(where: { "\($0.getAddress())" == uuid }) {
            if let bluetoothGatt = self.bluetoothGatt {
            	print("Pavlo connectDevice existed already so close")
                bluetoothGatt.close()
                self.bluetoothGatt = nil
            }
            print("Pavlo connectDevice start connect")
            GattCallback.shared.connectReceiver = receiver
            GattCallback.shared.device = device            
            self.bluetoothGatt = device.connectGatt(context: nil, autoConnect: false, callback: GattCallback.shared)
        } else {
            receiver(nil)
        }
    }
	
	public func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
		if let bluetoothGatt = self.bluetoothGatt {
			bluetoothGatt.close()
			self.bluetoothGatt = nil
		}
		
		receiver(nil)		
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
		print("Pavlo readCharacteristic uuid = \(uuid)")
		if let bluetoothGatt = self.bluetoothGatt {
			print("Pavlo readCharacteristic start discoverServices")
			GattCallback.shared.dataReceiver = receiver
			let success = bluetoothGatt.discoverServices()
			print("Pavlo readCharacteristic start discoverServices success = \(success)")
		} else {
			receiver(nil)	
		}		
	}
	
	public func notifyCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
		if let bluetoothGatt = self.bluetoothGatt {
			GattCallback.shared.dataReceiver = receiver
			print("Pavlo notifyCharacteristic start discoverServices")
			let success = bluetoothGatt.discoverServices()
			print("Pavlo notifyCharacteristic start discoverServices success = \(success)")
		} else {
			receiver(nil)	
		}		
	}
    public func writeCharacteristic(uuid: String, data: Data) {
		if let bluetoothGatt = self.bluetoothGatt {
			print("Pavlo writeCharacteristic start discoverServices")
			GattCallback.shared.writeData = data
			let _ = bluetoothGatt.discoverServices()
		}
    }
    
    public func listenToStateEvents(receiver: @escaping (DeviceState) -> Void) {
    }    
}

public class GattCallback: Object, BluetoothGattCallback {
	static let shared = GattCallback()
	var connectReceiver: ((Peripheral?) -> Void)?
	var dataReceiver: ((Data?) -> Void)?	
	var device: BluetoothDevice?
	var writeData: Data?
	
    public func onConnectionStateChange(gatt: BluetoothGatt?, status: Int32, newState: Int32) {
    	print("Pavlo onConnectionStateChange")
    	guard let device = device else {
    		connectReceiver?(nil)
    		return
    	}
    	
        if newState == BluetoothProfileStatic.STATE_CONNECTED {
        	print("Pavlo onConnectionStateChange connected")
        	let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: true)
        	connectReceiver?(peripheral)
        } else if (newState == BluetoothProfileStatic.STATE_DISCONNECTED) {
        	print("Pavlo onConnectionStateChange disconnected")
        	let peripheral = Peripheral(name: device.getName(), uuid: device.getAddress(), isConnected: false)
        	connectReceiver?(peripheral)            
        } else {
        	print("Pavlo onConnectionStateChange empty")
        	connectReceiver?(nil)
        }        
    }
    
    public func onServicesDiscovered(gatt: BluetoothGatt?, status: Int32) {
    	print("Pavlo onServicesDiscovered")
        if status == BluetoothGatt.GATT_SUCCESS, let gatt = gatt, let services = gatt.getServices() {
        	print("Pavlo onServicesDiscovered gatt success")
            for gattService in services {
                if let gattService = gattService, let characteristics = gattService.getCharacteristics() {
                	print("Pavlo onServicesDiscovered getCharacteristics")
                    for gattCharacteristic in characteristics {
                    	print("Pavlo onServicesDiscovered gattCharacteristic ???")
                    	guard let gattCharacteristic = gattCharacteristic else { continue }
                    	print("Pavlo onServicesDiscovered gattCharacteristic !!!")
                        if (gattCharacteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_WRITE) == 0 &&
                            (gattCharacteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) == 0 {
                            print("Pavlo onServicesDiscovered gattCharacteristic !!! write")
                            if let writeData = writeData {
                                let _ = gattCharacteristic.setValue(value: writeData.map{Int8(bitPattern: $0)})
                                let _ = gatt.writeCharacteristic(characteristic: gattCharacteristic)
                            }
                        } else if (gattCharacteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_READ) == 0 {
                        	print("Pavlo onServicesDiscovered gattCharacteristic !!! read")
                            let _ = gatt.readCharacteristic(characteristic: gattCharacteristic)
                        } else if (gattCharacteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) == 0 {
                        	print("Pavlo onServicesDiscovered gattCharacteristic !!! notify")
                            let _ = gatt.setCharacteristicNotification(characteristic: gattCharacteristic, enable: true)
                            let _ = gatt.readCharacteristic(characteristic: gattCharacteristic)
                        }
                    }
                }
            }
        } else {
            dataReceiver?(nil)
        }
    }
    
	public func onCharacteristicWrite(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?, status: Int32) {

	}
	    
    public func onCharacteristicRead(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?, status: Int32) {
    	print("Pavlo onCharacteristicRead")
    	if let bytes = characteristic?.getValue() {
    		print("Pavlo onCharacteristicRead !!!")
    		let readValue = Data(bytes: bytes, count: bytes.count)
			dataReceiver?(readValue)
    	} else {
			dataReceiver?(nil)    		
    	}
	}
	
	public func onCharacteristicChanged(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?) {
		print("Pavlo onCharacteristicChanged")
    	if let bytes = characteristic?.getValue() {
    		print("Pavlo onCharacteristicChanged !!!")
    		let readValue = Data(bytes: bytes, count: bytes.count)
			dataReceiver?(readValue)
    	} else {
			dataReceiver?(nil)    		
    	}
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