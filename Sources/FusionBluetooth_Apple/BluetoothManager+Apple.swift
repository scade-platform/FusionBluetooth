#if os(macOS) || os(iOS)
import FusionBluetooth_Common
import CoreBluetooth

public class BluetoothManager {
    fileprivate class CBCDelegate: NSObject {
        typealias Receiver = (Peripheral?) -> Void
        typealias StateReceiver = (DeviceState) -> Void
        typealias DataReceiver = (Data?) -> Void
        var receiver: Receiver?
        var stateReceiver: StateReceiver?
        var readCharacteristicReceiver: DataReceiver?
        var notifyCharacteristicReceiver: DataReceiver?
        var writeCharacteristicReceiver: DataReceiver?
        
        var peripheralArray: [CBPeripheral] = []
        var writeData: Data?
    }
  
    private let delegate: CBCDelegate
    private let centralManager: CBCentralManager
    
    public required init() {
        self.delegate = CBCDelegate()
        self.centralManager = CBCentralManager(delegate: self.delegate, queue: nil)
    }
}

extension BluetoothManager: BluetoothManagerProtocol {
    public func requestAuthorization() { }
    
    public func isAuthorized() -> Bool {
        if #available(iOS 13.0, *) {
             return centralManager.authorization == .allowedAlways
         }
         return CBPeripheralManager.authorizationStatus() == .authorized
    }
        
    public func isSupporting() -> Bool {
        return self.centralManager.state != .unsupported
    }
        
    public func isDiscovering() -> Bool {
        return self.centralManager.isScanning
    }
    
    public func isEnabled() -> Bool {
        return self.centralManager.state == .poweredOn
    }
    
    public func startDiscovering(receiver: @escaping (Peripheral?) -> Void) {
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
    
    public func enableBluetooth() -> Bool {
    	return false
    }

	public func disableBluetooth() -> Bool {
		return false
    }
        
    public func readCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
        self.delegate.readCharacteristicReceiver = receiver
        if let peripheral = self.delegate.peripheralArray.first(where: { uuid == "\($0.identifier)" }) {
            peripheral.delegate = self.delegate
            peripheral.discoverServices(nil)
        } else {
            receiver(nil)
        }
    }
    
    public func notifyCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void) {
        self.delegate.notifyCharacteristicReceiver = receiver
        if let peripheral = self.delegate.peripheralArray.first(where: { uuid == "\($0.identifier)" }) {
            peripheral.delegate = self.delegate
            peripheral.discoverServices(nil)
        } else {
            receiver(nil)
        }
    }
    
    public func writeCharacteristic(uuid: String, data: Data) {
        self.delegate.writeData = data
        if let peripheral = self.delegate.peripheralArray.first(where: { uuid == "\($0.identifier)" }) {
            peripheral.delegate = self.delegate
            peripheral.discoverServices(nil)
        }
    }
    
    public func listenToStateEvents(receiver: @escaping (DeviceState) -> Void) {
        self.delegate.stateReceiver = receiver
    }
}

extension BluetoothManager.CBCDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            stateReceiver?(.unknown)
        case .resetting:
            stateReceiver?(.resetting)
        case .unsupported:
            stateReceiver?(.unsupported)
        case .unauthorized:
            stateReceiver?(.unauthorized)
        case .poweredOff:
            stateReceiver?(.poweredOff)
        case .poweredOn:
            stateReceiver?(.poweredOn)

        @unknown default:
            stateReceiver?(.unknown)
        }
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
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let characteristic = characteristic as CBCharacteristic

            if characteristic.properties.contains(.write) {
                if let writeData = writeData {
                    peripheral.writeValue(writeData, for: characteristic, type: .withResponse)
                }
            }
            
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.properties.contains(.write) {
            
        }
        
        if characteristic.properties.contains(.read) {
            readCharacteristicReceiver?(characteristic.value!)
        }
        
        if characteristic.properties.contains(.notify) {
            notifyCharacteristicReceiver?(characteristic.value!)
        }
    }
}

#endif