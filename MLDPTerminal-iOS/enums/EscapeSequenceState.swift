//
// Created by 横路海斗 on 2020/09/01.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

enum EscapeSequenceState {
    case none
    case esc
    case ansi
    case tec
}