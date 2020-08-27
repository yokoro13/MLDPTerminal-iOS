//
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

struct Screen {
    var screenColumn : Int
    var screenRow : Int

    var c: cursor = cursor(x: 0, y: 0){
        didSet{
            if oldValue.x > screenColumn {
                c.x = screenColumn
            }
            if oldValue.y > screenRow {
                c.y = screenRow
            }
        }
    }

    init(screenColumn: Int, screenRow: Int){
        self.screenColumn = screenColumn
        self.screenRow = screenRow
    }
}