//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import UIKit

class Terminal {
    var escapeSequence: EscapeSequence
    var screen: Screen
    var textBuffer = [[textAttr]]()

    var diffScreenAndBuffSize = 0       // スクリーンのサイズとバッファサイズの差分
    var hasNext = false                 // 行が次に続くか
    var currColor = UIColor.black       // 現在の色を記憶
    var writingRow = 0 {                 // 現在書き込み中のバッファの行
        didSet {
            screen.c.y = writingRow - diffScreenAndBuffSize + 1
        }
    }

    init(screenColumn: Int, screenRow: Int){
        self.screen = Screen(screenColumn: screenColumn, screenRow: screenRow)
        self.escapeSequence = EscapeSequence(term: self)
    }

    // textview内のカーソル位置に文字を書き込む関数
    func writeText(_ text: String) {
        if text == "\r\n" {
            if textHasPrevious() && textBuffer[writingRow].count == 1 { // 行の1文字目のとき
                textBuffer[writingRow][0].hasPrevious = false           // 違う行判定にする
                return
            }
            if writingRow == textBuffer.count {            // カーソルがbufferサイズとカーソル位置が等しいとき
                textBuffer.append([textAttr(char: " ", color: currColor)])  // 次のテキスト記憶を準備
            }
            if curIsRowEnd() {  // カーソルが文末のとき
                if textBuffer[writingRow].count == 1 {  // 文字がないとき
                    textBuffer[writingRow][screen.c.x - 1].char = " "
                }
                else {
                    textBuffer[writingRow].removeLast() // カーソル文字を削除する
                }
            }
            writingRow += 1 // 書き込む位置をずらす
            screen.c.x = 1
            textBuffer[writingRow][screen.c.x - 1].hasPrevious = false      // 違う行判定にする

            if writingRow > diffScreenAndBuffSize + screen.screenColumn {   // カーソルが基底から数えて最大行数を超えたとき
                diffScreenAndBuffSize += 1
            }
            return
        } else if text == "\r" {      // CR(復帰)ならカーソルを行頭に移動する
            escapeSequence.escRoot(n: writingRow, m: 1, c: screen.c)
            return
        } else if text == "\n" {      // LF(改行)ならカーソルを1行下に移動する
            escapeSequence.escDown(n: 1, c: screen.c)
            if writingRow > diffScreenAndBuffSize + screen.screenColumn {
                diffScreenAndBuffSize += 1
            }
            return
        } else if text == "\t" {  // HT(水平タブ)ならカーソルを4文字ごとに飛ばす
            // 必要な空白数を計算し追加する
            let count = ((screen.c.x / 4 + 1) * 4) - screen.c.x
            for _ in 0..<count {
                writeText(" ")
            }
            return
        } else if text == "\u{08}" { // BS(後退)ならカーソルを一つ左にずらす
            escapeSequence.escLeft(n: 1, c: screen.c)
            return
        } else if text >= "\u{00}" && text <= "\u{1f}" {  // 上記以外の制御コードのとき
            // 何もせずに返る
            return
        }
        // カーソル位置に文字と色を書き込む
        textBuffer[writingRow][screen.c.x - 1].char = text
        textBuffer[writingRow][screen.c.x - 1].color = currColor
        if hasNext {    // 折り返しがあったとき
            hasNext = false
            textBuffer[writingRow][screen.c.x - 1].hasPrevious = true
        }
        // 基底位置がずれるとき
        if writingRow == diffScreenAndBuffSize + screen.screenColumn && screen.c.x == screen.screenRow {
            diffScreenAndBuffSize += 1
        }
        if screen.c.x == screen.screenRow {     // 折り返すとき
            if writingRow == textBuffer.count { // カーソルが最後行のとき
                textBuffer.append([textAttr(char: " ", color: currColor)])
            }
            writingRow += 1
            screen.c.x = 1
            hasNext = true
        } else {    // 折り返さないとき
            if screen.c.x == textBuffer[writingRow].count { // カーソルが最後桁のとき
                textBuffer[writingRow].append(textAttr(char: " ", color: currColor))
            }
            screen.c.x += 1
        }
    }

    // 書き込み位置がバッファの最後か判断する関数
    func curIsEnd() -> Bool {
        return curIsRowEnd() && writingRow == textBuffer.count
    }

    // カーソルが行末か判断する関数
    func curIsRowEnd() -> Bool {
        return screen.c.x == textBuffer[writingRow].count
    }

    // カーソルの示す文字を取得する関数
    func getCurrChar() -> String {
        return textBuffer[writingRow][screen.c.x - 1].char
    }

    // カーソルの示す位置のhasPrevious属性を取得する関数
    func textHasPrevious() -> Bool {
        return textBuffer[writingRow][screen.c.x - 1].hasPrevious
    }

    func makeScreenText() -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        var attributes: [NSAttributedString.Key: Any]
        var char: NSMutableAttributedString

        var row = diffScreenAndBuffSize     // 基底位置を取得する
        let bias = row

        while row < bias + screen.screenColumn && row < textBuffer.count {
            for column in 0..<textBuffer[row].count {
                var backColor = UIColor.white                   // 背景色を設定する
                var foreColor = textBuffer[row][column].color  // 前景色を設定する
                if screen.c.y == row + 1 && screen.c.x ==  column + 1 {
                    backColor = UIColor.gray
                    foreColor = UIColor.white
                }
                attributes = [.backgroundColor: backColor, .foregroundColor: foreColor]                // 文字の色を設定する
                char = NSMutableAttributedString(string: textBuffer[row][column].char, attributes: attributes) // 文字に色を登録する
                text.append(char)
            }
            attributes = [.backgroundColor: UIColor.white, .foregroundColor: UIColor.white]            // 改行を追加する
            char = NSMutableAttributedString(string: "\n", attributes: attributes)
            text.append(char)
            row += 1            // 次の行の準備
        }
    }
}