//
//  RKWebViewController.swift
//  Demo
//
//  Created by gongruike on 16/8/1.
//  Copyright © 2016年 gongruike. All rights reserved.
//

import UIKit
import WebKit

private let WKWebViewTitleKeyPath           = ""
private let WKWebViewCanGoBackKeyPath       = ""
private let WKWebViewLoadingKeyPath         = ""
private let WKWebViewProgressKeyPath        = ""

public class RKWebViewController: UIViewController {

    private struct Keys {
        static let a = ""
    }
    
    public var request: NSURLRequest
    
    public var webViewConfiguration: WKWebViewConfiguration?
    // Only Effect On iPhone. Default is false
    public var hideToolBar: Bool = false
    
    public lazy var webView: WKWebView! = {
        //
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        //
        let wk = WKWebView(frame: CGRect.zero, configuration: configuration)
        //
        wk.navigationDelegate = self
        //
        wk.UIDelegate = self
        //
        return wk
    }()
    
    public lazy var loadingIndicatorView: UIActivityIndicatorView = {
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
    
    public lazy var stopBarButtonItem: UIBarButtonItem = {
        //
        let stop = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                   target: self,
                                   action: #selector(onStopBarButtonItemClicked(_:)))
        return stop
    }()
    
    public lazy var actionBarButtonItem: UIBarButtonItem = {
        //
        let action = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                     target: self,
                                     action: #selector(onRefreshBarButtonItemClicked(_:)))
        return action
    }()
    
    public static let BackImage: UIImage = {
       return UIImage()
    }()
    
    public static let ForwardImage: UIImage = {
        return UIImage()
    }()
    
    // init
    public convenience init(string: String) {
        self.init(url: NSURL(string: string)!)
    }
    
    public convenience init(url: NSURL) {
        self.init(request: NSURLRequest(URL: url))
    }
    
    public init(request: NSURLRequest) {
        self.request = request
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
        
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.baidu.com")!))
        //
        updateToolBarItems()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //
        switch UI_USER_INTERFACE_IDIOM() {
        case .Phone:
            navigationController?.setToolbarHidden(hideToolBar, animated: true)
        case .Pad:
            navigationController?.setToolbarHidden(true, animated: true)
        default:
            break
        }
        
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    deinit {
        //
        removeWebViewObserver()
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
        if keyPath == "title" {
            
        } else {
            
        }
    }
    
}

public extension RKWebViewController {
   
    func observeWebView() {
        //
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: "canGoBack", options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    func removeWebViewObserver()  {
        //
        webView.removeObserver(self, forKeyPath: "title")
        //
        webView.removeObserver(self, forKeyPath: "loading")
        //
        webView.removeObserver(self, forKeyPath: "canGoBack")
        //
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    func backImage() -> UIImage {
        //
        UIGraphicsBeginImageContextWithOptions(CGSize.zero, false, 1)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func forwardImage() -> UIImage {
        //
        UIGraphicsBeginImageContextWithOptions(CGSize.zero, false, 1)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func loadRequest(request: NSURLRequest) {
        webView.loadRequest(request)
    }
    
    func updateToolBarItems() {
        //
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace,
                                         target: nil,
                                         action: nil)
        //
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
                                            target: nil,
                                            action: nil)
        //
        let items = [
            fixedSpace,
            backBarButtonItem,
            flexibleSpace,
            forwardBarButtonItem,
            flexibleSpace,
            stopBarButtonItem,
            flexibleSpace,
            actionBarButtonItem,
            fixedSpace
        ]
        navigationController?.toolbar.barStyle = navigationController?.navigationBar.barStyle ?? .Default
        navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor;
        setToolbarItems(items, animated: true)
    }
    
}

public extension RKWebViewController {
    //
    func onBackBarButtonItemClicked(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    func onForwardBarButtonItemClicked(sender: UIBarButtonItem) {
        webView.goForward()
    }

    func onRefreshBarButtonItemClicked(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    func onStopBarButtonItemClicked(sender: UIBarButtonItem) {
        //
        webView.stopLoading()
        //
        updateToolBarItems()
    }
    
    func onActionBarButtonItemClicked(sender: UIBarButtonItem) {
        //
    }
}

extension RKWebViewController: WKNavigationDelegate {
    
}

extension RKWebViewController: WKUIDelegate {
    
}

extension RKWebViewController: WKScriptMessageHandler {
    
    // js post message to native
    public func userContentController(userContentController: WKUserContentController,
                                      didReceiveScriptMessage message: WKScriptMessage) {
        //
    }
    
}

