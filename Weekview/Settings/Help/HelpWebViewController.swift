//
//  HelpWebViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 16.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class HelpWebViewController: UIViewController {
    @IBOutlet weak var loadCircle: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewHight: NSLayoutConstraint!
    
    let settings = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.backgroundColor = settings.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let url = URL(string: "https://kay4ik.jimdo.com")
        webView.loadRequest(URLRequest(url: url!))
        webView.delegate = self
        loadCircle.startAnimating()
        subtitleLabel.isHidden = true
        loadingViewHight.constant = 40
    }
    
    func setupDesign() {
        loadingView.backgroundColor = settings.backgroundColor
        let color = settings.mainTextColor
        titleLabel.textColor = color
        subtitleLabel.textColor = color
    }
    
}
extension HelpWebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadCircle.stopAnimating()
        loadingView.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        titleLabel.text = "Fehler beim laden!"
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
            self.loadingViewHight.constant = 70
        }, completion: nil)
        subtitleLabel.isHidden = false
        subtitleLabel.text = "Internetverbindung prüfen."
    }
}
