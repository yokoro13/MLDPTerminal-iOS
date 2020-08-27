//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation

class Terminal {
    var screen: Screen
    var textBuffer = [[textAttr]]()

    init(screenColumn: Int, screenRow: Int){
        self.screen = Screen(screenColumn: screenColumn, screenRow: screenRow)
    }

}