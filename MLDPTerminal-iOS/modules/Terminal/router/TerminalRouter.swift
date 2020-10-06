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
        let view = R.storyboard.terminal.instantiateInitialViewController()
        let presenter = TerminalPresenter()
        let interactor = TerminalInteractor()
        let router = TerminalRouter()

        let navigation = UINavigationController(rootViewController: view!)

        view?.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        router.viewController = view

        return navigation
    }

    func presentSelectDevice() {
        let selectDeviceModuleViewController = SelectDeviceRouter.assembleModule()
        viewController?.navigationController?.pushViewController(selectDeviceModuleViewController, animated: true)
    }
}