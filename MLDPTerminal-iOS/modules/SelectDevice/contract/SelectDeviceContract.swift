//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

protocol SelectDeviceView: IndicatableView {
    var presenter: SelectDevicePresentation! { get set }
}

protocol SelectDevicePresentation: class {
    var view: SelectDeviceView? { get set }
    var interactor: SelectDeviceUseCase! { get set }
    var router: SelectDeviceWireFrame! { get set }

    func didSelectDevice()
}

protocol SelectDeviceUseCase: class {
    var output : SelectDeviceInteractorOutput! { get set }

    func scanDevice()
}

protocol SelectDeviceInteractorOutput: class {
}

protocol SelectDeviceWireFrame: class {
    var viewController : UIViewController? { get set }

    func presentTerminal()

    static func assembleModule() -> UIViewController
}