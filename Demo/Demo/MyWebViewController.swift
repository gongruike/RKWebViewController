//
//  MyWebViewController.swift
//  Demo
//
//  Created by gongruike on 2016/12/26.
//  Copyright © 2016年 gongruike. All rights reserved.
//

import UIKit

class MyWebViewController: RKWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.white
    }
    
    override func onTitleChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.onTitleChange(change)
    }

}
