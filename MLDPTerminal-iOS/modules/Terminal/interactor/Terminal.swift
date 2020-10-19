//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import UIKit

class Terminal {
    var escapeSequence: EscapeSequence!
    var screen: Screen
    var textBuffer = [[textAttr]]()

    private var escState: EscapeSequenceState = .none

    private var escString: String = ""

    var puttingCtrl: Bool = false

    var topRow = 0       // スクリーンのサイズとバッファサイズの差分
    var hasNext = false                 // 行が次に続くか
    var currColor = UIColor.black       // 現在の色を記憶
    var currentRow = 0 {                 // 現在書き込み中のバッファの行
        didSet {
            screen.c.y = currentRow - topRow + 1
        }
    }

    init(screenColumn: Int, screenRow: Int) {
        self.screen = Screen(screenColumn: screenColumn, screenRow: screenRow)
        textBuffer.append([textAttr(char: "", color: currColor)])
    }

    func setupEscapeSequence() {
        self.escapeSequence = EscapeSequence(term: self)
    }

    // textview内のカーソル位置に文字を書き込む関数
    func writeText(_ text: String) {
        if  "\u{00}" <= text  && text <= "\u{1f}"{
            writeOperationCode(text: text)
            return
        }

        if hasNext {    // 折り返しがあったとき
            hasNext = false
            textBuffer[currentRow][screen.c.x].hasPrevious = true
        }

        if screen.c.x == screen.screenRow {     // 折り返すとき
            if currentRow == textBuffer.count { // カーソルが最後行のとき
                textBuffer.append([textAttr(char: " ", color: currColor)])
            }
            currentRow += 1
            screen.c.x = 0
            hasNext = true
        } else {    // 折り返さないとき
            if screen.c.x == textBuffer[currentRow].count { // カーソルが行の最後
                textBuffer[currentRow].append(textAttr(char: text, color: currColor))
            } else {
                // カーソル位置に文字と色を書き込む
                textBuffer[currentRow][screen.c.x].char = text
                textBuffer[currentRow][screen.c.x].color = currColor
            }
            screen.c.x += 1
        }

        if topRow + screen.screenColumn <= currentRow {
            topRow += 1
        }
    }

    func writeOperationCode(text: String) {
        switch text {
        case "\r":      // CR(復帰)ならカーソルを行頭に移動する
            escapeSequence.moveDownToRowLead(n: 1, c: screen.c)
            return
        case "\n":       // LF(改行)ならカーソルを1行下に移動する
            escapeSequence.moveDown(n: 1, c: screen.c)
            textBuffer[currentRow][screen.c.x].hasPrevious = false      // 違う行判定にする
            if currentRow == textBuffer.count {            // カーソルがbufferサイズとカーソル位置が等しいとき
                textBuffer.append([textAttr(char: " ", color: currColor)])  // 次のテキスト記憶を準備
            }
            if screen.screenColumn <= currentRow {
                topRow += 1
            }
            return
        case "\t":  // HT(水平タブ)ならカーソルを4文字ごとに飛ばす
            let count = ((screen.c.x / 4 + 1) * 4) - screen.c.x
            for _ in 0 ..< count {
                writeText(" ")
            }
            return
        case "\u{08}":  // BS(後退)ならカーソルを一つ左にずらす
            escapeSequence.moveLeft(n: 1, c: screen.c)
            return
        default:
            return
        }
    }

    // 書き込み位置がバッファの最後か判断する関数
    func curIsEnd() -> Bool {
        curIsRowEnd() && currentRow == textBuffer.count
    }

    // カーソルが行末か判断する関数
    func curIsRowEnd() -> Bool {
        screen.c.x == textBuffer[currentRow].count
    }

    func getCurrLineText() -> String {
        var lineText: String = ""
        for x in 0 ..< textBuffer[currentRow].count {
            lineText.append(textBuffer[currentRow][x].char)
        }
        return lineText
    }

    // カーソルの示す文字を取得する関数
    func getCurrChar() -> String {
        textBuffer[currentRow][screen.c.x].char
    }

    // カーソルの示す位置のhasPrevious属性を取得する関数
    func textHasPrevious() -> Bool {
        textBuffer[currentRow][screen.c.x].hasPrevious
    }

    func makeScreenText() -> NSMutableAttributedString {
        let text: NSMutableAttributedString = NSMutableAttributedString()
        var attributes: [NSAttributedString.Key: Any]
        var char: NSMutableAttributedString

        for row in topRow ..< topRow + screen.screenRow {
            if textBuffer.count <= row {
                break
            }
            for column in 0 ..< textBuffer[row].count {
                attributes = [.backgroundColor: UIColor.white, .foregroundColor: textBuffer[row][column].color] // 文字の色を設定する
                char = NSMutableAttributedString(string: textBuffer[row][column].char, attributes: attributes) // 文字に色を登録する
                text.append(char)
            }
            attributes = [.backgroundColor: UIColor.white, .foregroundColor: UIColor.white]            // 改行を追加する
            char = NSMutableAttributedString(string: "\n", attributes: attributes)
            text.append(char)
        }
        return text
    }

