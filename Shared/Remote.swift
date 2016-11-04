//
//  Remote.swift
//  Remote
//
//  Created by Kristian Trenskow on 03/11/2016.
//  Copyright © 2016 trenskow.io. All rights reserved.
//

import CoreBluetooth

extension Notification.Name {
    public static let remoteConnecting    = Notification.Name(rawValue: "RemoteConnecting")
    public static let remoteConnected     = Notification.Name(rawValue: "RemoteConnected")
    public static let remoteDisconnecting = Notification.Name(rawValue: "RemoteDisconnecting")
    public static let remoteDisconnected  = Notification.Name(rawValue: "RemoteDisconnected")
}

public protocol RemoteDelegate: class {
    func remote(_ remote: Remote, didChangeState state: Remote.State)
}

public class Remote: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public struct Command : OptionSet {
        
        public let rawValue: UInt8
        
        public static let stop        = Command(rawValue: 0b00000100)
        public static let fastForward = Command(rawValue: 0b00001000)
        public static let play        = Command(rawValue: 0b00010000)
        public static let record      = Command(rawValue: 0b00100000)
        public static let rewind      = Command(rawValue: 0b01000000)
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
    }
    
    public enum State {
        case connecting
        case connected
        case disconnecting
        case disconnected
    }
    
    public static let `default` = Remote()
    
    private let central: CBCentralManager
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    private var shouldConnect = false
    
    var state: State = .disconnected {
        didSet {
            delegate?.remote(self, didChangeState: state)
            var name: Notification.Name!
            switch state {
            case .connecting:
                name = .remoteConnecting
            case .disconnecting:
                name = .remoteDisconnecting
            case .connected:
                name = .remoteConnected
            case .disconnected:
                name = .remoteDisconnected
            }
            NotificationCenter.default.post(name: name, object: self)
        }
    }
    
    public weak var delegate: RemoteDelegate?
    
    override init() {
        central = CBCentralManager(delegate: nil, queue: DispatchQueue.main)
        super.init()
        central.delegate = self
    }
    
    typealias CompletionHandler = (Error?) -> ()
    
    public func `do`(command: Command) {
        
        guard let peripheral = peripheral else { return }
        
        var commandRawValue = command.rawValue
        
        peripheral.writeValue(
            Data(bytes: &commandRawValue, count: MemoryLayout<UInt8>.size),
            for: characteristic!,
            type: .withResponse
        )
        
    }
    
    func scan() {
        shouldConnect = false
        central.scanForPeripherals(
            withServices: [CBUUID(string: "4D77A91A-559E-11E6-BEB8-9E71128CAE78")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    public func connect() {
        guard central.state == .poweredOn else {
            shouldConnect = true
            return
        }
        state = .connecting
        scan()
    }
    
    public func disconnect() {
        guard shouldConnect == false else {
            shouldConnect = false
            return
        }
        guard let peripheral = peripheral else { return }
        self.state = .disconnecting
        central.cancelPeripheralConnection(peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        central.stopScan()
        self.central.connect(self.peripheral!, options: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn && shouldConnect == true
            else { return }
        scan()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        characteristic = nil
        state = .disconnected
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        characteristic = service.characteristics?.first
        state = .connected
    }
}
