//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class TerminalPresenter: TerminalPresentation {
    weak var view: TerminalView?
    var interactor: TerminalUseCase!
    var router: TerminalWireframe!

    func viewDidLoad() {
        interactor.addObserver()
    }

    func didInputText(_ text: String) {
        interactor.writeTextToBuffer(text)
    }

    func didClickButton(_ content: ButtonContentType) {
        switch content {
        case .up:
            interactor.moveUp()
            return
        case .down:
            interactor.moveDown()
            return
        case .right:
            interactor.moveRight()
            return
        case .left:
            interactor.moveLeft()
            return
        case .ctrl:
            interactor.putCtrl()
            return
        case .esc:
            interactor.putEsc()
            return
        case .scan:
            interactor.startScan()
            return
        }
    }

    func didScrollUp() {
        interactor.scrollUp()
    }

    func didScrollDown() {
        interactor.scrollDown()
    }
}