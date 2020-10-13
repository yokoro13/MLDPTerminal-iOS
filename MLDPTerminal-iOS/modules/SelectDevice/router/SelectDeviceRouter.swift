//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class SelectDeviceRouter: SelectDeviceWireFrame {

    weak var viewController: UIViewController?

    static func assembleModule() -> UIViewController {
        let view = R.storyboard.selectDevice.selectDeviceViewController()
        let presenter = SelectDevicePresenter()
        let interactor = SelectDeviceInteractor()
        let router = SelectDeviceRouter()
        let navigation = UINavigationController(rootViewController: view!)
        navigation.navigationBar.isHidden = false
        view?.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        router.viewController = view
        return navigation
    }

    func presentTerminal(forBleDevice device: BleDevice) {
        // _ = TerminalRouter.assembleModule(device)
        // viewController?.present(terminalViewController, animated: true)
        viewController?.dismiss(animated: true)
    }

    func cancelScanDevice() {
        // let terminalViewController = TerminalRouter.assembleModuleNoDevice()
        viewController?.dismiss(animated: true)
    }
}
