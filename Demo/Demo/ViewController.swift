//
//  ViewController.swift
//  Demo
//
//  Created by gongruike on 2016/12/27.
//  Copyright © 2016年 gongruike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func onPushBtnClicked(_ sender: UIButton) {
        //
        let webView = MyWebViewController(string: "http://www.baidu.com")
        show(webView, sender: nil)
    }
    
}

