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

    struct KeyPath {
        
        static let title                = "title"
        static let loading              = "loading"
        static let canGoBack            = "canGoBack"
        static let canGoForward         = "canGoForward"
        static let estimatedProgress    = "estimatedProgress"
        
        static let allKeyPaths          = [title, loading, canGoBack, canGoForward, estimatedProgress]
    }
    
    open var url: URL
    
    open var webView: WKWebView
    
    open var progressView: UIProgressView
    
    open lazy var progressViewTopLayoutConstraint: NSLayoutConstraint = {
        //
        return NSLayoutConstraint(
            item: self.progressView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
    }()
    
    open lazy var backBarButtonItem: UIBarButtonItem = {
        //
        return UIBarButtonItem(
            image: self.backImage(),
            style: .plain,
            target: self,
            action: #selector(onBackBarButtonItemClicked(_:))
        )
    }()
    
    open lazy var forwardBarButtonItem: UIBarButtonItem = {
        //
        return UIBarButtonItem(
            image: self.forwardImage(),
            style: .plain,
            target: self,
            action: #selector(onForwardBarButtonItemClicked(_:))
        )
    }()
    
    open lazy var refreshBarButtonItem: UIBarButtonItem = {
        //
        return UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(onRefreshBarButtonItemClicked(_:))
        )
    }()
    
    open lazy var stopBarButtonItem: UIBarButtonItem = {
        //
        return UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(onStopBarButtonItemClicked(_:))
        )
    }()

    open lazy var flexibleSpace: UIBarButtonItem = {
        //
        return UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
    }()
    
    // Life-cycle
    public convenience init(string: String, webViewConfiguration: WKWebViewConfiguration? = nil) {
        self.init(url: URL(string: string)!, webViewConfiguration: webViewConfiguration)
    }
    
    public init(url: URL, webViewConfiguration: WKWebViewConfiguration? = nil) {
        
        self.url = url

        self.webView = WKWebView(frame: CGRect.zero,
                                 configuration: webViewConfiguration ?? WKWebViewConfiguration())
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor.blue
        progressView.trackTintColor = UIColor.clear
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        
        view = webView
        addWebViewObserver()
        
        view.addSubview(progressView)
        addProgressViewLayoutConstraints()
        
        load(url: url)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    deinit {
        removeWebViewObserver()
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
        
        if keyPath == KeyPath.title {
            
            onTitleChange(change)
        } else if keyPath == KeyPath.loading {
            
            onLoadingChange(change)
        } else if keyPath == KeyPath.canGoBack || keyPath == KeyPath.canGoForward {
            
            onBackForwardListChange(change)
        } else if keyPath == KeyPath.estimatedProgress {
            
            onEstimatedProgressChange(change)
        } else {
            // Call super
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }

    open func load(url: URL) {
        
        webView.load(URLRequest(url: url))
    }
    
    // 变化progressViewTopLayoutConstraint
    open func updateProgressViewTopLayoutConstraint() {
        
        let size = view.bounds.size
        if let navigationBar = navigationController?.navigationBar, !navigationBar.isHidden, navigationBar.isTranslucent {
            
            let statusBarHeight: CGFloat = (size.width <= size.height) ? UIApplication.shared.statusBarFrame.height : 0
            let navigationBarHeight: CGFloat = navigationBar.bounds.height
            progressViewTopLayoutConstraint.constant = navigationBarHeight + statusBarHeight
        } else {
            progressViewTopLayoutConstraint.constant = 0
        }
    }
    
    // Private Methods
    private func addProgressViewLayoutConstraints() {
        
        updateProgressViewTopLayoutConstraint()
        let progressViewLayoutConstraints = [
            progressViewTopLayoutConstraint,
            NSLayoutConstraint(item: progressView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2)
        ]
        NSLayoutConstraint.activate(progressViewLayoutConstraints)
    }
    
    private func onViewWillTransition(to size: CGSize,
                                      with coordinator: UIViewControllerTransitionCoordinator) {
        updateProgressViewTopLayoutConstraint()
    }

}

// MARK: KVO
extension RKWebViewController {
    
    open func addWebViewObserver() {
        
        KeyPath.allKeyPaths.forEach { (keyPath) in
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
    }
    
    open func removeWebViewObserver() {
        
        KeyPath.allKeyPaths.forEach { (keyPath) in
            webView.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    open func onTitleChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        title = change?[NSKeyValueChangeKey.newKey] as? String
    }
    
    open func onLoadingChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
        
        progressView.isHidden = !webView.isLoading
        
        updateToolBarItems()
    }
    
    open func onBackForwardListChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        updateToolBarItems()
    }
    
    open func onEstimatedProgressChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        if let progress = change?[NSKeyValueChangeKey.newKey] as? Float {
            
            progressView.progress = progress
        }
    }
    
}

// ToolBar: Back，Forward, Refresh, Stop
extension RKWebViewController {

    open func updateToolBarItems() {
        
        backBarButtonItem.isEnabled = webView.canGoBack
        
        forwardBarButtonItem.isEnabled = webView.canGoForward
        
        let refreshStopBarButtonItem = webView.isLoading ? stopBarButtonItem : refreshBarButtonItem
        
        let items = [
            flexibleSpace,
            backBarButtonItem,
            flexibleSpace,
            forwardBarButtonItem,
            flexibleSpace,
            refreshStopBarButtonItem,
            flexibleSpace
        ]
        
        navigationController?.toolbar.barStyle = navigationController?.navigationBar.barStyle ?? .default
        navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor;
        setToolbarItems(items, animated: false)
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
    
}

// Back、 forward images
extension RKWebViewController {
    
    open func backImage() -> UIImage? {
        
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
        
        return image
    }
    
    open func forwardImage() -> UIImage? {
        
        guard let cgImage = backImage()?.cgImage else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .down)
    }
    
}

