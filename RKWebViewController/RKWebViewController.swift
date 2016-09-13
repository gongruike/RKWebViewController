// The MIT License (MIT)
//
// Copyright (c) 2016 Ruike Gong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


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
    
    public var request: NSURLRequest
    
    public var webViewConfiguration: WKWebViewConfiguration?

    public lazy var webView: WKWebView! = {
        //
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        //
        let wk = WKWebView(frame: CGRect.zero, configuration: configuration)
        //
        wk.translatesAutoresizingMaskIntoConstraints = false
        //
        wk.UIDelegate = self
        //
        return wk
    }()
    
    public lazy var progressView: UIProgressView! = {
        //
        let pv = UIProgressView(progressViewStyle: .Default)
        //
        pv.translatesAutoresizingMaskIntoConstraints = false
        //
        pv.progressTintColor = self.progressViewTintColor
        //
        pv.trackTintColor = UIColor.clearColor()
        //
        return pv
    }()
    
    public var progressViewTintColor: UIColor = UIColor.blueColor() {
        didSet {
            //
            progressView.progressTintColor = progressViewTintColor
        }
    }
    
    private lazy var progressViewTopLayoutConstraint: NSLayoutConstraint = {
        //
        return NSLayoutConstraint(item: self.progressView,
                                  attribute: .Top,
                                  relatedBy: .Equal,
                                  toItem: self.view,
                                  attribute: .Top,
                                  multiplier: 1,
                                  constant: 0)
    }()
    
    public lazy var backBarButtonItem: UIBarButtonItem = {
        //
        let image = RKWebViewController.BackImage()
        //
        let back = UIBarButtonItem(image: image,
                                   style: .Plain,
                                   target: self,
                                   action: #selector(onBackBarButtonItemClicked(_:)))
        return back
    }()
    
    public lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        let image = RKWebViewController.ForwardImage()
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

    /// MARK: init
    public convenience init(string: String, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
        self.init(url: NSURL(string: string)!, webViewConfiguration: webViewConfiguration)
    }
    
    public convenience init(url: NSURL, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
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

    override public func viewDidLoad() {
        super.viewDidLoad()
        //
        view.addSubview(webView)
        //
        view.addSubview(progressView)
        //
        addLayoutConstraints()
        //
        addWebViewObserver()
        //
        loadRequest(request)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //
        navigationController?.setToolbarHidden(false, animated: true)
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
        } else if keyPath == KeyPath.Loading {
            //
            onLoadingChange(change)
            updateToolBarItems()
        } else if keyPath == KeyPath.CanGoBack || keyPath == KeyPath.CanGoForward {
            //
            updateToolBarItems()
        } else if keyPath == KeyPath.EstimatedProgress {
            //
            onEstimatedProgressChange(change)
        }
    }
    
    public override func viewWillTransitionToSize(size: CGSize,
                                                  withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        //
        onViewWillTransitionToSize(size)
    }
    
    /// MARK: Public Methods
    public func loadRequest(request: NSURLRequest) {
        //
        self.request = request
        //
        webView.loadRequest(request)
    }
    
    /// MARK: Layout
    func addLayoutConstraints() {
        //
        let webViewLayoutConstraints = [
            NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        ]
        NSLayoutConstraint.activateConstraints(webViewLayoutConstraints)
        //
        updateProgressViewTopLayoutConstraint(view.bounds.size)
        let progressViewLayoutConstraints = [
            progressViewTopLayoutConstraint,
            NSLayoutConstraint(item: progressView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 2)
        ]
        NSLayoutConstraint.activateConstraints(progressViewLayoutConstraints)
    }
    
    func updateProgressViewTopLayoutConstraint(size: CGSize) {
        // Portrait Landscape
        var navigationBarHeight: CGFloat = navigationController?.navigationBar.bounds.height ?? 0
        if size.width < size.height {
            // StatusBar Height
            navigationBarHeight += 20
        }
        
        progressViewTopLayoutConstraint.constant = navigationBarHeight
    }
    
    func onViewWillTransitionToSize(size: CGSize) {
        //
        updateProgressViewTopLayoutConstraint(size)
        //
        view.setNeedsUpdateConstraints()
    }
    
    /// MARK: Key-Value Observe
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
    
    func removeWebViewObserver() {
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
        progressView.hidden = !webView.loading
    }
    
    func onEstimatedProgressChange(change: [String : AnyObject]?) {
        //
        if let progress = change?[NSKeyValueChangeNewKey] as? Float {
            //
            progressView.progress = progress
        }
    }
    
    /// MARK: Back，Forward, Refresh, Stop
    func updateToolBarItems() {
        //
        backBarButtonItem.enabled = webView.canGoBack
        //
        forwardBarButtonItem.enabled = webView.canGoForward
        //
        let refreshStopBarButtonItem = webView.loading ? stopBarButtonItem : refreshBarButtonItem
        //
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
                                            target: nil,
                                            action: nil)
        //
        let items = [
            flexibleSpace,
            backBarButtonItem,
            flexibleSpace,
            forwardBarButtonItem,
            flexibleSpace,
            refreshStopBarButtonItem,
            flexibleSpace
        ]
        //
        navigationController?.toolbar.barStyle = navigationController?.navigationBar.barStyle ?? .Default
        navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor;
        setToolbarItems(items, animated: true)
    }
    
    func onBackBarButtonItemClicked(sender: UIBarButtonItem) {
        
        progressViewTintColor = UIColor.brownColor()
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
    }
    
}

extension RKWebViewController: WKUIDelegate {
    //
    public func webView(webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: () -> Void) {
        //
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { action in
            //
            completionHandler()
        }
        //
        let alertController = UIAlertController(title: webView.title, message: message, preferredStyle: .Alert)
        //
        alertController.addAction(action)
        //
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    public func webView(webView: WKWebView,
                        runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: (Bool) -> Void) {
        //
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Destructive) { action in
            completionHandler(true)
        }
        //
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Default) { action in
            //
            completionHandler(false)
        }

        //
        let alertController = UIAlertController(title: webView.title, message: message, preferredStyle: .Alert)
        //
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        //
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    public func webView(webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: (String?) -> Void) {
        //
        let alertController = UIAlertController(title: webView.title, message: prompt, preferredStyle: .Alert)
        //
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.text = defaultText
        }
        //
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Destructive) { action in
            completionHandler(alertController.textFields?.first?.text)
        }
        //
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Default) { action in
            //
            completionHandler(nil)
        }
        //
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        //
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}

public extension RKWebViewController {
    
    public static func BackImage() -> UIImage {
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
    }
    
    public static func ForwardImage() -> UIImage {
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
    }
    
}

