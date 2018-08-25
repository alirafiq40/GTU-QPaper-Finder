//
//  PDFViewController.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 24/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD
import GoogleMobileAds

class PDFViewController: UIViewController {
    
    var webview:WKWebView!
    var paper:Paper!
    
    var btnClose1:UIButton!
    var btnClose2:UIButton!
    var interstitial: GADInterstitial!
    
    fileprivate let buttonwidth = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var docURL = documentsUrl
        docURL.appendPathComponent(paper.fileName!)
        
        webview = WKWebView()
        
        if !FileManager.default.fileExists(atPath: docURL.path) {
            showAlertMessage("No file found")
        }
        
        webview.loadFileURL(docURL, allowingReadAccessTo: docURL)
        webview.navigationDelegate = self
        webview.scrollView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        webview.addGestureRecognizer(tapGesture)
        
        self.view = webview
        self.title = paper.code
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        PAPER_VIEW_COUNT += 1
        
        if PAPER_VIEW_COUNT % 4 == 0 {
            loadInterstatial()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        self.navigationController?.isNavigationBarHidden = true
        
        let width = self.webview.frame.width > self.webview.frame.height ? self.webview.frame.height : self.webview.frame.width
        let height = self.webview.frame.width > self.webview.frame.height ? self.webview.frame.width : self.webview.frame.height
        
        btnClose1 = UIButton(frame: CGRect(x: (Int(width) - buttonwidth)/2 , y: (Int(height) - buttonwidth - 20), width: buttonwidth, height: buttonwidth))
        btnClose1.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        btnClose1.tintColor = .black
        btnClose1.backgroundColor = UIColor.lightGray
        btnClose1.makeCircular(forced: true)
        btnClose1.addTarget(self, action: #selector(closeVC(_:)), for: .touchUpInside)
        
        webview.addSubview(btnClose1)
        
        btnClose2 = UIButton(frame: CGRect(x: (Int(height) - buttonwidth - 20), y:  20, width: buttonwidth, height: buttonwidth))
        btnClose2.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        btnClose2.tintColor = .black
        btnClose2.backgroundColor = UIColor.lightGray
        btnClose2.makeCircular(forced: true)
        btnClose2.addTarget(self, action: #selector(closeVC(_:)), for: .touchUpInside)
        
        webview.addSubview(btnClose2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollViewDidEndDecelerating(self.webview.scrollView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewTap() {
        if self.btnClose1.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.btnClose1.alpha = 0
                self.btnClose2.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.btnClose1.alpha = 1
                self.btnClose2.alpha = 1
            }
        }
    }

    func loadInterstatial() {
        interstitial = GADInterstitial(adUnitID: InterstitialUnitID)
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
    }
    
    func showInterstatial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    @objc func closeVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PDFViewController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        showInterstatial()
    }
}

extension PDFViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.dismiss()
        showAlertMessage(error.localizedDescription)
    }
}

extension PDFViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3) {
            self.btnClose1.alpha = 1
            self.btnClose2.alpha = 1
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.3) {
                self.btnClose1.alpha = 0
                self.btnClose2.alpha = 0
            }
        }
    }
}
