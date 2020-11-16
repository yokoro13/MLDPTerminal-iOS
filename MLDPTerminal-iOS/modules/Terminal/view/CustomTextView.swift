//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    var showingCursor: cursor = cursor(x: 0, y: 0)

    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }

    override func draw(_ rect: CGRect) {
        let textHeight = " ".getStringHeight(font!)
        let textWidth = " ".getStringWidth(font!)

        let rectangle = UIBezierPath(
                rect: CGRect(
                        x: CGFloat(Int(textWidth) * (showingCursor.x)),
                        y: CGFloat(Int(textHeight) * (showingCursor.y+1)),
                        width: textWidth,
                        height: textHeight
                )
        )

        UIColor.gray.setFill()
        rectangle.fill()
    }
}
