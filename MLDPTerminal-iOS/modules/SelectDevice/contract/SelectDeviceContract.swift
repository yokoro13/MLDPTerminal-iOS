//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

protocol SelectDeviceView: IndicatableView {
    var presenter: SelectDevicePresentation! { get set }

    func showDevices(_ devices: [BleDevice])
}

protocol SelectDevicePresentation: class {
    var view: SelectDeviceView? { get set }
    var interactor: SelectDeviceUseCase! { get set }
    var router: SelectDeviceWireFrame! { get set }

    func viewDidLoad()
    func didSelectDevice(_ device: BleDevice)
    func didClickCancelButton()
}

protocol SelectDeviceUseCase: class {
    var output : SelectDeviceInteractorOutput! { get set }

    func addObserver()
    func scanDevice()
    func deviceDiscover(notification: NSNotification?)
    func connect(device: BleDevice)
    func setDevice(device: BleDevice)
}

protocol SelectDeviceInteractorOutput: class {
    func deviceDiscovered(_ device: BleDevice)
}

protocol SelectDeviceWireFrame: class {
    var viewController : UIViewController? { get set }

    // SelectBleDevice -> Terminal への値渡し
    func presentTerminal(forBleDevice device: BleDevice)
    func cancelScanDevice()

    static func assembleModule() -> UIViewController
}