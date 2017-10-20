//
//  ViewController.swift
//  IdKeyboard
//
//  Created by 泽i on 2017/10/20.
//  Copyright © 2017年 泽i. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    let idkeyboard = IdKeyboardController()
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.inputView = idkeyboard.inputView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