    func resizeTextBuffer(newScreenRow: Int, newScreenColumn: Int) {
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

        screen.c = newTextBuffer.count > 0 ? cursor(x: newTextBuffer[writeLine - 1].count, y: newTextBuffer.count) : cursor(x: 0, y: 0)

        topRow =  newTextBuffer.count - newScreenRow >= 0 ? newTextBuffer.count - newScreenRow : 0
        currentRow = (newTextBuffer.count - 1) >= 0 ? newTextBuffer.count - 1 : 0
    }

    // ターミナルに文字を出力する
    func writeTextToBuffer(_ string : String) {
        // 複数文字届いたときは一字ずつ処理する
        for inputCharacter in string{
            let text = String(inputCharacter)

            // ASCIIコード外のとき
            if !text.isAscii() {
                return
            }

            if escState == .none && text != "\u{1b}"{
                writeText(text)
            } else {
                checkEscapeSequence(text)
            }
        }
    }

    func checkEscapeSequence(_ text: String) {
        // エスケープシーケンス
        switch escState {
        case .none:            //ステート0：エスケープシーケンスかどうか
            clearEscapeSequence()
            escState = .esc
        case .esc:            // ステート1：どの種類のエスケープシーケンスか
            escString.append(text)
            // 正しいシーケンスのとき
            if text == "[" {
                escState = .ansi
            } else if text == "?" {
                escState = .tec
            } else {
                // シーケンスではなかったとき
                clearEscapeSequence()
            }
        case .ansi:     // ステート2: ANSIがきたら実行　違えば貯める
            escString.append(text)
            if escString.isANSI() {
                print(escString)
                identifyEscapeSequence(esStr: escString)
                clearEscapeSequence()
            } else {
                if !(text.isNumeric() || text == ";") {
                    clearEscapeSequence()
                }
            }
        case .tec:    // ステート3: どのTeCエスケープシーケンスか
            if text == "s" {
                BleManager.sharedBleManager.write("\u{1b}?\(screen.screenRow),\(screen.screenColumn)s")
                clearEscapeSequence()
            } else {
                print("NO ESC_SEQ") // シーケンスではなかったとき
                clearEscapeSequence()
            }
        }
    }

    func identifyEscapeSequence(esStr: String) {
        var n: Int = 1
        var m: Int = 1

        let length = esStr.utf8.count
        let mode = String(esStr.suffix(1))

        if length != 2 {
            if mode != "H" {
                n = Int(esStr.substring(from: 1, to: length-1))!
            } else {
                let index = esStr.firstIndex(of: ";")
                let semicolonPos = esStr.distance(from: esStr.startIndex, to: index!)
                if semicolonPos != 1 {
                    n = Int(esStr.substring(from: 1, to: semicolonPos))!
                }
                if esStr.at(index: semicolonPos+1) != "H" {
                    m = Int(esStr.substring(from: semicolonPos+1, to: length-1))!
                }
            }
        }
        escapeSequence(mode: mode, n: n, m: m)
    }

    func escapeSequence(mode: String, n:Int, m:Int) {
        switch mode {
        case "A":
            escapeSequence.moveUp(n: n, c: screen.c)                              // 上にn移動する
        case "B":
            escapeSequence.moveDown(n: n, c: screen.c)                            // 下にn移動する
        case "C":
            escapeSequence.moveRight(n: n, c: screen.c)                           // 右にn移動する
        case "D":
            escapeSequence.moveLeft(n: n, c: screen.c)                            // 左にn移動する
        case "E":
            escapeSequence.moveDownToRowLead(n: n, c: screen.c)                         // n行下の先頭に移動する
        case "F":
            escapeSequence.moveUpToRowLead(n: n, c: screen.c)                           // n行上の先頭に移動する
        case "G":
            escapeSequence.moveCursor(n: n, m: m, c: screen.c)              // 左からnの場所に移動する
        case "J", "H", "f":
            escapeSequence.clearScreen(n: n-1, c: screen.c)                  // 画面を消去する
        case "K":
            escapeSequence.clearLine(n: n-1, c: screen.c)                  // 行を消去する
        case "m":
            escapeSequence.changeColor(color: n)                // 文字色を変更する
        default:
            escState = .none
        }
    }

    private func clearEscapeSequence() {
        escState = .none
        escString = ""
    }

    func toggleCtrl() {
        puttingCtrl = !puttingCtrl
    }
}