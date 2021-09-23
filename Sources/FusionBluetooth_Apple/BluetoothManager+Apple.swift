#if os(macOS) || os(iOS)
import FusionBluetooth_Common
import CoreBluetooth

extension Device: DeviceProtocol {
    public func connect(receiver: @escaping (Bool, BMError?) -> Void) {
        BluetoothManager.shared.connectDevice(device: self) { success, error in
            self.isConnected = success
            receiver(success, error)
        }
    }
    
    public func disconnect(receiver: @escaping (Bool, BMError?) -> Void) {
        BluetoothManager.shared.disconnectDevice(device: self) { success, error in
            self.isConnected = !success
            receiver(success, error)
        }
    }
    
    public func write(data: Data) {
        BluetoothManager.shared.writeCharacteristic(device: self, data: data)
    }
    
    public func read(receiver: @escaping (Data?) -> Void) {
        BluetoothManager.shared.readCharacteristic(device: self, receiver: receiver)
    }
    
    public func notify(receiver: @escaping (Data?) -> Void) {
        BluetoothManager.shared.notifyCharacteristic(device: self, receiver: receiver)
    }
}

public class BluetoothManager {
    fileprivate class CBCDelegate: NSObject {
        typealias DiscoverReceiver = (Device?, BMError?) -> Void
        typealias ConnectReceiver = (Bool, BMError?) -> Void
        typealias DataReceiver = (Data?) -> Void
        var discoverReceiver: DiscoverReceiver?
        var connectReceiver: ConnectReceiver?
        var disconnectReceiver: ConnectReceiver?
        var readCharacteristicReceiver: DataReceiver?
        var notifyCharacteristicReceiver: DataReceiver?
        var writeCharacteristicReceiver: DataReceiver?
        
        var peripheralArray: [CBPeripheral] = []
        var writeData: Data?
    }
  
    public static let shared = BluetoothManager()
    private let delegate: CBCDelegate
    private let centralManager: CBCentralManager
    
    public required init() {
        self.delegate = CBCDelegate()
        self.centralManager = CBCentralManager(delegate: self.delegate, queue: nil)
    }
}

extension BluetoothManager: BluetoothManagerProtocol {
    public func startDiscovering(receiver: @escaping (Device?, BMError?) -> Void) {
        guard isAuthorized() else { receiver(nil, .unauthorized); return }
        guard isSupporting() else { receiver(nil, .unsupported); return }
        guard isEnabled() else { receiver(nil, .notEnabled); return }
        guard !isDiscovering() else { receiver(nil, .discovering); return }
        self.delegate.discoverReceiver = receiver
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func stopDiscovering() {
        centralManager.stopScan()
    }
}

extension BluetoothManager {
    func requestAuthorization() { }
    
    func isAuthorized() -> Bool {
        if #available(iOS 13.0, *) {
             return centralManager.authorization == .allowedAlways
         }
         return CBPeripheralManager.authorizationStatus() == .authorized
    }
        
    func isSupporting() -> Bool {
        return self.centralManager.state != .unsupported
    }
        
    func isDiscovering() -> Bool {
        return self.centralManager.isScanning
    }
    
    func isEnabled() -> Bool {
        return self.centralManager.state == .poweredOn
    }
    
    
    func enableBluetooth() -> Bool {
        return false
    }

    func disableBluetooth() -> Bool {
        return false
    }
    
    func connectDevice(device: Device, receiver: @escaping (Bool, BMError?) -> Void) {
        self.delegate.connectReceiver = receiver
        if let peripheral = self.delegate.peripheralArray.first(where: { "\($0.identifier)" == device.uuid }) {
            centralManager.connect(peripheral, options: nil)
        } else {
            receiver(false, .notFound)
        }
    }
    
    func disconnectDevice(device: Device, receiver: @escaping (Bool, BMError?) -> Void) {
        self.delegate.disconnectReceiver = receiver
        if let peripheral = self.delegate.peripheralArray.first(where: { device.uuid == "\($0.identifier)" }) {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            receiver(false, .notFound)
        }
    }
    
    func isConnected(device: Device) -> Bool {
        if let peripheral = self.delegate.peripheralArray.first(where: { device.uuid == "\($0.identifier)" }) {
            return peripheral.state == .connected
        }
        
        return false
    }
        
    func readCharacteristic(device: Device, receiver: @escaping (Data?) -> Void) {
        self.delegate.readCharacteristicReceiver = receiver
        if let peripheral = self.delegate.peripheralArray.first(where: { device.uuid == "\($0.identifier)" }) {
            peripheral.delegate = self.delegate
            peripheral.discoverServices(nil)
        } else {
            receiver(nil)
        }
    }
    
    func notifyCharacteristic(device: Device, receiver: @escaping (Data?) -> Void) {
        self.delegate.notifyCharacteristicReceiver = receiver
        if let peripheral = self.delegate.peripheralArray.first(where: { device.uuid == "\($0.identifier)" }) {
            peripheral.delegate = self.delegate
            peripheral.discoverServices(nil)
        } else {
            receiver(nil)
        }
    }
    
    func writeCharacteristic(device: Device, data: Data) {
        self.delegate.writeData = data
        if let peripheral = self.delegate.peripheralArray.first(where: { device.uuid == "\($0.identifier)" }) {
            peripheral.delegate = self.delegate
            peripheral.discoverServices(nil)
        }
    }
}

extension BluetoothManager.CBCDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            discoverReceiver?(nil, .unknown)
            connectReceiver?(false, .unknown)
        case .unsupported:
            discoverReceiver?(nil, .unsupported)
            connectReceiver?(false, .unsupported)
        case .unauthorized:
            discoverReceiver?(nil, .unauthorized)
            connectReceiver?(false, .unauthorized)
        case .poweredOff:
            discoverReceiver?(nil, .notEnabled)
            connectReceiver?(false, .notEnabled)
        case .resetting:
            discoverReceiver?(nil, .discovering)
            connectReceiver?(false, .discovering)
        case .poweredOn: break
        @unknown default:
            discoverReceiver?(nil, .unknown)
            connectReceiver?(false, .unknown)
        }
    }
  
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralData = self.convertPeripheral(peripheral: peripheral)
        if !self.peripheralArray.contains(peripheral) {
            self.peripheralArray.append(peripheral)

            discoverReceiver?(peripheralData, nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectReceiver?(true, nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnectReceiver?(true, nil)
    }
    
    private func convertPeripheral(peripheral: CBPeripheral) -> Device{
        return Device(name: peripheral.name, uuid: "\(peripheral.identifier)", isConnected: peripheral.state == .connected)
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