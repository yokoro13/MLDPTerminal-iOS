//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import UIKit

// 文字と色を保存をする構造体
struct textAttr {
    var char: String        // 文字を保存する変数
    var color: UIColor      // 色を保存する変数
    var hasPrevious: Bool      // 前に続く文字の有無(同一行内か)を表す変数

    // 初期化関数
    init(char: String, color: UIColor, hasPrevious: Bool = true) {
        self.char = char
        self.color = color
        self.hasPrevious = hasPrevious
    }
}

extension textAttr{

}
