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

    var topRow = 0       // スクリーンのサイズとバッファサイズの差分
    var hasNext = false                 // 行が次に続くか
    var currColor = UIColor.black       // 現在の色を記憶
    var currentRow = 0 {                 // 現在書き込み中のバッファの行
        didSet {
            screen.c.y = currentRow - topRow + 1
        }
    }

    init(screenColumn: Int, screenRow: Int){
        self.screen = Screen(screenColumn: screenColumn, screenRow: screenRow)
        self.escapeSequence = EscapeSequence(term: self)
    }

    // textview内のカーソル位置に文字を書き込む関数
    func writeText(_ text: String) {
        if  "\u{00}" <= text  && text <= "\u{1f}"{
            writeOperationCode(text: text)
            return
        }
        // カーソル位置に文字と色を書き込む
        textBuffer[currentRow][screen.c.x - 1].char = text
        textBuffer[currentRow][screen.c.x - 1].color = currColor
        if hasNext {    // 折り返しがあったとき
            hasNext = false
            textBuffer[currentRow][screen.c.x - 1].hasPrevious = true
        }

        if screen.c.x == screen.screenRow {     // 折り返すとき
            if currentRow == textBuffer.count { // カーソルが最後行のとき
                textBuffer.append([textAttr(char: " ", color: currColor)])
            }
            currentRow += 1
            screen.c.x = 1
            hasNext = true
        } else {    // 折り返さないとき
            if screen.c.x == textBuffer[currentRow].count { // カーソルが最後桁のとき
                textBuffer[currentRow].append(textAttr(char: " ", color: currColor))
            }
            screen.c.x += 1
        }

        if topRow + screen.screenColumn <= currentRow {
            topRow += 1
        }
    }

    func writeOperationCode(text: String){
        if text == "\r\n" {
            if textHasPrevious() && textBuffer[currentRow].count == 1 { // 行の1文字目のとき
                textBuffer[currentRow][0].hasPrevious = false           // 違う行判定にする
                return
            }
            if currentRow == textBuffer.count {            // カーソルがbufferサイズとカーソル位置が等しいとき
                textBuffer.append([textAttr(char: " ", color: currColor)])  // 次のテキスト記憶を準備
            }
            if curIsRowEnd() {  // カーソルが文末のとき
                if textBuffer[currentRow].count == 1 {  // 文字がないとき
                    textBuffer[currentRow][screen.c.x - 1].char = " "
                }
                else {
                    textBuffer[currentRow].removeLast() // カーソル文字を削除する
                }
            }
            currentRow += 1 // 書き込む位置をずらす
            screen.c.x = 1
            textBuffer[currentRow][screen.c.x - 1].hasPrevious = false      // 違う行判定にする

            if topRow + screen.screenColumn <= currentRow {   // カーソルが基底から数えて最大行数を超えたとき
                topRow += 1
            }
            return
        } else if text == "\r" {      // CR(復帰)ならカーソルを行頭に移動する
            escapeSequence.escRoot(n: currentRow, m: 1, c: screen.c)
            return
        } else if text == "\n" {      // LF(改行)ならカーソルを1行下に移動する
            escapeSequence.escDown(n: 1, c: screen.c)
            if topRow + screen.screenColumn <= topRow {
                topRow += 1
            }
            return
        } else if text == "\t" {  // HT(水平タブ)ならカーソルを4文字ごとに飛ばす
            let count = ((screen.c.x / 4 + 1) * 4) - screen.c.x
            for _ in 0 ..< count {
                writeText(" ")
            }
            return
        } else if text == "\u{08}" { // BS(後退)ならカーソルを一つ左にずらす
            escapeSequence.escLeft(n: 1, c: screen.c)
            return
        } else {  // 上記以外の制御コードのとき
            return
        }
    }

    // 書き込み位置がバッファの最後か判断する関数
    func curIsEnd() -> Bool {
        return curIsRowEnd() && currentRow == textBuffer.count
    }

    // カーソルが行末か判断する関数
    func curIsRowEnd() -> Bool {
        return screen.c.x == textBuffer[currentRow].count
    }

    // カーソルの示す文字を取得する関数
    func getCurrChar() -> String {
        return textBuffer[currentRow][screen.c.x - 1].char
    }

    // カーソルの示す位置のhasPrevious属性を取得する関数
    func textHasPrevious() -> Bool {
        return textBuffer[currentRow][screen.c.x - 1].hasPrevious
    }

    func makeScreenText() -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        var attributes: [NSAttributedString.Key: Any]
        var char: NSMutableAttributedString

        for row in topRow ..< topRow + screen.screenRow {
            if textBuffer.count <= row {
                break
            }
            for column in 0 ..< textBuffer[row].count {
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
        }
        return text
    }

    func resizeTextBuffer(newScreenRow: Int, newScreenColumn: Int){
        var newTextBuffer = [[textAttr]]()
        var writeLine = 0   // 書き込み行

        // 整形前の状態を生成
        for row in 0 ..< textBuffer.count {

            if textBuffer[row][0].hasPrevious { // 前の行に追加
                textBuffer[row][0].hasPrevious = false
                newTextBuffer[writeLine - 1] += textBuffer[row]
            } else {    // 新しく追加
                newTextBuffer.append(textBuffer[row])
            }

            let overed = newTextBuffer[writeLine].count - newScreenColumn // オーバーする文字数
            if 0 < overed {
                let usedLines = overed % newScreenColumn    // 使う行数-1
                var pos1 = newScreenColumn

                for line in 0 ... usedLines {
                    writeLine += 1
                    let pos2 = overed - (usedLines - line) * newScreenColumn
                    let overedParts = newTextBuffer[pos1 ..< pos2]
                    newTextBuffer.append(contentsOf: overedParts)
                    newTextBuffer[writeLine][0].hasPrevious = true
                    pos1 = pos2
                }
            }
            writeLine += 1
        }

        textBuffer = newTextBuffer
        screen.c = cursor(x: newTextBuffer.count, y: newTextBuffer[newTextBuffer.count-1].count)
        topRow =  newTextBuffer.count - newScreenRow >= 0 ? newTextBuffer.count - newScreenRow : 0
        currentRow = newTextBuffer.count - 1
    }
}