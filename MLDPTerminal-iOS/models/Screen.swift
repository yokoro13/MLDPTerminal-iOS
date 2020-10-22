//c
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

struct cursor {
    var x : Int
    var y : Int
    init(x: Int, y: Int){
        self.x = x
        self.y = y
    }
}

extension cursor: Equatable {
    static func ==(lhs: cursor, rhs: cursor) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

class Screen {
    var screenColumn : Int
    var screenRow : Int

    var c: cursor = cursor(x: 0, y: 0){
        didSet{
            if oldValue.x >= screenColumn {
                c.x = screenColumn - 1
            }
            if oldValue.x < 0 {
                c.x = 0
            }
            if oldValue.y >= screenRow {
                c.y = screenRow - 1
            }
            if oldValue.y < 0 {
                c.y = 0
            }
        }
    }

    init(screenColumn: Int, screenRow: Int){
        self.screenColumn = screenColumn
        self.screenRow = screenRow
    }
}