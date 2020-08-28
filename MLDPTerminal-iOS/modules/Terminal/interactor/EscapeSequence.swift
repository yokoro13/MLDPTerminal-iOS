//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class EscapeSequence {
    var term: Terminal

    init(term: Terminal){
        self.term = term
    }

    // 上にn移動する関数
    // n : 変位
    func escUp(n: Int, c: cursor) {
        let column = c.y - 1
        escUpTop(n: n, c: c)
        escRight(n: column, c: c)
    }

    // 下にn移動する関数
    // n : 変位
    func escDown(n: Int, c: cursor) {
        let column = c.y - 1
        escDownTop(n: n, c: c)
        escRight(n: column, c: c)
    }

    // 右にn移動する関数
    // n : 変位
    func escRight(n: Int, c: cursor) {
        // 移動がないとき(n = 0)
        if n == 0 {
            return
        }
        // 何もないときはカーソル文字を追加
        if term.getCurrChar() == "" {
            term.textBuffer[c.x - 1].append(textAttr(char: "_", color: term.currColor, hasPrevious: false))
        }
        // カーソル文字を削除する
        if term.curIsRowEnd() {
            print("remove last")
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1][0..<term.textBuffer[c.x - 1].count - 1])
            if term.textBuffer[c.x - 1].count == 0 {
                term.textBuffer[c.x - 1] = [textAttr(char: " ", color: term.currColor, hasPrevious: false)]
            }
        }
        // カーソルをずらす
        c.y = c.y + n
        // 桁数が足りないとき
        if c.y > term.textBuffer[c.x - 1].count {
            print("column isn't enough")
            print("add spaceCount : \(c.y - term.textBuffer[c.x - 1].count - 1)")
            // 足りない空白を追加する
            for _ in 0..<c.y - term.textBuffer[c.x - 1].count - 1 {
                term.textBuffer[c.x - 1].append(textAttr(char: " ", color: term.currColor))
                // 行頭に追加したとき
                if term.textBuffer[c.x - 1].count == 1 {
                    // 情報を初期化する
                    term.textBuffer[c.x - 1][0].hasPrevious = false
                }
            }
            // カーソル文字を追加する
            term.textBuffer[c.x - 1].append(textAttr(char: "_", color: term.currColor))
        }
    }

    // 左にn移動する関数
    // n : 変位
    func escLeft(n: Int, c: cursor) {
        print("--- escLeft ---")
        print("n : \(n)")
        // 移動がないとき(n = 0)
        if n == 0 {
            return
        }
        // カーソル文字を削除する
        if term.curIsRowEnd() {
            print("remove last")
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1][0..<term.textBuffer[c.x - 1].count - 1])
            if term.textBuffer[c.x - 1].count == 0 {
                term.textBuffer[c.x - 1] = [textAttr(char: "_", color: term.currColor, hasPrevious: false)]
            }
        }
        var move = n
        // 桁数が足りないとき
        if c.y <= move {
            move = c.y - 1
        }
        // カーソルをずらす
        c.y = c.y - move
    }

    // n行下の先頭に移動する関数
    // n : 変位
    func escDownTop(n: Int, c: cursor) {
        print("--- escDownTop ---")
        print("n : \(n)")
        // カーソル文字を削除する
        if term.curIsRowEnd() {
            print("remove last")
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1][0..<term.textBuffer[c.x - 1].count - 1])
            if term.textBuffer[c.x - 1].count == 0 {
                term.textBuffer[c.x - 1] = [textAttr(char: "", color: term.currColor, hasPrevious: false)]
            }
        }
        // 行数が足りないとき
        if term.textBuffer.count - c.x < n {
            print("row isn't enough : \(n - (term.textBuffer.count - c.x))")
            // 改行を付け加える
            print("upperLimit : \(n - (term.textBuffer.count - c.x) - 1)")
            for _ in 0..<(n - (term.textBuffer.count - c.x) - 1) {
                term.textBuffer.append([textAttr(char: "", color: term.currColor, hasPrevious: false)])
            }
            // 改行とカーソル文字を追加する
            term.textBuffer.append([textAttr(char: "_", color: term.currColor, hasPrevious: false)])
        }
        // カーソルをずらす
        c.x = c.x + n
        c.y = 1
        // カーソル行が空行のとき
        if term.textBuffer[c.x - 1][0].char == "" && term.textBuffer[c.x - 1].count == 1 {
            // カーソル文字を追加する
            term.textBuffer[c.x - 1] = [textAttr(char: "_", color: term.currColor, hasPrevious: false)]
        }
    }

    // n行上の先頭に移動する関数
    // n : 変位
    func escUpTop(n: Int, c: cursor) {
        print("--- escUpTop ---")
        print("n : \(n)")
        // カーソル文字を削除する
        if term.curIsRowEnd() {
            print("remove last")
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1][0..<term.textBuffer[c.x - 1].count - 1])
            if term.textBuffer[c.x - 1].count == 0 {
                term.textBuffer[c.x - 1] = [textAttr(char: "", color: term.currColor, hasPrevious: false)]
            }
        }
        var move = n
        // 行数が足りないとき
        if c.x <= move {
            // 移動範囲を制限する
            move = c.x - 1
        }
        // カーソルをずらす
        c.x = c.x - move
        c.y = 1
        // 空文字ならカーソル文字にする
        if term.getCurrChar() == "" {
            term.textBuffer[c.x - 1][c.y - 1] = textAttr(char: "_", color: term.currColor, hasPrevious: false)
        }
        print("c.x : \(c.x)")
    }

    // 現在位置と関係なく上からn、左からmの場所に移動する関数
    // n : 変位
    // m : 変位
    func escRoot(n: Int, m: Int, c: cursor) {
        print("--- escRoot ---")
        print("n : \(n), m : \(m)")
        // カーソルを上に移動させるとき
        if c.x >= n {
            // c.x - n上の先頭に移動する
            escUpTop(n: c.x - n, c: c)
        }
        // カーソルを下に移動させるとき
        else {
            // n - c.x下の先頭に移動する
            escDownTop(n: n - c.x, c: c)
        }
        // 左からmの位置に移動する
        escRight(n: m - 1, c: c)
    }

    // 画面消去関数(カーソル位置は移動しない)
    // n : 消去範囲指定
    // 0 : カーソルより後ろを消去する, 1 : カーソルより前を消去する, 2 : 画面全体を消去する
    func escViewDelete(n: Int, c: cursor) {

        switch n {
                // カーソルより後ろを消去する
        case 0:
            // カーソル行より後ろを消去する
            term.textBuffer = Array(term.textBuffer.prefix(c.x))
            let cursorPrev = term.textBuffer[c.x - 1][c.y - 1].hasPrevious
            // カーソル行のカーソルより後ろを消去する
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1].prefix(c.y - 1))
            // カーソル文字を追加する
            term.textBuffer[c.x - 1].append(textAttr(char: "_", color: term.currColor, hasPrevious: cursorPrev))
                // カーソルより前を消去する
        case 1:
            // カーソル行より前を消去する
            for row in term.diffScreenAndBuffSize..<c.x - 1 {
                term.textBuffer[row] = [textAttr(char: "", color: term.currColor, hasPrevious: false)]
            }
            // カーソル行のカーソルより前を空白に置き換える
            for column in 0..<c.y {
                term.textBuffer[c.x - 1][column].char = " "
            }
                // 画面全体を消去する
        case 2:
            // カーソル行より後ろを消去する
            term.textBuffer = Array(term.textBuffer.prefix(c.x))
            // カーソル行のカーソルより後ろを消去する
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1].prefix(c.y))
            // カーソル行より前を消去する
            for row in term.diffScreenAndBuffSize..<c.x - 1 {
                term.textBuffer[row] = [textAttr(char: "", color: term.currColor, hasPrevious: false)]
            }
            // カーソル行のカーソルより前を空白に置き換える
            for column in 0..<c.y {
                term.textBuffer[c.x - 1][column].char = " "
            }
        default:
            print("Invalid Number")
            return
        }
    }

    // 行消去関数(カーソル位置は移動しない)
    // n : 消去範囲指定
    // 0 : カーソルより後ろを消去する, 1 : カーソルより前を消去する, 2 : 行全体を消去する
    func escLineDelete(n: Int, c: cursor) {
        switch n {
        case 0:
            let cursorPrev = term.textBuffer[c.x - 1][c.y - 1].hasPrevious
            // カーソルより後ろを消去する
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1].prefix(c.y - 1))
            // カーソル文字を追加する
            term.textBuffer[c.x - 1].append(textAttr(char: "_", color: term.currColor, hasPrevious: cursorPrev))
        case 1:
            // カーソルより前を空白に置き換える
            for column in 0..<c.y {
                term.textBuffer[c.x - 1][column].char = " "
            }
        case 2:
            // カーソルより後ろを消去する
            term.textBuffer[c.x - 1] = Array(term.textBuffer[c.x - 1].prefix(c.y))
            // カーソル前を空白に置き換える
            for column in 0..<c.y {
                term.textBuffer[c.x - 1][column].char = " "
            }
        default:
            print("Invalid Number")
            return
        }
    }
}