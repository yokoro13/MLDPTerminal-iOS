//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

// View -> Presenter
protocol TerminalView: class {
    var presenter: TerminalPresentation! { get set }

    func moveCursor(_ c: cursor)
    func updateScreen(_ text: NSMutableAttributedString)
    func updateConnectDeviceName(_ name: String)
    func hideMenu(_ duration:Float)
    func showMenu(_ duration:Float)
    // func showSomething
}

// View <- Presenter -> Router
//            |
//             ---> Interactor　   の接続
protocol TerminalPresentation: class {
    var view: TerminalView? { get set }
    var interactor: TerminalUseCase! { get set }
    var router: TerminalWireframe! { get set }

    // View からの操作処理
    func viewDidLoad()
    func setupTerminal(screenColumn: Int, screenRow: Int)
    func didChangeScreenSize(screenColumnSize: Int, screenRowSize: Int)

    func didInputText(_ text: String)
    func didTapButton(_ type: ButtonContentType)

    func didScrollUp()
    func didScrollDown()

    func didShowKeyboard(keyboardHeight: Int)
    func didHideKeyboard(keyboardHeight: Int)
}

// Presenter -> Interactor -> Entity
protocol TerminalUseCase: class {
    // Entityの操作はここに記述
    var output: TerminalInteractorOutput! { get set }

    func setupTerminal(screenColumn: Int, screenRow: Int)

    func addObserver()
    func writeTextToBuffer(_ text: String)
    func writePeripheral(_ message: String)

    func tapUp()
    func tapDown()
    func tapRight()
    func tapLeft()

    func tapScan()
    func tapConnect()
    func tapDisconnect()
    func tapEsc()
    func tapCtrl()
    func tapTab()
    func tapDel()

    func scrollUp()
    func scrollDown()

    func showKeyboard(keyboardHeight: Int)
    func hideKeyboard(keyboardHeight: Int)
    func changeScreenSize(newScreenColumnSize: Int, newScreenRowSize: Int)

    func tapMenu()
}

// Entity -> Interactor -> Presenter -> View
protocol TerminalInteractorOutput: class {
    // Presenter 経由で View に渡したい値はここに記述
    func cursorMoved(_ cursor: cursor)
    func textChanged(_ text: NSMutableAttributedString)
    func menuStatusChanged(_ isShowingMenu: Bool)
    func deviceNameChanged(_ name: String)
}

// Router の接続
// 他画面との通信
protocol TerminalWireframe: class {
    var viewController: UIViewController? { get set }

    func presentSelectDevice()

    static func assembleModule(_ device: BleDevice) -> UIViewController
    static func assembleModuleNoDevice() -> UIViewController
}