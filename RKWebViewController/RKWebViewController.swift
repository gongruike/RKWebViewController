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
    
    public var backImage: UIImage?
    
    public var forwardImage: UIImage?
    
    public var request: NSURLRequest
    
    public var webViewConfiguration: WKWebViewConfiguration?
    
    public var URL: NSURL? {
        return webView.URL
    }
    
    public lazy var webView: WKWebView! = {
        //
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        //
        configuration.userContentController.addScriptMessageHandler(self, name: "")
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
        let image = self.backImage ?? RKWebViewController.BackImage
        //
        let back = UIBarButtonItem(image: image,
                                   style: .Plain,
                                   target: self,
                                   action: #selector(onBackBarButtonItemClicked(_:)))
        return back
    }()
    
    public lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        let image = self.forwardImage ?? RKWebViewController.ForwardImage
        //
        let forward = UIBarButtonItem(image: image,
                                      style: .Plain,
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
        //
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(12, 21), false, 0)
        
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Miter
        
        path.moveToPoint(CGPointMake(11, 1))
        path.addLineToPoint(CGPointMake(1, 11))
        path.addLineToPoint(CGPointMake(11, 20))
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //
        return image
    }()
    
    public static let ForwardImage: UIImage = {
        //
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(12, 21), false, 0)
        
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Miter
        
        path.moveToPoint(CGPointMake(1, 1))
        path.addLineToPoint(CGPointMake(11, 11))
        path.addLineToPoint(CGPointMake(1, 20))
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //
        return image
    }()
    
    // init
    public convenience init(string: String, webViewConfiguration: WKWebViewConfiguration? = nil) {
        self.init(url: NSURL(string: string)!, webViewConfiguration: webViewConfiguration)
    }
    
    public convenience init(url: NSURL, webViewConfiguration: WKWebViewConfiguration? = nil) {
        self.init(request: NSURLRequest(URL: url), webViewConfiguration: webViewConfiguration)
    }
    
    public init(request: NSURLRequest, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
        self.request = request
        self.webViewConfiguration = webViewConfiguration
        //
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
        addWebViewObserver()
        //
        loadRequest(request)
    }

    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //
        switch UI_USER_INTERFACE_IDIOM() {
        case .Phone:
            navigationController?.setToolbarHidden(false, animated: true)
        case .Pad:
            navigationController?.setToolbarHidden(true, animated: true)
        default:
            break
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            navigationController?.setToolbarHidden(true, animated: false)
        }
        
        webView.stopLoading()
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    deinit {
        //
        webView.stopLoading()
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
            //
        }
    }
    
}

public extension RKWebViewController {
   
    func addWebViewObserver() {
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
    
    
    func onTitleChange(change: [String : AnyObject]?) {
        //
        title = change?[NSKeyValueChangeNewKey] as? String
    }
    
    func onLoadingChange(change: [String : AnyObject]?) {
        //
        UIApplication.sharedApplication().networkActivityIndicatorVisible = webView.loading
        //
        if webView.loading {
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
    
}

public extension RKWebViewController {
    
    func loadRequest(request: NSURLRequest) {
        webView.loadRequest(request)
    }
    
    func updateToolBarItems() {
        //
        backBarButtonItem.enabled = webView.canGoBack
        //
        forwardBarButtonItem.enabled = webView.canGoForward
        //
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

