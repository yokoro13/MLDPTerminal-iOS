//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class SelectDeviceInteractor: SelectDeviceUseCase {

    weak var output: SelectDeviceInteractorOutput!

    var bleManager: BleManager = BleManager.sharedBleManager

    func addObserver() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(deviceDiscover),
                name: .discoveredDeviceNotification,
                object: nil)
    }

    @objc func deviceDiscover(notification: NSNotification?) {
        let device = notification?.userInfo!["device"] as! BleDevice
        self.output.deviceDiscovered(device)
    }

    func scanDevice() {
        bleManager.scanDevice()
    }

    func setDevice(device: BleDevice) {
        bleManager.currentPeripheral = device.peripheral
    }

    func connect(device: BleDevice) {
        bleManager.connect(peripheral: device.peripheral)
    }
}