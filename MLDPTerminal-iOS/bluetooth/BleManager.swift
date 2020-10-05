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
    private var timer: Timer?                      // 接続待ちタイムアウト用

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
        timer?.invalidate()
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
        for characteristic in service.characteristics! where characteristic.uuid.isEqual(MLDP_CHARACTERISTIC_UUID) {
            self.characteristic = characteristic
            peripheral.setNotifyValue(true, for:characteristic)

            // 書き込みデータの準備(文字を文字コードに変換?)
            let str = "App:on\r\n"
            let data = str.data(using: String.Encoding.utf8)

            // ペリフェラルにデータを書き込む
            peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            break
        }
        state = .idle
    }

    // Notify開始／停止時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else {
            NSLog("BleManager: %@", error.debugDescription)
            state = .error
            return
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
        centralManager?.stopScan()
        centralManager.connect(peripheral, options: nil)
    }


    // デバイスにデータを送信する
    func write(_ data : String) {
        if currentPeripheral == nil {
            print("device is not ready!")
            return;
        }

        if characteristic == nil {
            print("device is not ready!")
            return;
        }

        currentPeripheral?.writeValue(
                data.data(using: String.Encoding.utf8)!,
                for: characteristic!,
                type: CBCharacteristicWriteType.withResponse
        )
    }

}

