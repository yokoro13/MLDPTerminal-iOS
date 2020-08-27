//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class SelectDevicePresenter: SelectDevicePresentation {

    weak var view: SelectDeviceView?
    var interactor: SelectDeviceUseCase!
    var router: SelectDeviceWireFrame!

    var discoveredDevices: [BleDevice] = []

    func viewDidLoad(){
        interactor.scanDevice()
    }

    func didSelectDevice(_ device: BleDevice) {
        interactor.connect(device: device)
        router.presentTerminal(forBleDevice: device)
    }

    func didClickCancelButton(){
        router.cancelScanDevice()
    }
}

extension SelectDevicePresenter: SelectDeviceInteractorOutput {
    func deviceDiscovered(_ device: BleDevice) {
        self.discoveredDevices.append(device)
        view?.showDevices(discoveredDevices)
    }
}