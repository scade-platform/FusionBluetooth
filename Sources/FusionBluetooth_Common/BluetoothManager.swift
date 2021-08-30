import Foundation

/**
 *  @struct Peripheral
 *
 *  @discussion The device data for peripheral
 *
 */
public struct Peripheral: Equatable {

    /**
     *  @property name
     *
     *  @discussion The device name.
     *
     */
    public let name: String?
    
    /**
     *  @property uuid
     *
     *  @discussion The identifier in iOS and MAC address in Android.
     *
     */
    public let uuid: String
    
     /**
     *  @property isConnected
     *
     *  @discussion The state whether the peripheral is connected or not
     *
     */
    public var isConnected: Bool
    
    public init(name: String?, uuid: String, isConnected: Bool) {
        self.name = name
        self.uuid = uuid
        self.isConnected = isConnected
    }
}

/**
 *  @enum BMError
 *
 *  @discussion Error State
 *
 */
public enum BMError: Equatable, Error {
    case unknown // State unknown, update imminent.
    case unsupported // The platform doesn't support the Bluetooth Low Energy Central/Client role.
    case unauthorized // The application is not authorized to use the Bluetooth Low Energy role.
    case discovering // The application is currently discovering the Bluetooth Device.
    case resetting // The connection with the system service was momentarily lost, update imminent.
    case notEnabled // Bluetooth is currently not enabled.
    case notFound // The application could not find the Bluetooth Device.
    case error(String)
    
    func description() -> String {
        switch self {
        case .unknown:
            return "Unexpected error"
        case .unsupported:
            return "The platform doesn't support the Bluetooth Low Energy Central/Client role."
        case .unauthorized:
            return "The application is not authorized to use the Bluetooth Low Energy role."
        case .discovering:
            return "The application is currently discovering the Bluetooth Device."
        case .resetting:
            return "The connection with the system service was momentarily lost, update imminent."
        case .notEnabled:
            return "Bluetooth is currently not enabled."
        case .notFound:
            return "The application could not find the Bluetooth Device."
        case .error(let error):
            return error
        }
    }
}

/**
 *  @protocol BluetoothManagerProtocol
 *
 *  @discussion The delegate of managing Bluetooth.
 *
 */
public protocol BluetoothManagerProtocol {
    /*
     * @method startDiscovering:
     *
     * @param receiver Returns a Peripheral discovered.
     *
     * @discussion Start Discovering Peripherals.
     */
    func startDiscovering(receiver: @escaping (Peripheral?, BMError?) -> Void)
    
    /*
     * @method stopDiscovering:
     *
     * @discussion Stops scanning peripherals.
     */
    func stopDiscovering()
        
    /*
     * @method connectDevice:
     *
     * @param uuid Peripheral identifier in iOS and Device Mac addres in Android
     * @param receiver Returns the Peripheral connected.
     *
     * @discussion Connects a peripheral
     */
    func connectDevice(uuid: String, receiver: @escaping (Peripheral?, BMError?) -> Void)
    
    /*
     * @method disconnectDevice:
     *
     * @param uuid Peripheral identifier in iOS and Device Mac addres in Android
     * @param receiver Returns the Peripheral disconnected.
     *
     * @discussion Disconnects a peripheral
     */
    func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?, BMError?) -> Void)

    /*
     * @method writeCharacteristic:
     *
     * @param uuid Peripheral identifier in iOS and Device Mac addres in Android
     * @param data A data to send
     *
     * @discussion write a Characteristic to a peripheral.
     */
    func writeCharacteristic(uuid: String, data: Data)
            
    /*
     * @method readCharacteristic:
     *
     * @param uuid Peripheral identifier in iOS and Device Mac addres in Android
     * @param data A data received
     *
     * @discussion Read a Characteristic from a peripheral.
     */
    func readCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void)
    
    /*
     * @method notifyCharacteristic:
     *
     * @param uuid Peripheral identifier in iOS and Device Mac addres in Android
     * @param data A data received
     *
     * @discussion Notify a Characteristic from a peripheral.
     */
    func notifyCharacteristic(uuid: String, receiver: @escaping (Data?) -> Void)
}
