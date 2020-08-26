//
//  BleManager.swift
//  MLDPTerminal-iOS
//
//  Created by 横路海斗 on 2020/08/25.
//  Copyright © 2020 yokoro. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // MLDPのサービスのUUID
    private let target_service_uuid =              // MLDP Service
            CBUUID(string:"00035B03-58E6-07DD-021A-08123A000300")
    private let target_charactaristic_uuid =       // Read/Write/Notify 用
            CBUUID(string: "00035B03-58E6-07DD-021A-08123A000301")

    private var centralManager: CBCentralManager!
    private var bleDevices = [CBPeripheral]()     // 発見したデバイス一覧
    private var bleDevice: CBPeripheral?          // 選択したデバイス
    private var characteristic: CBCharacteristic?  // データの出力先
    private var readData: Data?                    // 受信したデータ
    private var writeData = Data()                 // 送信待ちデータ
    private var timer: Timer?                      // 接続待ちタイムアウト用

    enum State {
        case initializing
        case ready
        case scanning
        case trying
        case busy
        case idle
        case canceling
        case closed
        case error
    }
    var state: State = .initializing

    override init() {
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
        if !bleDevices.contains(peripheral) {
            bleDevices.append(peripheral)
        }
    }

    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([target_service_uuid])
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
        for characteristic in service.characteristics! where characteristic.uuid.isEqual(target_charactaristic_uuid) {
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
            if readData != nil {
                readData!.append(data)
            } else {
                readData = data
            }
        }
    }

    // デバイスにデータを送信する
    func write(_ inputString : String) {
        if characteristic == nil {
            print("device is not ready!")
            return;
        }

        // FIXME ここでControllerがViewをもつな!w
        // コントロールキーを押しているとき
        if terminalView!.ctrlKey {
            terminalView?.writePeripheral(inputString)
        }
        else {
            bleDevice?.writeValue(
                    inputString.data(using: String.Encoding.utf8)!,
                    for: characteristic,
                    type: CBCharacteristicWriteType.withResponse
            )
            print("inputString : \(String(describing: inputString))")  // TeCに送った文字列
            print("--- デバイスにデータを送信しました write() ---")
        }
    }
}

