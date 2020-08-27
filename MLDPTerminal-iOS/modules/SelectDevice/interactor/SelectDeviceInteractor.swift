//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class SelectDeviceInteractor: SelectDeviceUseCase {
    weak var output: SelectDeviceInteractorOutput!

    var bleManager: BleManager = BleManager.sharedBleManager

    func scanDevice() {
        bleManager.scanDevice()
    }

    func connect(device: BleDevice) {
        bleManager.connect(peripheral: device.peripheral!)
    }
}