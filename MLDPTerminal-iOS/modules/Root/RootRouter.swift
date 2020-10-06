//
// Created by 横路海斗 on 2020/08/26.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit

class RootRouter: RootWireframe {
    func presentTerminalScreen(in window: UIWindow) {
        window.makeKeyAndVisible()
        window.rootViewController = TerminalRouter.assembleModuleNoDevice()
    }
}
