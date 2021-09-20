import Foundation
import ScadeKit

public protocol DeviceProtocol {
    /*
     * @method connect:
     *
     * @param receiver Returns the success or error of Peripheral connection.
     *
     * @discussion Connects the device
     */
    func connect(receiver: @escaping (Bool, BMError?) -> Void)
    
    /*
     * @method disconnect:
     *
     * @param receiver Returns the success or error of Peripheral disconnection.
     *
     * @discussion Disconnects the device
     */
    func disconnect(receiver: @escaping (Bool, BMError?) -> Void)
    
    /*
     * @method write:
     *
     * @param data
     *
     * @discussion Write Data to the device.
     */
    func write(data: Data)
            
    /*
     * @method read:
     *
     * @param data
     *
     * @discussion Read data from the device.
     */
    func read(receiver: @escaping (Data?) -> Void)
    
    /*
     * @method notify:
     *
     * @param data
     *
     * @discussion Receive notification data from the device.
     */
    func notify(receiver: @escaping (Data?) -> Void)
}
/**
 *  @struct Device
 *
 *
 */
public class Device: EObject {

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
    
    public func description() -> String {
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
     * @param receiver Returns a Device discovered.
     *
     * @discussion Start discovering devices.
     */
    func startDiscovering(receiver: @escaping (Device?, BMError?) -> Void)
    
    /*
     * @method stopDiscovering:
     *
     * @discussion Stops scanning peripherals.
     */
    func stopDiscovering()
}
