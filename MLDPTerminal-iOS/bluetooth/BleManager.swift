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

    public static let sharedBleManager = BleManager()

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
        // FIXME bleDevices を通知してInteractor側で追加
        /**if !bleDevices.contains(peripheral) {
            bleDevices.append(peripheral)
        }**/
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
        // FIX notify data
        /**if let data = characteristic.value {
            if readData != nil {
                readData!.append(data)
            } else {
                readData = data
            }
        }**/
    }

    /* Central関連メソッド */

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManagerState: \(central.state)")
        switch central.state {
        case .poweredOff:
            print("Bluetoothの電源がOff")
            // Indicator表示開始
            appDelegate.indicator.show(controller: self)
        case .poweredOn:
            print("Bluetoothの電源はOn")
            // Indicator表示終了
            appDelegate.indicator.dismiss()
        case .resetting:
            print("レスティング状態")
            // Indicator表示開始
            appDelegate.indicator.show(controller: self)
        case .unauthorized:
            print("非認証状態")
            // Indicator表示開始
            appDelegate.indicator.show(controller: self)
        case .unknown:
            print("不明")
            // Indicator表示開始
            appDelegate.indicator.show(controller: self)
        case .unsupported:
            print("非対応")
            // Indicator表示開始
            appDelegate.indicator.show(controller: self)
        }
    }

    // ペリフェラルを発見したときに呼ばれる
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // デバイス配列に追加格納
        appDelegate.discoveredDevice.append(peripheral)
        reload()
    }

    func scanDevice() {
        centralManager.scanForPeripherals(withServices: [MLDP_SERVICE_UUID], options: nil)
    }


    // 接続を開始する関数
    func connect(peripheral: CBPeripheral) {
        // 省電力のために探索停止
        centralManager?.stopScan()
        centralManager.connect(peripheral, options: nil)

        // タイマーがすでに動作しているとき
        if appDelegate.connectTimer.isValid {
            // 現在のタイマーを破棄する
            appDelegate.connectTimer.invalidate()
        }
        // タイマーを生成する
        appDelegate.connectTimer = Timer.scheduledTimer(timeInterval: 5, target: ViewController(), selector: #selector(ViewController().timeOut), userInfo: nil, repeats: false)
        print("waiting for connection")
    }


    // デバイスにデータを送信する
    func write(_ inputString : String, bleDevice: CBPeripheral) {
        if characteristic == nil {
            print("device is not ready!")
            return;
        }

        // FIXME Interactorで処理
        // コントロールキーを押しているとき
        /**if terminalView!.ctrlKey {
            terminalView?.writePeripheral(inputString)
        }
        else {
            bleDevice.writeValue(
                    inputString.data(using: String.Encoding.utf8)!,
                    for: characteristic,
                    type: CBCharacteristicWriteType.withResponse
            )
            print("inputString : \(String(describing: inputString))")  // TeCに送った文字列
            print("--- デバイスにデータを送信しました write() ---")
        }**/
    }

}

