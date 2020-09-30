//
// Created by 横路海斗 on 2020/08/25.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import UIKit

extension String {
    // ASCII文字の判定をする関数(ASCIIコードならtrueを返す)
    // 返り値 : ASCII文字 -> true, それ以外 -> false
    func isAscii() -> Bool {
        return self <= "\u{7f}" && "\u{00}" <= self
    }

    // 数字の判定をする関数
    // 返り値 : 数字 -> true, それ以外 -> false
    func isNumeric() -> Bool {
        return "0" <= self && self <= "9"
    }

    func substring(from: Int, to: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: from)..<self.index(self.startIndex, offsetBy: to)])
    }

    func at(index: Int) -> String {
        return self.substring(from: index, to: index+1)
    }

    func isANSI() -> Bool {
        let pattern = "[A-HJKSTfm]"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.utf8.count))
        return matches.count > 0
    }

    // 文字列の高さを取得する関数
    func getStringHeight(_ font: UIFont) -> CGFloat {
        let attribute = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: attribute)
        return size.height
    }

    // 文字列の横幅を取得する関数
    func getStringWidth(_ font: UIFont) -> CGFloat {
        let attribute = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: attribute)
        return size.width
    }
}