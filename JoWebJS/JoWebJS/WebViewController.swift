//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQWebViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQWebViewController
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import WebKit


private let TitleKeyPath = "title"

private let EstimatedProgressKeyPath = "estimatedProgress"


/// An instance of `WebViewController` displays interactive web content.
public class WebViewController: UIViewController{

    // MARK: Properties

    /// Returns the web view for the controller.
    public final var webView: WKWebView {
        get {
            return _webView
        }
    }

    /// Returns the progress view for the controller.
    public final var progressBar: UIProgressView {
        get {
            return _progressBar
        }
    }

    /// The URL request for the web view. Upon setting this property, the web view immediately begins loading the request.
    public final var urlRequest: NSURLRequest {
        didSet {
            webView.loadRequest(urlRequest)
        }
    }

    /**
    Specifies whether or not to display the web view title as the navigation bar title.
    The default is `false`, which sets the navigation bar title to the URL host name of the URL request.
    */
    public final var displaysWebViewTitle: Bool = false

    
    private lazy final var _webView: WKWebView = { [unowned self] in
        // FIXME: prevent Swift bug, lazy property initialized twice from `init(coder:)`
        // return existing webView if webView already added
        let views = self.view.subviews.filter {$0 is WKWebView } as! [WKWebView]
        if views.count != 0 {
            return views.first!
        }
        


        let webView = WKWebView(frame: self.view.bounds, configuration: self.configuration)
        self.view.addSubview(webView)
        webView.addObserver(self, forKeyPath: TitleKeyPath, options: .New, context: nil)
        webView.addObserver(self, forKeyPath: EstimatedProgressKeyPath, options: .New, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        return webView
        }()

    private lazy final var _progressBar: UIProgressView = { [unowned self] in
        let progressBar = UIProgressView(progressViewStyle: .Bar)
        progressBar.backgroundColor = .clearColor()
        progressBar.trackTintColor = .clearColor()
        self.view.addSubview(progressBar)
        return progressBar
        }()

    var configuration: WKWebViewConfiguration

    private final let activities: [UIActivity]?

    // MARK: Initialization

    /**
    Constructs a new `WebViewController`.

    - parameter urlRequest:    The URL request for the web view to load.
    - parameter configuration: The configuration for the web view.
    - parameter activities:    The custom activities to display in the `UIActivityViewController` that is presented when the action button is tapped.

    - returns: A new `WebViewController` instance.
    */
    
//    func loadNN()
//    {
//    }
//    
    
    
    public init(urlRequest: NSURLRequest, configuration: WKWebViewConfiguration = WKWebViewConfiguration(), activities: [UIActivity]? = nil) {
        self.configuration = configuration
        self.urlRequest = urlRequest
        self.activities = activities
        super.init(nibName: nil, bundle: nil)
    }

    /**
    Constructs a new `WebViewController`.

    - parameter url: The URL to display in the web view.

    - returns: A new `WebViewController` instance.
    */
    
    init(url: NSURL,wk_config:WKWebViewConfiguration) {
        self.configuration = wk_config
        self.urlRequest = NSURLRequest(URL: url)
        self.activities = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(url: NSURL) {
        self.init(urlRequest: NSURLRequest(URL: url))
    }

    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        self.configuration = WKWebViewConfiguration()
        self.urlRequest = NSURLRequest(URL: NSURL(string: "")!)
        self.activities = nil
        super.init(coder: aDecoder)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: TitleKeyPath, context: nil)
        webView.removeObserver(self, forKeyPath: EstimatedProgressKeyPath, context: nil)
    }


    // MARK: View lifecycle

    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = urlRequest.URL?.host

        if presentingViewController?.presentedViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Done,
                target: self,
                action: Selector("didTapDoneButton:"))
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Action,
            target: self,
            action: Selector("didTapActionButton:"))

        webView.loadRequest(urlRequest)
    }

    /// :nodoc:
    public override func viewWillAppear(animated: Bool) {
        assert(navigationController != nil, "\(WebViewController.self) must be presented in a \(UINavigationController.self)")
        super.viewWillAppear(animated)
    }

    /// :nodoc:
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.stopLoading()
    }

    /// :nodoc:
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        webView.frame = CGRect(
            x: view.frame.minX,
            y: view.frame.minY,
            width: view.frame.size.width,
            height: view.frame.size.height)

        view.bringSubviewToFront(progressBar)
        progressBar.frame = CGRect(
            x: view.frame.minX,
            y: topLayoutGuide.length,
            width: view.frame.size.width,
            height: 2)
    }


    // MARK: Actions

    internal final func didTapDoneButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    internal final func didTapActionButton(sender: UIBarButtonItem) {
        if let url = urlRequest.URL {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: activities)
            activityVC.popoverPresentationController?.barButtonItem = sender
            presentViewController(activityVC, animated: true, completion: nil)
        }
    }


    // MARK: KVO

    /// :nodoc:
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let theKeyPath = keyPath where object as? WKWebView == webView else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }

        if displaysWebViewTitle && theKeyPath == TitleKeyPath {
            title = webView.title
        }

        if theKeyPath == EstimatedProgressKeyPath {
            updateProgress()
        }
    }

    // MARK: Private

    private func updateProgress() {
        let completed = webView.estimatedProgress == 1.0
        progressBar.setProgress(completed ? 0.0 : Float(webView.estimatedProgress), animated: !completed)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = !completed
    }
    
}
