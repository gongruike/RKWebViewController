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

    private struct KeyPath {
        //
        static let Title                = "title"
        //
        static let Loading              = "loading"
        //
        static let CanGoBack            = "canGoBack"
        //
        static let CanGoForward         = "canGoForward"
        //
        static let EstimatedProgress    = "estimatedProgress"
    }
    
    public var request: NSURLRequest
    
    public var webViewConfiguration: WKWebViewConfiguration?
    //
    public var hideToolBar: Bool = false
    
    public lazy var webView: WKWebView! = {
        //
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        //
        let wk = WKWebView(frame: UIScreen.mainScreen().bounds, configuration: configuration)
        //
        wk.navigationDelegate = self
        //
        wk.UIDelegate = self
        //
        return wk
    }()
    
    public lazy var loadingIndicatorView: UIActivityIndicatorView = {
        //
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
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
        let back = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                   target: self,
                                   action: #selector(onBackBarButtonItemClicked(_:)))
        return back
    }()
    
    public lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        let forward = UIBarButtonItem(barButtonSystemItem: .Play,
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
        let stop = UIBarButtonItem(barButtonSystemItem: .Stop,
                                   target: self,
                                   action: #selector(onStopBarButtonItemClicked(_:)))
        return stop
    }()
    
    public lazy var actionBarButtonItem: UIBarButtonItem = {
        //
        let action = UIBarButtonItem(barButtonSystemItem: .Action,
                                     target: self,
                                     action: #selector(onActionBarButtonItemClicked(_:)))
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
        
        //
        updateToolBarItems()
        //
        observeWebView()
        //
        loadRequest(NSURLRequest(URL: NSURL(string: "https://www.baidu.com")!))
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
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
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
        //
        webView.stopLoading()
    }

    public override func observeValueForKeyPath(keyPath: String?,
                                                ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {
        //
        if keyPath == KeyPath.Title {
            //
            onTitleChange(change)
            //
        } else if keyPath == KeyPath.Loading {
            //
            onLoadingChange(change)
            updateToolBarItems()
            //
        } else if keyPath == KeyPath.CanGoBack || keyPath == KeyPath.CanGoForward {
            //
            updateToolBarItems()
            //
        } else if keyPath == KeyPath.EstimatedProgress {
            
        }
    }
    
}

public extension RKWebViewController {
   
    func observeWebView() {
        //
        webView.addObserver(self, forKeyPath: KeyPath.Title, options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.Loading, options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.CanGoBack, options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.CanGoForward, options: .New, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.EstimatedProgress, options: .New, context: nil)
    }
    
    func removeWebViewObserver()  {
        //
        webView.removeObserver(self, forKeyPath: KeyPath.Title)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.Loading)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.CanGoBack)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.CanGoForward)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.EstimatedProgress)
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
        
        backBarButtonItem.enabled = webView.canGoBack
        //
        forwardBarButtonItem.enabled = webView.canGoForward
        
        let refreshStopBarButtonItem = webView.loading ? stopBarButtonItem : refreshBarButtonItem
        
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
            refreshStopBarButtonItem,
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
    
    func onTitleChange(change: [String : AnyObject]?) {
        //
        title = change?[NSKeyValueChangeNewKey] as? String
    }
    
    func onLoadingChange(change: [String : AnyObject]?) {
        //
        if webView.loading {
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }
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

