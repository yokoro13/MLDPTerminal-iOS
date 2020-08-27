//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

// View -> Presenter
protocol TerminalView: IndicatableView {
    var presenter: TerminalPresentation! { get set }

    // View の操作
    // func showSomething
}

// View <- Presenter -> Router
//           -> Interactor　   の接続
protocol TerminalPresentation: class {
    var view: TerminalView? { get set }
    var interactor: TerminalUseCase! { get set }
    var router: TerminalWireframe! { get set }

    // View からの操作処理
    func viewDidLoad()

    func didInputText(_ text: String)
    func didClickButton(_ content: ButtonContentType)
    func didScrollUp()
    func didScrollDown()
    // func doSomething()
    // didWriteText()
}

// Presenter -> Interactor -> Entity
protocol TerminalUseCase: class {
    // Entityの操作はここに記述
    var output: TerminalInteractorOutput! { get set }

    func setupTerminal(screenColumn: Int, screenRow: Int)

    func addObserver()
    func writeTextToBuffer(_ text: String)

    func moveUp()
    func moveDown()
    func moveRight()
    func moveLeft()

    func startScan()
    func putEsc()
    func putCtrl()

    func scrollUp()
    func scrollDown()
}

// Entity -> Interactor -> Presenter
protocol TerminalInteractorOutput: class {
    // Presenter に渡したい値はここに記述
    // func something()
}

// Router の接続
// 他画面との通信
protocol TerminalWireframe: class {
    var viewController: UIViewController? { get set }

    func presentSelectDevice()

    static func assembleModule(_ device: BleDevice) -> UIViewController
    static func assembleModuleNoDevice() -> UIViewController
}