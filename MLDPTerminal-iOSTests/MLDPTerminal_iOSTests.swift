//
//  MLDPTerminal_iOSTests.swift
//  MLDPTerminal-iOSTests
//
//  Created by 横路海斗 on 2020/08/25.
//  Copyright © 2020 yokoro. All rights reserved.
//

import XCTest
@testable import MLDPTerminal_iOS

class MLDPTerminal_iOSTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testTerminalInit(){
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 0))
    }

    func testWriteText(){
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        // input text
        terminal.writeTextToBuffer("aaaa")
        let currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "aaaa")
        XCTAssertEqual(terminal.screen.c, cursor(x: 4, y: 0))
    }

    func testWriteTextLF(){
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        // input LF
        terminal.setupEscapeSequence()

        terminal.writeTextToBuffer("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        terminal.writeTextToBuffer("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))
        let currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")
    }

    func testWriteTextWarp(){
        let terminal: Terminal = Terminal(screenColumn: 2, screenRow: 20)
        terminal.setupEscapeSequence()
        terminal.writeTextToBuffer("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 0))
        var currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")

        terminal.writeTextToBuffer("aa")

        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))
        currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")
    }

    func testWriteTextTopRow(){
        let terminal: Terminal = Terminal(screenColumn: 2, screenRow: 3)
        terminal.setupEscapeSequence()
        terminal.writeTextToBuffer("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        terminal.writeTextToBuffer("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 2))

        terminal.writeTextToBuffer("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 2))

        var currRow = terminal.currentRow
        var topRow = terminal.topRow

        XCTAssertEqual(currRow, 3)
        XCTAssertEqual(topRow, 1)


        terminal.writeTextToBuffer("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 2))
        var currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")

        terminal.writeTextToBuffer("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 2))
        currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, " ")

        currRow = terminal.currentRow
        topRow = terminal.topRow

        XCTAssertEqual(currRow, 4)
        XCTAssertEqual(topRow, 2)
    }

    func testEscapeSequence(){
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        terminal.setupEscapeSequence()
        let ESC_HEAD = "\u{1b}["

        // right
        terminal.writeTextToBuffer(ESC_HEAD + "C")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 0))

        // down
        terminal.writeTextToBuffer(ESC_HEAD + "B")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))

        // left
        terminal.writeTextToBuffer(ESC_HEAD + "D")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        // up
        terminal.writeTextToBuffer(ESC_HEAD + "A")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 0))

        terminal.writeTextToBuffer(ESC_HEAD + "9;4H")
        XCTAssertEqual(terminal.screen.c, cursor(x: 3, y: 8))

    }
}
