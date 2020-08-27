//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class SelectDeviceRouter: SelectDeviceWireFrame {

    weak var viewController: UIViewController?

    static func assembleModule() -> UIViewController {
        fatalError("assembleModule() has not been implemented")
    }

    func presentTerminal(forBleDevice device: BleDevice) {
        let terminalViewController = TerminalRouter.assembleModule(device)
        viewController?.navigationController?.pushViewController(terminalViewController, animated: true)
    }

    func cancelScanDevice() {
        let terminalViewController = TerminalRouter.assembleModuleNoDevice()
        viewController?.navigationController?.pushViewController(terminalViewController, animated: true)
    }
}
