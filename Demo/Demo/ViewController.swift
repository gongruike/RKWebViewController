//
//  ViewController.swift
//  Demo
//
//  Created by gongruike on 16/8/1.
//  Copyright © 2016年 gongruike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.brownColor()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPushBtnClicked(sender: UIButton) {
        
        let webViewController = RKWebViewController(string: "")
        showViewController(webViewController, sender: nil)
//        navigationController?.pushViewController(webViewController, animated: true)
    }

}

