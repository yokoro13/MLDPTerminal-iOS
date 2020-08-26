//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
