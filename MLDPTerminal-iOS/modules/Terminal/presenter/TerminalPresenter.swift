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
        interactor.writePeripheral(text)
    }

    func didTapButton(_ type: ButtonContentType) {
        switch type {
        case .up:
            interactor.tapUp()
            return
        case .down:
            interactor.tapDown()
            return
        case .right:
            interactor.tapRight()
            return
        case .left:
            interactor.tapLeft()
            return
        case .ctrl:
            interactor.tapCtrl()
            return
        case .esc:
            interactor.tapEsc()
            return
        case .tab:
            interactor.tapTab()
            return
        case .scan:
            router.presentSelectDevice()
            return
        case .connect:
            interactor.tapConnect()
            return
        case .disconnect:
            interactor.tapDisconnect()
            return
        }
    }

    func didScrollUp() {
        interactor.scrollUp()
    }

    func didScrollDown() {
        interactor.scrollDown()
    }

    func didChangeScreenSize(screenWidth: Int, screenHeight: Int, textWidth: Int, textHeight: Int) {
        interactor
    }

    func didShowKeyboard() {
        <#code#>
    }

    func didHideKeyboard() {
        <#code#>
    }

    func didOrientationChange() {
        <#code#>
    }

    func didTapMenu() {
        <#code#>
    }
}

extension TerminalPresenter: TerminalInteractorOutput {
    func cursorMoved(_ cursor: cursor){
        view?.moveCursor(cursor)
    }

    func textChanged(_ text: NSMutableAttributedString){
        view?.updateScreen(text)
    }

    func menuStatusChanged(_ isShowingMenu: Bool){
        if isShowingMenu {
            view?.hideMenu(0.7)
        } else {
            view?.showMenu(0.7)
        }
    }
}