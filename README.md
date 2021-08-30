# FusionBluetoothThe FusionBluetooth SPM package makes it possible to use Bluetooth functionality on Android and iOS using Swift Discuss-------Join our slack channel here for Fusion Package discussion [link](https://scadeio.slack.com/archives/C025WRG18TW)For native cross plaform development with Swift and geneel Fusion introduciton, go here [SCADE Fusion](beta.scade.io/fusion)Install - Add to Package.swift------------------------------```swiftimport PackageDescriptionimport Foundationlet SCADE_SDK = ProcessInfo.processInfo.environment["SCADE_SDK"] ?? ""let package = Package(    name: "BluetoothApp",    platforms: [        .macOS(.v10_14)    ],    products: [        .library(            name: "BluetoothApp",            type: .static,            targets: [                "BluetoothApp"            ]        )    ],    dependencies: [		.package(name: "FusionBluetooth", url: "https://github.com/scade-platform/FusionBluetooth.git", .branch("main")),    ],    targets: [        .target(            name: "BluetoothApp",            dependencies: [            	.product(name: "FusionBluetooth", package: "FusionBluetooth"),            ],            exclude: ["main.page"],            swiftSettings: [                .unsafeFlags(["-F", SCADE_SDK], .when(platforms: [.macOS, .iOS])),                .unsafeFlags(["-I", "\(SCADE_SDK)/include"], .when(platforms: [.android])),            ]        )    ])```Permission Settings-------------------<Add Permission specific text and instructions>```yaml...ios:  ...  plist:    ...    - key: NSBluetoothAlwaysUsageDescription      type: string      value: Use Bluetooth    android:  ...  permissions: ["ACCESS_FINE_LOCATION", "BLUETOOTH", "BLUETOOTH_ADMIN", "ACCESS_COARSE_LOCATION"]  ...```Demo App--------Our demo app is available here [link](https://github.com/scade-platform/FusionExamples/tree/main/BluetoothApp)Basic Usage-----------```swift    ...
    // initialize the BluetoothManager    let bluetoothManager = BluetoothManager()    // page adapter initialization    override func load(_ path: String) {        super.load(path)        // connect the button action to discover and connect func        discoverButton.onClick.append(SCDWidgetsEventHandler{ _ in self.discover()})        connectButton.onClick.append(SCDWidgetsEventHandler{ _ in self.connect()})    }  	    // discover func    func discover() {        bluetoothManager.startDiscovering { device, err in
            guard let device = device else {
                switch err {
                    case .some(let err):
                        print(err)
                    default:
                        print("Unknown")
                }
            }

            // Do something with my device, e.g. add to a list in the adapter
            devices.append(device)
        }    }    // connect func    func connect() {        bluetoothManager.connectDevice(uuid: uuid) { device, err in
            guard let device = device else {
                switch err {
                    case .some(let err):
                        print(err)
                    default:
                        print("Unknown")
                }
            }

            // Do something with my device, e.g. read/write/notify characteristic
        }    }    ...```Features--------List of features* start discovering* stop discovering
* connect device
* disconnect device
* write characteristic
* read characteristic
* notify characteristic
API---Please find the api here [API](./Sources/FusionBluetooth_Common/BluetoothManager.swift)