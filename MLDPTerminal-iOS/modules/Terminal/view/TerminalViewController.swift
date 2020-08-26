//
//  TerminalViewController.swift
//  MLDPTerminal-iOS
//
//  Created by 横路海斗 on 2020/08/25.
//  Copyright © 2020 yokoro. All rights reserved.
//

import UIKit
import CoreBluetooth

class TerminalViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        <#code#>
    }
}

extension TerminalViewController: UITextViewDelegate{

}