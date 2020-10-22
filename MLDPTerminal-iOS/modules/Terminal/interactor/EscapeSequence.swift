//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import UIKit

class EscapeSequence {
    var term: Terminal

    init(term: Terminal){
        self.term = term
    }

    // 上にn移動する関数
    // n : 変位
    func moveUp(n: Int, c: cursor) {
        term.currentRow -= (0 < c.y - n) ? n : c.y
        moveCursorY(n: -n, c: c)
    }

    // 下にn移動する関数
    // n : 変位
    func moveDown(n: Int, c: cursor) {
        term.currentRow += (c.y + n < term.screen.screenRow) ? n : term.screen.screenRow - c.y
        moveCursorY(n: n, c: c)

        if term.textBuffer.count <= term.topRow + term.screen.c.y {
            for _ in 0 ... term.topRow + term.screen.c.y - term.textBuffer.count {
                term.textBuffer.append([textAttr(char: " ", color: term.currColor, hasPrevious: false)])
            }
        }
    }

    // 右にn移動する関数
    // n : 変位
    func moveRight(n: Int, c: cursor) {
        // カーソルをずらす
        moveCursorX(n: n, c: c)

        let over = term.screen.c.x - term.textBuffer[term.currentRow].count
        if 0 < over {
            // 足りない空白を追加する
            for _ in 0 ..< over {
                term.textBuffer[term.currentRow].append(textAttr(char: " ", color: term.currColor))
                if term.textBuffer[term.currentRow].count == 1 {
                    term.textBuffer[term.currentRow][0].hasPrevious = false
                }
            }
        }
    }

    // 左にn移動する関数
    // n : 変位
    func moveLeft(n: Int, c: cursor) {
        moveCursorX(n: -n, c: c)
    }

    // n行下の先頭に移動する関数
    // n : 変位
    func moveDownToRowLead(n: Int, c: cursor) {
        moveDown(n: n, c: cursor(x: 0, y: c.y))
    }

    // n行上の先頭に移動する関数
    // n : 変位
    func moveUpToRowLead(n: Int, c: cursor) {
        moveUp(n: n, c: cursor(x: 0, y:  c.y))
    }

    // 現在位置と関係なく上からn、左からmの場所に移動する関数
    // n : 変位
    // m : 変位
    func moveCursor(n: Int, c: cursor) {
        moveRight(n: n, c: cursor(x: 0, y: c.y))
    }

    // 現在位置と関係なく上からn、左からmの場所に移動する関数
    // n : 変位
    // m : 変位
    func moveCursor(n: Int, m: Int, c: cursor) {
        let _n = n < term.screen.screenRow ? n-1 : term.screen.screenRow - 1
        let _m = m < term.screen.screenColumn ? m-1 : term.screen.screenColumn - 1
        if c.y < n {    // カーソルを下に移動させるとき
            term.currentRow -= c.y
            moveDown(n: _n, c: cursor(x: 0, y: 0))
        } else {        // カーソルを上に移動させるとき
            term.currentRow -= c.y - _n
            term.screen.c = cursor(x: 0, y: _n)
        }

        moveRight(n: _m, c: term.screen.c)
    }

    private func clearScreenFromCursor(c: cursor) {
        clearLineFromCursor(line: c.y, from: c.x)
        for y in c.y+1 ..< term.screen.screenRow {
            clearLineFromCursor(line: y, from: 0)
        }
    }

    private func clearScreenToCursor(c: cursor) {
        clearLineToCursor(line: c.y, to: c.x)
        for y in 0 ..< c.y {
            clearLineFromCursor(line: y, from: 0)
        }
    }

    // 画面消去関数(カーソル位置は移動しない)
    // n : 消去範囲指定
    // 0 : カーソルより後ろを消去する, 1 : カーソルより前を消去する, 2 : 画面全体を消去する
    func clearScreen(n: Int, c: cursor) {

        switch n {
            case 0: // カーソルより後ろを消去する
                clearScreenFromCursor(c: c)
            case 1: // カーソルより前を消去する
                clearScreenToCursor(c: c)
            case 2: // 画面全体を消去する
                clearScreenToCursor(c: cursor(x: c.x-1, y: c.y))
                clearScreenFromCursor(c: c)
            default:
                print("Invalid Number")
                return
        }
    }

    private func clearLineFromCursor(line: Int, from: Int){
        term.textBuffer[line] = Array(term.textBuffer[line].prefix(from))
        if term.textBuffer.count == 0 {
            term.textBuffer[line].append(textAttr(char: "", color: term.currColor, hasPrevious: false))
        }
    }

    private func clearLineToCursor(line: Int, to: Int){
        for i in 0 ..< to {
            term.textBuffer[line][i].char = " "
        }
    }

    // 行消去関数(カーソル位置は移動しない)
    // n : 消去範囲指定
    // 0 : カーソルより後ろを消去する, 1 : カーソルより前を消去する, 2 : 行全体を消去する
    func clearLine(n: Int, c: cursor) {
        switch n {
        case 0:
            clearLineFromCursor(line: c.y, from: c.x)
        case 1:
            clearLineToCursor(line: c.y, to: c.x)
        case 2:
            clearLineToCursor(line: c.y, to: c.x-1)
            clearLineFromCursor(line: c.y, from: c.x)
        default:
            print("Invalid Number")
            return
        }
    }

    func scrollNext(n: Int) {
        if (term.topRow + n > term.textBuffer.count){
            return
        }
        term.topRow = term.topRow + n
    }

    func scrollBack(n: Int) {
        if (term.topRow - n < 0) {
            return
        }
        term.topRow = term.topRow - n
    }

    // 文字色を変更する関数
    // color : 変更する色
    func changeColor(color: Int) {
        switch color {
        case 30:
            term.currColor = UIColor.black
        case 31:
            term.currColor = UIColor.red
        case 32:
            term.currColor = UIColor.green
        case 33:
            term.currColor = UIColor.yellow
        case 34:
            term.currColor = UIColor.blue
        case 35:
            term.currColor = UIColor.magenta
        case 36:
            term.currColor = UIColor.cyan
        case 37:
            term.currColor = UIColor.white
        default: break
        }
    }

    private func moveCursorX(n: Int, c: cursor) {
        term.screen.c = cursor(x: c.x + n, y: c.y)
    }

    private func moveCursorY(n: Int, c: cursor) {
        term.screen.c = cursor(x: c.x, y: c.y + n)
    }
}