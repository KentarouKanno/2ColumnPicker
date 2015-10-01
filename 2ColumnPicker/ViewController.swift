//
//  ViewController.swift
//  2ColumnPicker
//
//  Created by KentarOu on 2015/10/02.
//  Copyright © 2015年 KentarOu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pickerKeyBoard: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pickerKeyBoard.inputType = .TwoColumnPicker
        pickerKeyBoard.placeholder = "選択してください。"
        //pickerKeyBoard.pickerDataArray = ["a","b","c","d","e"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

