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
        term.setupEscapeSequence()
    }

    @objc func receivedData(notification: NSNotification?){
        let text = String(data: notification?.userInfo!["text"] as! Data, encoding: .utf8) ?? "?"
        print(text)
        writeTextToBuffer(text)
        moveToInputRange()
    }

    var receiveTimer = Timer()

    func writeTextToBuffer(_ text: String){
        receiveTimer.invalidate()
        term.writeTextToBufferAtCursor(text)
        receiveTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(updateScreen),
                userInfo: nil,
                repeats: false
        )
    }

    @objc private func updateScreen(){
        output.textChanged(term.makeScreenText())
        // output.cursorMoved(term.screen.c)
    }

    func changeScreenSize(newScreenColumnSize: Int, newScreenRowSize: Int) {
        print("--- onOrientationChange ---")
        term.resizeTextBuffer(newScreenRow: newScreenRowSize, newScreenColumn: newScreenColumnSize)
        output.textChanged(term.makeScreenText())
        // output.cursorMoved(term.screen.c)
        moveToInputRange()
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

    }

    func tapEsc() {
        writePeripheral("\u{1b}")
    }

    func tapCtrl() {
        term.toggleCtrl()
    }

    func tapTab() {
        writePeripheral("\t")
    }

    func tapDel() {
        bleManager.disconnect()
    }

    func scrollUp() {
        // 下にスクロールできるとき
        if term.topRow < term.getTotalLineCount() - term.screen.screenRow {
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
        // ペリフェラルと接続されていないとき
        if bleManager.state == .closed {
            return
        }
        bleManager.disconnect()
    }

    private func moveToInputRange(){
        term.topRow = term.currentRow - term.screen.c.y

        if (term.topRow < 0) {
            term.topRow = 0
        }

        // term.screen.c.y = term.currentRow - term.topRow
    }

    func showKeyboard(keyboardHeight: Int) {
        moveToInputRange()
        output.textChanged(term.makeScreenText())
    }

    func hideKeyboard(keyboardHeight: Int) {
        moveToInputRange()
        output.textChanged(term.makeScreenText())
    }

    private var isShowingMenu: Bool = false

    func tapMenu() {
        print("--- menu button tapped ---")
        isShowingMenu = !isShowingMenu
        output.menuStatusChanged(isShowingMenu)
        output.deviceNameChanged(bleManager.currentPeripheral?.name ?? "")
    }
}