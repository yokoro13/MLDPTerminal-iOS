//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class TerminalInteractor: TerminalUseCase {
    weak var output: TerminalInteractorOutput!
    private let bleManager = BleManager.sharedBleManager

    func addObserver() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(receivedData),
                name: .receivedDataNotification,
                object: nil)
    }

    @objc func receivedData(notification: NSNotification?){
        let text = notification?.userInfo!["text"] as! String
        writeTextToBuffer(text)
    }

    func writeTextToBuffer(_ text: String) {
        <#code#>
    }

    func moveUp() {
        <#code#>
    }

    func moveDown() {
        <#code#>
    }

    func moveRight() {
        <#code#>
    }

    func moveLeft() {
        <#code#>
    }

    func startScan() {
        <#code#>
    }

    func putEsc() {
        <#code#>
    }

    func putCtrl() {
        <#code#>
    }

    func scrollUp() {
        <#code#>
    }

    func scrollDown() {
        <#code#>
    }
}