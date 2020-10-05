//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class TerminalInteractor: TerminalUseCase {

    weak var output: TerminalInteractorOutput!
    private let bleManager = BleManager.sharedBleManager
    private var term: Terminal!

    func addObserver() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(receivedData),
                name: .receivedDataNotification,
                object: nil)
    }


    func setupTerminal(screenColumn: Int, screenRow: Int) {
        term = Terminal(screenColumn: screenColumn, screenRow: screenRow)
    }

    @objc func receivedData(notification: NSNotification?){
        let text = notification?.userInfo!["text"] as! String
        writeTextToBuffer(text)
    }

    func writeTextToBuffer(_ text: String){
        term.writeTextToBuffer(text)
    }

    func changeScreenSize(newScreenColumnSize: Int, newScreenRowSize: Int) {
        print("--- onOrientationChange ---")
        term.resizeTextBuffer(newScreenRow: newScreenRowSize, newScreenColumn: newScreenColumnSize)
        term.screen.screenColumn = newScreenColumnSize
        term.screen.screenRow = newScreenRowSize
    }

    func writePeripheral(_ message: String) {
        bleManager.write(message)
    }

    func tapUp() {
        writePeripheral("\u{1b}[A")
    }

    func tapDown() {
        writePeripheral("\u{1b}[B")
    }

    func tapRight() {
        writePeripheral("\u{1b}[C")
    }

    func tapLeft() {
        writePeripheral("\u{1b}[D")
    }

    func tapScan() {
        // nothing
    }

    func tapEsc() {
        writePeripheral("\u{1b}")
    }

    func tapCtrl() {
        // ctrlKey.toggle()
    }

    func tapTab() {
        writePeripheral("\t")
    }

    func scrollUp() {
        // 下にスクロールできるとき
        if term.topRow < term.textBuffer.count - term.screen.screenColumn && term.topRow > -1 {
            // 基底位置を下げる
            term.topRow += 1
            output.textChanged(term.makeScreenText())
        }
    }

    func scrollDown() {
        // 上にスクロールできるとき
        if term.topRow > 0 {
            // 基底位置を上げる
            term.topRow -= 1
            output.textChanged(term.makeScreenText())
        }
    }

    func tapConnect() {

    }

    func tapDisconnect() {
        print("--- disconnect button tapped ---")

        // ペリフェラルと接続されていないとき
        if bleManager.state == .closed {
            return
        }
    }

    func showKeyboard(keyboardHeight: Int) {

        // キーボードの高さだけ基底位置を下げる
        term.topRow += keyboardHeight
        // 基底位置を下げすぎたとき
        if term.topRow > term.textBuffer.count - term.screen.screenColumn {
            // 基底位置を上げる
            term.topRow = term.textBuffer.count - term.screen.screenColumn
            // 基底位置の上限を定める
            if term.topRow < 0 {
                term.topRow = 0
            }
        }
        // カーソルが表示範囲から外れたとき
        if term.screen.c.y < term.topRow + 1 {
            term.topRow = term.screen.c.y  - 1
        } else if term.screen.c.y > term.topRow + term.screen.screenColumn {
            term.topRow = term.screen.c.y - term.screen.screenColumn
        }
        // 書き込み位置を表示する
        output.textChanged(term.makeScreenText())
        // スクロール基底を初期化する
        term.topRow = -1
    }

    func hideKeyboard(keyboardHeight: Int) {
        print("--- keyboardWillHide ---")

        // キーボードの高さだけ基底位置を上げる
        term.topRow -= keyboardHeight
        // 基底位置の上限を定める
        if term.topRow < 0 {
            term.topRow = 0
        }
        // カーソルが表示範囲から外れたとき
        if term.screen.c.y < term.topRow + 1 {
            term.topRow = term.screen.c.y - 1
        } else if term.screen.c.y > term.topRow + term.screen.screenColumn {
            term.topRow = term.screen.c.y - term.screen.screenColumn
        }
        // 書き込み位置を表示する(キーボードが消えることで下に余白ができるのを防ぐための場合分け)
        // スクロールしていたとき
        if term.topRow > -1 && term.textBuffer.count - term.topRow > term.screen.screenColumn {
            output.textChanged(term.makeScreenText())
        }
        // スクロールしていないとき
        else {
            // 表示する
            output.textChanged(term.makeScreenText())
            // スクロール基底を初期化する
            term.topRow = -1
        }
    }

    private var isShowingMenu: Bool = false

    func tapMenu() {
        print("--- menu button tapped ---")
        isShowingMenu = !isShowingMenu
        output.menuStatusChanged(isShowingMenu)
    }
}