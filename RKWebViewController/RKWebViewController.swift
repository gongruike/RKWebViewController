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

open class RKWebViewController: UIViewController {

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
    
    open var currentURL: URL? {
        return webView.url
    }
    
    open var request: URLRequest
    
    open var webViewConfiguration: WKWebViewConfiguration?

    open lazy var webView: WKWebView! = {
        //
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        //
        let wk = WKWebView(frame: CGRect.zero, configuration: configuration)
        //
        wk.translatesAutoresizingMaskIntoConstraints = false
        //
        return wk
    }()
    
    open lazy var progressView: UIProgressView! = {
        //
        let pv = UIProgressView(progressViewStyle: .default)
        //
        pv.translatesAutoresizingMaskIntoConstraints = false
        //
        pv.progressTintColor = self.progressViewTintColor
        //
        pv.trackTintColor = UIColor.clear
        //
        return pv
    }()
    
    open var progressViewTintColor: UIColor = UIColor.blue {
        didSet {
            //
            progressView.progressTintColor = progressViewTintColor
        }
    }
    
    private lazy var progressViewTopLayoutConstraint: NSLayoutConstraint = {
        //
        return NSLayoutConstraint(item: self.progressView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: self.view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 0)
    }()
    
    // Toolbar items
    open lazy var backBarButtonItem: UIBarButtonItem = {
        //
        let image = self.backImage()
        //
        let back = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(onBackBarButtonItemClicked(_:)))
        return back
    }()
    
    open lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        let image = self.forwardImage()
        //
        let forward = UIBarButtonItem(image: image,
                                      style: .plain,
                                      target: self,
                                      action: #selector(onForwardBarButtonItemClicked(_:)))
        return forward
    }()
    
    open lazy var refreshBarButtonItem: UIBarButtonItem = {
        //
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh,
                                      target: self,
                                      action: #selector(onRefreshBarButtonItemClicked(_:)))
        return refresh
    }()
    
    open lazy var stopBarButtonItem: UIBarButtonItem = {
        //
        let stop = UIBarButtonItem(barButtonSystemItem: .stop,
                                   target: self,
                                   action: #selector(onStopBarButtonItemClicked(_:)))
        return stop
    }()

    /// MARK: init
    public convenience init(string: String, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
        self.init(url: URL(string: string)!, webViewConfiguration: webViewConfiguration)
    }
    
    public convenience init(url: URL, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
        self.init(request: URLRequest(url: url), webViewConfiguration: webViewConfiguration)
    }
    
    public init(request: URLRequest, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
        self.request = request
        self.webViewConfiguration = webViewConfiguration
        //
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    open func loadRequest(_ request: URLRequest) {
        //
        self.request = request
        //
        webView.load(request)
    }

    override open func viewDidLoad() {
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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    deinit {
        //
        removeWebViewObserver()
    }

    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //
        onViewWillTransitionToSize(size)
    }
    

    ///
    /// MARK: Layout
    func addLayoutConstraints() {
        //
        let webViewLayoutConstraints = [
            NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        ]
        NSLayoutConstraint.activate(webViewLayoutConstraints)
        //
        updateProgressViewTopLayoutConstraint(view.bounds.size)
        let progressViewLayoutConstraints = [
            progressViewTopLayoutConstraint,
            NSLayoutConstraint(item: progressView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2)
        ]
        NSLayoutConstraint.activate(progressViewLayoutConstraints)
    }
    
    func updateProgressViewTopLayoutConstraint(_ size: CGSize) {
        // Portrait Landscape
        // TODO
        progressViewTopLayoutConstraint.constant = (size.width < size.height) ? 64 : 32
    }
    
    func onViewWillTransitionToSize(_ size: CGSize) {
        //
        updateProgressViewTopLayoutConstraint(size)
        //
        view.setNeedsLayout()
    }
    
    ///
    /// MARK: Key-Value Observing
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        if keyPath == KeyPath.Title {
            //
            onTitleChange(change: change)
        } else if keyPath == KeyPath.Loading {
            //
            onLoadingChange(change: change)
            updateToolBarItems()
        } else if keyPath == KeyPath.CanGoBack || keyPath == KeyPath.CanGoForward {
            //
            updateToolBarItems()
        } else if keyPath == KeyPath.EstimatedProgress {
            //
            onEstimatedProgressChange(change: change)
        }
    }
    
    open func addWebViewObserver() {
        //
        webView.addObserver(self, forKeyPath: KeyPath.Title, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.Loading, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.CanGoBack, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.CanGoForward, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.EstimatedProgress, options: .new, context: nil)
    }
    
    open func removeWebViewObserver() {
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
    
    open func onTitleChange(change: [NSKeyValueChangeKey : Any]?) {
        //
        title = change?[NSKeyValueChangeKey.newKey] as? String
    }
    
    open func onLoadingChange(change: [NSKeyValueChangeKey : Any]?) {
        //
        UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
        //
        progressView.isHidden = !webView.isLoading
    }
    
    open func onEstimatedProgressChange(change: [NSKeyValueChangeKey : Any]?) {
        //
        if let progress = change?[NSKeyValueChangeKey.newKey] as? Float {
            //
            progressView.progress = progress
        }
    }
    
    
    /// ToolBar
    /// MARK: Back，Forward, Refresh, Stop
    open func updateToolBarItems() {
        //
        backBarButtonItem.isEnabled = webView.canGoBack
        //
        forwardBarButtonItem.isEnabled = webView.canGoForward
        //
        let refreshStopBarButtonItem = webView.isLoading ? stopBarButtonItem : refreshBarButtonItem
        //
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
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
        navigationController?.toolbar.barStyle = navigationController?.navigationBar.barStyle ?? .default
        navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor;
        setToolbarItems(items, animated: true)
    }
    
    open func onBackBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    open func onForwardBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    open func onRefreshBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    open func onStopBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    open func backImage() -> UIImage {
        //
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 12, height: 21), false, 0)
        
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .round
        path.lineJoinStyle = .miter
        
        path.move(to: CGPoint(x: 11, y: 1))
        path.addLine(to: CGPoint(x: 1, y: 11))
        path.addLine(to: CGPoint(x: 11, y: 20))
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //
        return image!
    }
    
    open func forwardImage() -> UIImage {
        //
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 12, height: 21), false, 0)
        
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .round
        path.lineJoinStyle = .miter
        
        path.move(to: CGPoint(x: 1, y: 1))
        path.addLine(to: CGPoint(x: 11, y: 11))
        path.addLine(to: CGPoint(x: 1, y: 20))
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //
        return image!
    }
    
}
