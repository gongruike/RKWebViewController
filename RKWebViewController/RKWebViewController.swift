//
//  RKWebViewController.swift
//  Demo
//
//  Created by gongruike on 16/8/1.
//  Copyright © 2016年 gongruike. All rights reserved.
//

import UIKit
import WebKit

public class RKWebViewController: UIViewController {

    public var url: String = ""
    
    public var webViewConfiguration: WKWebViewConfiguration?
    
    public var showToolBar: Bool = true
    
    public lazy var webView: WKWebView! = {
        //
        let configuration = WKWebViewConfiguration()
        //
        let awebView = WKWebView(frame: CGRect.zero, configuration: configuration)
        //
        awebView.navigationDelegate = self
        //
        awebView.UIDelegate = self
        //
        return awebView
    }()
    
    lazy var loadingIndicatorView: UIActivityIndicatorView = {
        //
        let activityIndicatorView = UIActivityIndicatorView()
        //
        activityIndicatorView.activityIndicatorViewStyle = .WhiteLarge
        //
        activityIndicatorView.hidesWhenStopped = true
        //
        activityIndicatorView.center = self.view.center
        //
        self.view.addSubview(activityIndicatorView)
        //
        return activityIndicatorView
    }()
    
    public lazy var backBarButtonItem: UIBarButtonItem = {
       //
        let back = UIBarButtonItem(barButtonSystemItem: .Done,
                                   target: self,
                                   action: #selector(onBackBarButtonItemClicked(_:)))
        return back
    }()
    
    public lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        let forward = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                      target: self,
                                      action: #selector(onForwardBarButtonItemClicked(_:)))
        return forward
    }()
    
    public lazy var refreshBarButtonItem: UIBarButtonItem = {
        //
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                      target: self,
                                      action: #selector(onRefreshBarButtonItemClicked(_:)))
        return refresh
    }()
    
    public lazy var actionBarButtonItem: UIBarButtonItem = {
        //
        let action = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                     target: self,
                                     action: #selector(onRefreshBarButtonItemClicked(_:)))
        return action
    }()
    
    // init
    
    public init(url: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        //
        self.view = self.webView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()



    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    deinit {
        //
        webView.removeObserver(self, forKeyPath: "")
        //
        webView.removeObserver(self, forKeyPath: "")
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public override func observeValueForKeyPath(keyPath: String?,
                                                ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {
        //
        if keyPath == "" {
            
        } else {
            
        }
    }
    
}

public extension RKWebViewController {
   
    func observeWKWebView() {
        //
        webView.addObserver(self, forKeyPath: "", options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: "", options: .New, context: nil)
    }
    
    func buildWebView() -> WKWebView {
        return WKWebView()
    }
    
    //
    func backImage() -> UIImage {
        return UIImage()
    }
    
    func forwardImage() -> UIImage {
        return UIImage()
    }
    
    func temp() {
        let top = NSLayoutConstraint(item: webView,
                                     attribute: .Top,
                                     relatedBy: .Equal,
                                     toItem: view,
                                     attribute: .Top,
                                     multiplier: 1,
                                     constant: 0)
        
        let left = NSLayoutConstraint(item: webView,
                                      attribute: .Left,
                                      relatedBy: .Equal,
                                      toItem: view,
                                      attribute: .Left,
                                      multiplier: 1,
                                      constant: 0)
        
        let bottom = NSLayoutConstraint(item: webView,
                                        attribute: .Bottom,
                                        relatedBy: .Equal,
                                        toItem: view,
                                        attribute: .Bottom,
                                        multiplier: 1,
                                        constant: 0)
        
        let right = NSLayoutConstraint(item: webView,
                                       attribute: .Right,
                                       relatedBy: .Equal,
                                       toItem: view,
                                       attribute: .Right,
                                       multiplier: 1,
                                       constant: 0)
        
        webView.addConstraints([top, left, bottom, right])
    }
    
}

public extension RKWebViewController {
    //
    func onBackBarButtonItemClicked(sender: UIBarButtonItem) {
        
    }
    
    func onForwardBarButtonItemClicked(sender: UIBarButtonItem) {
        
    }

    func onRefreshBarButtonItemClicked(sender: UIBarButtonItem) {
        
    }
    
    func onActionBarButtonItemClicked(sender: UIBarButtonItem) {
        
    }
}

extension RKWebViewController: WKNavigationDelegate {
    
}

extension RKWebViewController: WKUIDelegate {
    
}

extension RKWebViewController: WKScriptMessageHandler {
    
    public func userContentController(userContentController: WKUserContentController,
                                      didReceiveScriptMessage message: WKScriptMessage) {
        //
    }
    
}

