//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import Foundation
import PKHUD

// 'IndicatableView' かつ 'UIViewController' 以外はエラー
extension IndicatableView where Self: UIViewController {

    func showActivityIndicator() {
        HUD.show(.progress)
    }

    func hideActivityIndicator() {
        HUD.hide()
    }
}