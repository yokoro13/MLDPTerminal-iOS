//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import UIKit

class Terminal {
    var escapeSequence: EscapeSequence!
    var screen: Screen
    private var textBuffer = [[textAttr]]()

    private var escState: EscapeSequenceState = .none
    private var escString: String = ""

    var puttingCtrl: Bool = false

    var topRow = 0       // スクリーンのサイズとバッファサイズの差分
    var hasNext = false                 // 行が次に続くか
    var currColor = UIColor.black       // 現在の色を記憶
    var currentRow = 0 {                 // 現在書き込み中のバッファの行
        didSet {
            screen.c.y = currentRow - topRow
        }
    }

    init(screenColumn: Int, screenRow: Int) {
        self.screen = Screen(screenColumn: screenColumn, screenRow: screenRow)
        textBuffer.append([textAttr(char: "", color: currColor)])
    }

    func setupEscapeSequence() {
        self.escapeSequence = EscapeSequence(term: self)
    }

    func writeOneCharToBuffer(_ char: String, x: Int, y: Int) {
        textBuffer[y][x].char = char
    }

    func addSpace(line: Int) {
        textBuffer[line].append(textAttr(char: " ", color: currColor))
    }

    func addNewLine() {
        textBuffer.append([textAttr(char: " ", color: currColor, hasPrevious: false)])
    }

    // ターミナルに文字を出力する
    func writeTextToBufferAtCursor(_ string : String) {
        // 複数文字届いたときは一字ずつ処理する
        for inputCharacter in string {
            let text = String(inputCharacter)

            // ASCIIコード外のとき
            if !text.isAscii() {
                return
            }

            if escState == .none && text != "\u{1b}"{
                writeTextAtCursor(text)
            } else {
                checkEscapeSequence(text)
            }
        }
    }

    // textview内のカーソル位置に文字を書き込む関数
    private func writeTextAtCursor(_ text: String) {
        if  "\u{00}" <= text && text <= "\u{1f}"{
            writeOperationCode(text: text)
            return
        }

        //print("cursor: (\(screen.c.x), \(screen.c.y))")
        //print("topRow: \(topRow)")
        //print("currentRow: \(currentRow)")

        if screen.c.x == screen.screenColumn - 1 {     // 折り返すとき
            textBuffer[currentRow].append(textAttr(char: text, color: currColor))
            if currentRow == textBuffer.count - 1 { // カーソルが最後行のとき
                textBuffer.append([textAttr(char: " ", color: currColor, hasPrevious: true)])
            }
            currentRow += 1
            screen.c.x = 0
        } else {    // 折り返さないとき
            if screen.c.x == textBuffer[currentRow].count { // カーソルが行の最後
                textBuffer[currentRow].append(textAttr(char: text, color: currColor, hasPrevious: false))
            }
            screen.c.x += 1
        }

        if topRow + screen.screenRow <= currentRow {
            topRow += 1
        }
    }

    private func writeOperationCode(text: String) {
        switch text {
        case "\r\n":
            print("********CRLF*******")
            escapeSequence.moveDownToRowLead(n: 1, c: screen.c)
            if screen.screenRow <= currentRow {
                topRow += 1
            }
            if textBuffer.count <= currentRow {
                textBuffer.append([textAttr(char: " ", color: currColor, hasPrevious: false)])
            }
            return
        case "\r":      // CR(復帰)ならカーソルを行頭に移動する
            // escapeSequence.moveDownToRowLead(n: 1, c: screen.c)
            screen.c.x = 0
            return
        case "\n":       // LF(改行)ならカーソルを1行下に移動する
            print("********LF*******")
            escapeSequence.moveDown(n: 1, c: screen.c)
            // screen.c.x = 0
            if screen.screenRow <= currentRow {
                topRow += 1
            }
            return
        case "\t":  // HT(水平タブ)ならカーソルを4文字ごとに飛ばす
            let count = 4 - 4 % screen.c.x
            for _ in 0 ..< count {
                writeTextAtCursor(" ")
            }
            return
        case "\u{08}":  // BS(後退)ならカーソルを一つ左にずらす
            escapeSequence.moveLeft(n: 1, c: screen.c)
            return
        default:
            return
        }
    }

    func getLineText(line: Int) -> [textAttr] {
        return textBuffer[line]
    }

    func getCurrLineText() -> String {
        var lineText: String = ""
        for x in 0 ..< textBuffer[currentRow].count {
            lineText.append(textBuffer[currentRow][x].char)
        }
        return lineText
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
                attributes = [.backgroundColor: UIColor.white, .foregroundColor: textBuffer[row][column].color, .font: font] // 文字の色を設定する
                if topRow + screen.c.y == row && screen.c.x ==  column {
                    attributes = [.backgroundColor:UIColor.gray, .foregroundColor: UIColor.white, .font: font]
                }
                char = NSMutableAttributedString(string: textBuffer[row][column].char, attributes: attributes) // 文字に色を登録する
                text.append(char)
            }
            attributes = [.backgroundColor: UIColor.white, .foregroundColor: UIColor.white, .font: font]            // 改行を追加する
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

    private func checkEscapeSequence(_ text: String) {
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

    private func identifyEscapeSequence(esStr: String) {
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

    private func escapeSequence(mode: String, n:Int, m:Int) {
        switch mode {
        case "A":
            escapeSequence.moveUp(n: n, c: screen.c)                // 上にn移動する
        case "B":
            escapeSequence.moveDown(n: n, c: screen.c)              // 下にn移動する
        case "C":
            escapeSequence.moveRight(n: n, c: screen.c)             // 右にn移動する
        case "D":
            escapeSequence.moveLeft(n: n, c: screen.c)              // 左にn移動する
        case "E":
            escapeSequence.moveDownToRowLead(n: n, c: screen.c)     // n行下の先頭に移動する
        case "F":
            escapeSequence.moveUpToRowLead(n: n, c: screen.c)       // n行上の先頭に移動する
        case "G":
            escapeSequence.moveCursor(n: n, c: screen.c)      // 左からnの場所に移動する
        case "H", "f":
            escapeSequence.moveCursor(n: n, m: m, c: screen.c)      // 左からnの場所に移動する
        case "J":
            escapeSequence.clearScreen(n: n-1, c: screen.c)         // 画面を消去する
        case "K":
            escapeSequence.clearLine(n: n-1, c: screen.c)           // 行を消去する
        case "m":
            escapeSequence.changeColor(color: n)                    // 文字色を変更する
        default:
            escState = .none
        }
    }

    func getTotalLineCount() -> Int {
        return textBuffer.count
    }

    func getLineTextCount(line: Int) -> Int {
        return textBuffer[line].count
    }

    private func clearEscapeSequence() {
        escState = .none
        escString = ""
    }

    func toggleCtrl() {
        puttingCtrl = !puttingCtrl
    }
}