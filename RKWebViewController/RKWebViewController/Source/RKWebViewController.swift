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
        //
        static let allKeyPaths = [title, loading, canGoBack, canGoForward, estimatedProgress]
    }
    
    open var url: URL?
    
    open var webView: WKWebView
    
    open var progressView: UIProgressView
    
    open lazy var progressViewTopLayoutConstraint: NSLayoutConstraint = {
        //
        return NSLayoutConstraint(item: self.progressView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: self.view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 0)
    }()
    
    open lazy var backBarButtonItem: UIBarButtonItem = {
        //
        let back = UIBarButtonItem(image: self.backImage(),
                                   style: .plain,
                                   target: self,
                                   action: #selector(onBackBarButtonItemClicked(_:)))
        return back
    }()
    
    open lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        let forward = UIBarButtonItem(image: self.forwardImage(),
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

    open lazy var flexibleSpace: UIBarButtonItem = {
        //
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                               target: nil,
                               action: nil)
    }()
    
    // Life-cycle
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
        progressView.progressTintColor = UIColor.blue
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
    public func loadURL(_ url: URL?) {
        //
        guard let url = url else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    func onViewWillTransition(to size: CGSize,
                              with coordinator: UIViewControllerTransitionCoordinator) {
        //
        updateProgressViewTopLayoutConstraint(size: size)
    }
    
    internal func updateProgressViewTopLayoutConstraint(size: CGSize) {
        //
        if let navigationBar = navigationController?.navigationBar, !navigationBar.isHidden, navigationBar.isTranslucent {
            //
            let statusBarHeight: CGFloat = (size.width <= size.height) ? UIApplication.shared.statusBarFrame.height : 0
            let navigationBarHeight: CGFloat = navigationBar.bounds.height
            progressViewTopLayoutConstraint.constant = navigationBarHeight + statusBarHeight
        } else {
            progressViewTopLayoutConstraint.constant = 0
        }
    }
    
    // Private Methods
    private func addProgressViewLayoutConstraints() {
        //
        updateProgressViewTopLayoutConstraint(size: view.bounds.size)
        let progressViewLayoutConstraints = [
            progressViewTopLayoutConstraint,
            NSLayoutConstraint(item: progressView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2)
        ]
        NSLayoutConstraint.activate(progressViewLayoutConstraints)
    }

    // MARK: Override
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // There is a bug, when the navigationbar's isTranslucent is false.
        // everytime refresh the webview, it get offset up the navigationbar height
        coordinator.animate(alongsideTransition: nil) { (context) in
            self.onViewWillTransition(to: size,
                                      with: coordinator)
        }
    }
 
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        //
        if keyPath == KeyPath.title {
            //
            onTitleChange(change)
        } else if keyPath == KeyPath.loading {
            //
            onLoadingChange(change)
        } else if keyPath == KeyPath.canGoBack || keyPath == KeyPath.canGoForward {
            //
            onBackForwardListChange(change)
        } else if keyPath == KeyPath.estimatedProgress {
            //
            onEstimatedProgressChange(change)
        } else {
            // Call super
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
    
    // MARK: KVO
    func addWebViewObserver() {
        //
        KeyPath.allKeyPaths.forEach { (keyPath) in
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
    }
    
    func removeWebViewObserver() {
        //
        KeyPath.allKeyPaths.forEach { (keyPath) in
            webView.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    func onTitleChange(_ change: [NSKeyValueChangeKey : Any]?) {
        //
        title = change?[NSKeyValueChangeKey.newKey] as? String
    }
    
    func onLoadingChange(_ change: [NSKeyValueChangeKey : Any]?) {
        //
        UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
        //
        progressView.isHidden = !webView.isLoading
        //
        updateToolBarItems()
    }
    
    func onBackForwardListChange(_ change: [NSKeyValueChangeKey : Any]?) {
        //
        updateToolBarItems()
    }
    
    func onEstimatedProgressChange(_ change: [NSKeyValueChangeKey : Any]?) {
        //
        if let progress = change?[NSKeyValueChangeKey.newKey] as? Float {
            //
            progressView.progress = progress
        }
    }
    
    /// ToolBar
    /// MARK: Back，Forward, Refresh, Stop
    func updateToolBarItems() {
        //
        backBarButtonItem.isEnabled = webView.canGoBack
        //
        forwardBarButtonItem.isEnabled = webView.canGoForward
        //
        let refreshStopBarButtonItem = webView.isLoading ? stopBarButtonItem : refreshBarButtonItem
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
        setToolbarItems(items, animated: false)
    }
    
    func onBackBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    func onForwardBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    func onRefreshBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    func onStopBarButtonItemClicked(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    // Back、 forward images
    func backImage() -> UIImage? {
        //
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 12, height: 22), false, 0)
        
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .round
        path.lineJoinStyle = .miter
        
        path.move(to: CGPoint(x: 11, y: 1))
        path.addLine(to: CGPoint(x: 1, y: 11))
        path.addLine(to: CGPoint(x: 11, y: 21))
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //
        return image
    }
    
    func forwardImage() -> UIImage? {
        //
        guard let cgImage = backImage()?.cgImage else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .down)
    }
    
}
