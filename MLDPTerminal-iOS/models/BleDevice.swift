//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BleDevice : Equatable {
    var name: String?
    var peripheral: CBPeripheral

    init(name: String?, peripheral: CBPeripheral){
        self.name = name
        self.peripheral = peripheral
    }
}