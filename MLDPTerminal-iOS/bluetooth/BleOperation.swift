//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import CoreBluetooth


class BleOperation {
    private let bleManager = BleManager.sharedBleManager

    // 切断状況判定変数
    func scanDevice() {
        bleManager.scanDevice()
    }

    // 接続を開始する関数
    func connect(peripheral: CBPeripheral) {
        bleManager.connect(peripheral: peripheral)
    }

    func stopScan(peripheral: CBPeripheral){
        bleManager.stopScan(peripheral: peripheral)
    }

    // デバイスにデータを送信する
    func write(_ data : String, peripheral: CBPeripheral) {
        bleManager.write(data, peripheral: peripheral)
    }
}