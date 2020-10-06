//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class TerminalRouter: TerminalWireframe {
    weak var viewController: UIViewController?

    static func assembleModule(_ device: BleDevice) -> UIViewController {
        let view = R.storyboard.terminal.terminalViewController()
        let presenter = TerminalPresenter()
        let interactor = TerminalInteractor()
        let router = TerminalRouter()
        let navigation = UINavigationController(rootViewController: view!)

        view?.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.bleDevice = device

        interactor.output = presenter

        router.viewController = view

        return navigation
    }

    static func assembleModuleNoDevice() -> UIViewController {
        let view = R.storyboard.terminal.terminalViewController()
        let presenter = TerminalPresenter()
        let interactor = TerminalInteractor()
        let router = TerminalRouter()
        let navigation = UINavigationController(rootViewController: view!)
        navigation.navigationBar.isHidden = true
        view?.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        router.viewController = view

        return navigation
    }

    func presentSelectDevice() {
        print("--- presentSelectDevice ---")
        let selectDeviceModuleViewController = SelectDeviceRouter.assembleModule()
        viewController?.present(selectDeviceModuleViewController, animated: true)
    }
}