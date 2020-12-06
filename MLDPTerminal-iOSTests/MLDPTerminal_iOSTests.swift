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
            let terminal: Terminal = Terminal(screenColumn: 41, screenRow: 49)
            terminal.setupEscapeSequence()

            let dispatchGroup = DispatchGroup()

            let queue = DispatchQueue(label: "queue", qos: .userInteractive)

            var workItem : DispatchWorkItem?
            let semaphore = DispatchSemaphore(value:1)

            var timer = Timer()
            for _ in 0 ..< 1000 {
                // timer.invalidate()

                terminal.writeTextToBufferAtCursor("a")
                timer = Timer.scheduledTimer(
                        timeInterval: 0.01,
                        target: self,
                        selector: #selector(test),
                        userInfo: nil,
                        repeats: false
                )
                // terminal.asyncMakeScreen()
            }
        }
    }

    @objc func test(){
        print("tset")
    }

    func testTerminalInit() {
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 0))
    }

    func testWriteText() {
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        // input text
        terminal.writeTextToBufferAtCursor("aaaa")
        let currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "aaaa")
        XCTAssertEqual(terminal.screen.c, cursor(x: 4, y: 0))
    }

    func testWriteTextLF() {
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        // input LF
        terminal.setupEscapeSequence()

        terminal.writeTextToBufferAtCursor("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        terminal.writeTextToBufferAtCursor("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))
        let currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")
    }

    func testWriteTextWarp() {
        let terminal: Terminal = Terminal(screenColumn: 2, screenRow: 20)
        terminal.setupEscapeSequence()
        terminal.writeTextToBufferAtCursor("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 0))
        var currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")

        terminal.writeTextToBufferAtCursor("aa")

        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))
        currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")
    }

    func testWriteTextTopRow() {
        let terminal: Terminal = Terminal(screenColumn: 2, screenRow: 3)
        terminal.setupEscapeSequence()
        terminal.writeTextToBufferAtCursor("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        terminal.writeTextToBufferAtCursor("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 2))

        terminal.writeTextToBufferAtCursor("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 2))

        var currRow = terminal.currentRow
        var topRow = terminal.topRow

        XCTAssertEqual(currRow, 3)
        XCTAssertEqual(topRow, 1)


        terminal.writeTextToBufferAtCursor("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 2))
        var currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")

        terminal.writeTextToBufferAtCursor("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 2))
        currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, " ")

        currRow = terminal.currentRow
        topRow = terminal.topRow

        XCTAssertEqual(currRow, 4)
        XCTAssertEqual(topRow, 2)
    }

    func testEscapeSequence() {
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        terminal.setupEscapeSequence()
        let ESC_HEAD = "\u{1b}["

        // right
        terminal.writeTextToBufferAtCursor(ESC_HEAD + "C")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 0))

        // down
        terminal.writeTextToBufferAtCursor(ESC_HEAD + "B")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))

        // left
        terminal.writeTextToBufferAtCursor(ESC_HEAD + "D")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        // up
        terminal.writeTextToBufferAtCursor(ESC_HEAD + "A")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 0))

        terminal.writeTextToBufferAtCursor(ESC_HEAD + "9;4H")
        XCTAssertEqual(terminal.screen.c, cursor(x: 3, y: 8))
    }

    func testAddManyText() {
        let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)
        terminal.setupEscapeSequence()
        for _ in 0 ..< 100 {
            terminal.writeTextToBufferAtCursor("aaaaaa")
        }
    }

    func testAddLF() {
        let terminal: Terminal = Terminal(screenColumn: 1, screenRow: 20)
        terminal.setupEscapeSequence()
        for _ in 0 ..< 100 {
            terminal.writeTextToBufferAtCursor("aaaaaa")
        }
        terminal.writeTextToBufferAtCursor("\r\n")
    }

    func testResizeTextBuffer() {
        let terminal: Terminal = Terminal(screenColumn: 20, screenRow: 20)
        terminal.setupEscapeSequence()

        terminal.writeTextToBufferAtCursor("aaaaaa")

        terminal.resizeTextBuffer(newScreenRow: 1, newScreenColumn: 1)
        var currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")

        XCTAssertEqual(terminal.topRow, 5)
        XCTAssertEqual(terminal.currentRow, 5)

        terminal.resizeTextBuffer(newScreenRow: 20, newScreenColumn: 20)
        currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "aaaaaa")

        XCTAssertEqual(terminal.topRow, 0)
        XCTAssertEqual(terminal.currentRow, 0)
    }
}
