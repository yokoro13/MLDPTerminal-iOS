//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class TerminalRouter: TerminalWireframe {
    weak var viewController: UIViewController?

    static func assembleModule(_ device: BleDevice) -> UIViewController {
        fatalError("assembleModule() has not been implemented")
    }

    static func assembleModuleNoDevice() -> UIViewController {
        fatalError("assembleModuleNoDevice() has not been implemented")
    }

    func presentSelectDevice() {
        <#code#>
    }
}