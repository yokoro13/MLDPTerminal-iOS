//
// Created by 横路海斗 on 2020/10/05.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

enum BleState {
    case initializing
    case ready
    case scanning
    case trying
    case busy
    case idle
    case canceling
    case closed
    case error
}