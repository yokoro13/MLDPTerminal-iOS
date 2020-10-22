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
    let terminal: Terminal = Terminal(screenColumn: 48, screenRow: 20)

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
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 0))
    }

    func testWriteText(){
        // input text
        terminal.writeTextToBuffer("aaaa")
        let currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "aaaa")
        XCTAssertEqual(terminal.screen.c, cursor(x: 4, y: 0))
    }

    func testWriteLF(){
        // input LF
        terminal.setupEscapeSequence()

        terminal.writeTextToBuffer("\r\n")
        XCTAssertEqual(terminal.screen.c, cursor(x: 0, y: 1))

        terminal.writeTextToBuffer("a")
        XCTAssertEqual(terminal.screen.c, cursor(x: 1, y: 1))
        let currLineText = terminal.getCurrLineText()
        XCTAssertEqual(currLineText, "a")
    }

    func testWarp(){
        let term = Terminal(screenColumn: 2, screenRow: 10)
        term.writeTextToBuffer(<#T##string: String##Swift.String#>)
    }
}
