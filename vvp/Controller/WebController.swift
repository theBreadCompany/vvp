//
//  WebController.swift
//  vvp
//
//  Created by Fabio Mauersberger on 17.10.22.
//
//  This is buggy in iOS 16.0; The webview takes an eternity to load the URL at best and simply displays nothing at worst
//  TODO: (annoying) workaround: implement detection of non-loading URLs and forward to Safari anyway

import Foundation
import WebKit
import WPKit
import SafariServices

class WebController: UIViewController, WKNavigationDelegate {
    public var url: URL?
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var shareBtn: UIButton!
    @IBOutlet private weak var doneBtn: UIButton!
    
    @IBAction private func done(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func shareSource(_ sender: Any) {
        
        guard let item = url else { return }
        wplog("Share initialized with ", item.absoluteString)
        let activityVC = UIActivityViewController(activityItems: [item] as [Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        
        if #available(iOS 13, *) {
            activityVC.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
            activityVC.isModalInPresentation = true
        }
        present(activityVC, animated: true)
    }
    
    override func viewDidLoad() {
        shareBtn.setTitle("", for: .normal)
        doneBtn.setTitle(NSLocalizedString("Done", comment: "done btn"), for: .normal)
        if let url = url {
            label.text = url.host
            self.webView.load(URLRequest(url: url))
            
        }
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == -1007 {
            self.present(SFSafariViewController(url: url!), animated: true)
            return
        }
    }
}
