//
//  ViewController.swift
//  Demo
//
//  Created by gongruike on 2016/12/28.
//  Copyright © 2016年 gongruike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "RK"
    }

    @IBAction func onPushBtnClicked(_ sender: Any) {
        //
//        let webView = MyWebViewController(string: "http://www.qq.com")
        let webView = MyWebViewController(url: URL(string: "http://www.qq.com")!)

        show(webView, sender: nil)
    }

}

