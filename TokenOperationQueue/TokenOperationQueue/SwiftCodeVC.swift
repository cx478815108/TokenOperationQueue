//
//  SwiftCodeVC.swift
//  TokenOperationQueue
//
//  Created by 武嘉晟 on 2020/1/31.
//  Copyright © 2020 Token. All rights reserved.
//

import UIKit

class SwiftCodeVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func one() {
        TokenOperationQueue
            .shared()
            .chain_setMaxConcurrent(3)
            .chain_runOperation({
                print("1")
            })
            .chain_runOperation({
                print("2")
            })
            .chain_runOperation({
                print("3")
            })
            .chain_runOperation({
                print("4")
            })
            .chain_finish()
    }
}
