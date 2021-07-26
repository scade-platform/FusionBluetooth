#if os(macOS) || os(iOS)
import FusionBluetooth_Common
import CoreBluetooth

public class BluetoothManager {
    fileprivate class CBCDelegate: NSObject {
        typealias Receiver = (Peripheral?) -> Void
        typealias StateReceiver = (Bool) -> Void
        var receiver: Receiver?
        var stateReceiver: StateReceiver?
        
        var peripheralArray: [CBPeripheral] = []
    }
  
	private let delegate: CBCDelegate
	private let centralManager: CBCentralManager
//	private let peripheral: CBPeripheral!
	
	public required init() {
		self.delegate = CBCDelegate()
        self.centralManager = CBCentralManager(delegate: self.delegate, queue: nil)
    }	
}

extension BluetoothManager: BluetoothManagerProtocol {
	public func requestAuthorization() { }
	
	public func isScanning() -> Bool {
		return self.centralManager.isScanning		
	}
	
	public func checkState(receiver: @escaping (Bool) -> Void) {
		self.delegate.stateReceiver = receiver

        receiver(self.centralManager.state == .poweredOn)       
	}
	
	public func discoverDevice(receiver: @escaping (Peripheral?) -> Void) {
		self.delegate.receiver = receiver
		centralManager.scanForPeripherals(withServices: nil, options: nil)
	}
	
	public func stopDiscovering() {
		centralManager.stopScan()
	}
	
	public func connectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {	
		self.delegate.receiver = receiver
		if let peripheral = self.delegate.peripheralArray.first(where: { "\($0.identifier)" == uuid }) {
            centralManager.connect(peripheral, options: nil)
        } else {
        	receiver(nil)
        }
	}
	
	public func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void) {
		self.delegate.receiver = receiver
		if let peripheral = self.delegate.peripheralArray.first(where: { uuid == "\($0.identifier)" }) {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
        	receiver(nil)
        }
	}
	
	public func receiveMessage(message: @escaping (String) -> Void) {
		
	}
	
    public func sendMessage(message: String) {
    	
    }
}

extension BluetoothManager.CBCDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {        
        stateReceiver?(central.state == .poweredOn)
    }
  
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
	  let peripheralData = self.convertPeripheral(peripheral: peripheral)
      if !self.peripheralArray.contains(peripheral) {
          self.peripheralArray.append(peripheral)

          receiver?(peripheralData)
      }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
	    let peripheralData = self.convertPeripheral(peripheral: peripheral)
	    receiver?(peripheralData)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
	    let peripheralData = self.convertPeripheral(peripheral: peripheral)
        receiver?(peripheralData)
    }
    
    private func convertPeripheral(peripheral: CBPeripheral) -> Peripheral{       
        return Peripheral(name: peripheral.name, uuid: "\(peripheral.identifier)", isConnected: peripheral.state == .connected)
    }
}

extension BluetoothManager.CBCDelegate: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
  
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
  }
}


#endif