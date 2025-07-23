//
//  BLEManager.swift
//  ESP32_BLE
//
//  Created by Yusuke Mizuno on 2025/07/21.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected = false

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeChar: CBCharacteristic?

    private let targetName = "LED-Device"

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover p: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = p.name, name == targetName {
            peripheral = p
            central.stopScan()
            central.connect(p, options: nil)
            p.delegate = self
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect p: CBPeripheral) {
        isConnected = true
        p.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("切断されました: \(peripheral.name ?? "Unknown")")
        isConnected = false
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        for char in service.characteristics ?? [] {
            if char.properties.contains(.write) {
                writeChar = char
            }
        }
    }

    func send(_ value: String) {
        guard let peripheral = peripheral,
              let char = writeChar,
              let data = value.data(using: .utf8)
        else { return }

        peripheral.writeValue(data, for: char, type: .withResponse)
    }
}
