//
//  HelpViewController.swift
//  Nikola
//
//  Created by Sutharshan on 7/19/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class HelpViewController: UIViewController,UIWebViewDelegate {
     var hud : MBProgressHUD = MBProgressHUD()
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    var urlPassed = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        self.showLoader(str: "Loading...")
        let url = URL (string: Const.Url.HOST_URL)
        let requestObj = URLRequest(url: url!);
        self.webView.loadRequest(requestObj)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        webView.scrollView.contentInset = UIEdgeInsets.zero;
    }
    public func webViewDidFinishLoad(_ webView: UIWebView)
    {
        self.hideLoader()
    }
}
extension HelpViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}

