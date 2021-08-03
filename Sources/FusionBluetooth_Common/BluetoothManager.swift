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
 *  @protocol BluetoothManagerProtocol
 *
 *  @discussion The delegate of managing Bluetooth.
 *
 */
public protocol BluetoothManagerProtocol {

	/*
     * @method requestAuthorization:
     *
     * @discussion Requests the ACCESS_FINE_LOCATION permission. For only Android
     */
    func requestAuthorization()
    
    /*
     * @method isDiscovering:
     *
     * @discussion Whether or not the central is currently discovering.
     */
	func isDiscovering() -> Bool
	
	/*
     * @method isCentralPoweredOn:
     *
     * @discussion Returns whether the central device is powered on.
     */     
	func isCentralPoweredOn() -> Bool
	
	/*
     * @method startDiscovering:
     *
     * @param receiver Returns a Peripheral discovered.
     *
     * @discussion Start Discovering Peripherals.
     */
	func startDiscovering(receiver: @escaping (Peripheral?) -> Void)
	
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
	func connectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void)
	
	/*
     * @method connectDevice:
     *
     * @param uuid Peripheral identifier in iOS and Device Mac addres in Android 
     * @param receiver Returns the Peripheral disconnected.
     *
     * @discussion Disconnects a peripheral
     */
	func disconnectDevice(uuid: String, receiver: @escaping (Peripheral?) -> Void)
	
	/*
     * @method receiveMessage:
     *
     * @param message A message string received
     *
     * @discussion Receives a message to a peripheral.
     */
	func receiveMessage(message: @escaping (String) -> Void)
	
	/*
     * @method sendMessage:
     *
     * @param message A message string to send
     *
     * @discussion Sends a message to a peripheral.
     */
    func sendMessage(message: String)
}