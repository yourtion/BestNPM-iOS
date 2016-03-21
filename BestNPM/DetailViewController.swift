//
//  DetailViewController.swift
//  BestNPM
//
//  Created by YourtionGuo on 7/29/15.
//  Copyright (c) 2015 Yourtion. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webview: UIWebView!
    var name:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        if(name != nil){
            self.navigationItem.title = name
            let request = NSURLRequest(URL: NSURL(string:"https://www.npmjs.com/package/" + name)!)
            webview.loadRequest(request)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.clearAllNotice()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.pleaseWait()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.clearAllNotice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

