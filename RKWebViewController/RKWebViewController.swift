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
        static let title                = "title"
        //
        static let loading              = "loading"
        //
        static let canGoBack            = "canGoBack"
        //
        static let canGoForward         = "canGoForward"
        //
        static let estimatedProgress    = "estimatedProgress"
    }
    
    open var url: URL?
    
    open var webView: WKWebView
    
    open var progressView: UIProgressView
    
    private lazy var progressViewTopLayoutConstraint: NSLayoutConstraint = {
        //
        return NSLayoutConstraint(item: self.progressView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: self.view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 1)
    }()
    
    //
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
        self.init(url: URL(string: string), webViewConfiguration: webViewConfiguration)
    }
    
    public init(url: URL?, webViewConfiguration: WKWebViewConfiguration? = nil) {
        //
        self.url = url
        //
        self.webView = WKWebView(frame: CGRect.zero,
                                 configuration: webViewConfiguration ?? WKWebViewConfiguration())
        //
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor.gray
        progressView.trackTintColor = UIColor.clear
        //
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    open override func loadView() {
        //
        view = webView
        addWebViewObserver()
        //
        view.addSubview(progressView)
        addProgressViewLayoutConstraints()
        //
        loadURL(url)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        navigationController?.setToolbarHidden(false, animated: false)
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

    // Public methods
    open func loadURL(_ url: URL?) {
        //
        guard let url = url else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    //
    private func addProgressViewLayoutConstraints() {
        //
//        updateProgressViewTopLayoutConstraint(view.bounds.size)
        let progressViewLayoutConstraints = [
            progressViewTopLayoutConstraint,
            NSLayoutConstraint(item: progressView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2)
        ]
        NSLayoutConstraint.activate(progressViewLayoutConstraints)
    }

    //
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //
//        onViewWillTransitionToSize(size)
    }
 
    func onViewWillTransition(to size: CGSize,
                              with coordinator: UIViewControllerTransitionCoordinator) {
//
//        updateProgressViewTopLayoutConstraint(size)
//
        view.setNeedsLayout()
    }
    
    func updateProgressViewTopLayoutConstraint(size: CGSize) {
        // Portrait Landscape
        // TODO
        progressViewTopLayoutConstraint.constant = (size.width < size.height) ? 64 : 32
    }
 
    /// MARK: KVO
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        if keyPath == KeyPath.title {
            //
            onTitleChanged(change)
        } else if keyPath == KeyPath.loading {
            //
            onLoadingChanged(change)
        } else if keyPath == KeyPath.canGoBack || keyPath == KeyPath.canGoForward {
            //
            updateToolBarItems()
        } else if keyPath == KeyPath.estimatedProgress {
            //
            onEstimatedProgressChanged(change)
        }
    }
    
    open func addWebViewObserver() {
        //
        webView.addObserver(self, forKeyPath: KeyPath.title, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.loading, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.canGoBack, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.canGoForward, options: .new, context: nil)
        //
        webView.addObserver(self, forKeyPath: KeyPath.estimatedProgress, options: .new, context: nil)
    }
    
    open func removeWebViewObserver() {
        //
        webView.removeObserver(self, forKeyPath: KeyPath.title)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.loading)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.canGoBack)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.canGoForward)
        //
        webView.removeObserver(self, forKeyPath: KeyPath.estimatedProgress)
    }
    
    open func onTitleChanged(_ change: [NSKeyValueChangeKey : Any]?) {
        //
        title = change?[NSKeyValueChangeKey.newKey] as? String
    }
    
    open func onLoadingChanged(_ change: [NSKeyValueChangeKey : Any]?) {
        //
        UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
        //
        progressView.isHidden = !webView.isLoading
        //
        updateToolBarItems()
    }
    
    func onBackForwardChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    open func onEstimatedProgressChanged(_ change: [NSKeyValueChangeKey : Any]?) {
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
