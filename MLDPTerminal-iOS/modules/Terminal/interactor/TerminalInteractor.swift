//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class TerminalInteractor: TerminalUseCase {
    weak var output: TerminalInteractorOutput!
    private let bleManager = BleManager()

    func addObserver() {
        NotificationCenter.default.addObserver(self,
                selector: #selector(updateUI),
                name: .receivedDataNotification,
                object: nil)
    }

    @objc func updateUI() {
        print("")
    }

}