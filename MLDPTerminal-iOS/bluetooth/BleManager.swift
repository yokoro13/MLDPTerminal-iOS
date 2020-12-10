//
//  BleManager.swift
//  MLDPTerminal-iOS
//
//  Created by 横路海斗 on 2020/08/25.
//  Copyright © 2020 yokoro. All rights reserved.
//

import Foundation
import CoreBluetooth

final class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // MLDPのサービスのUUID
    let MLDP_SERVICE_UUID = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000300")
    // notify-write用UUID
    let MLDP_CHARACTERISTIC_UUID = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000301")

    private var centralManager: CBCentralManager!
    private var characteristic: CBCharacteristic?  // データの出力先

    var state: BleState = .closed

    public static let sharedBleManager = BleManager()

    var currentPeripheral: CBPeripheral?

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            state = .ready
        default: // poweredOff,resetting,unauthorized,unknown,unsupported
            NSLog("BleManager: unexpected state")
            state = .error
        }
    }

    // ペリフェラルを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        NotificationCenter.default.post(
                name: .discoveredDeviceNotification,
                object: nil,
                userInfo: ["device": BleDevice(name: peripheral.name, peripheral: peripheral)])
    }

    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([MLDP_SERVICE_UUID])
    }

    // ペリフェラルとの接続が切断されると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        state = .closed
    }

    // サービス発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        guard error == nil else {
            NSLog("BleManager: %@", error.debugDescription)
            state = .error
            return
        }
        for service in peripheral.services! {
            print("didDiscoverServices")
            print(service)
            peripheral.discoverCharacteristics(nil, for:service)
        }
    }

    // キャラクタリスティック発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard error == nil else {
            NSLog("BleManager: %@", error.debugDescription)
            state = .error
            return
        }
        print("didDiscoverCharacteristicsFor")
        for characteristic in service.characteristics! where characteristic.uuid.isEqual(MLDP_CHARACTERISTIC_UUID) {
            self.characteristic = characteristic
            peripheral.setNotifyValue(true, for:characteristic)
            break
        }
        state = .idle
    }

    // Notify開始／停止時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        if error != nil {
            NSLog("BleManager: %@", error.debugDescription)
            state = .error
            return
        } else {
            write("\r\nMLDP\r\nApp:on\r\n") // Tecに接続
            print("TeCに接続")
        }
    }

    // peripheralからデータが届いたときのイベント
    func peripheral( _ peripheral: CBPeripheral,
                     didUpdateValueFor characteristic: CBCharacteristic,
                     error: Error?) {
        guard error == nil else {
            NSLog("BleManager: %@", error.debugDescription)
            state = .error
            return
        }
        if let data = characteristic.value {
            NotificationCenter.default.post(
                    name:  .receivedDataNotification,
                    object: nil,
                    userInfo: ["text": data])
        }
    }
    
    func scanDevice() {
        centralManager.scanForPeripherals(withServices: [MLDP_SERVICE_UUID], options: nil)
    }

    func stopScan(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }

    // 接続を開始する関数
    func connect(peripheral: CBPeripheral) {
        // 省電力のために探索停止
        self.currentPeripheral = peripheral
        centralManager?.stopScan()
        centralManager.connect(peripheral, options: nil)
        currentPeripheral?.delegate = self
    }

    func disconnect() {
        if currentPeripheral == nil {
            print("not set currentPeripheral")
            return;
        }

        if characteristic == nil {
            print("not set characteristic")
            return;
        }

        state = .closed
        let str = "ERR\r\nERR\r\n"                          // TeCが切断したと認識する文字列
        let data = str.data(using: String.Encoding.utf8)
        currentPeripheral?.writeValue(data!, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
        currentPeripheral?.setNotifyValue(false, for: characteristic!)
        centralManager.cancelPeripheralConnection(currentPeripheral!)

        centralManager = CBCentralManager(delegate: self, queue: nil)
        currentPeripheral?.delegate = self
        currentPeripheral = nil
    }


    // デバイスにデータを送信する
    func write(_ data : String) {
        if currentPeripheral == nil {
            print("not set currentPeripheral")
            return;
        }

        if characteristic == nil {
            print("not set characteristic")
            return;
        }

        currentPeripheral?.writeValue(
                data.data(using: String.Encoding.utf8)!,
                for: characteristic!,
                type: CBCharacteristicWriteType.withResponse
        )
    }

}

