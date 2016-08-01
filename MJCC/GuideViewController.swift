//
//  GuideViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/8/1.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = NSBundle.mainBundle().URLForResource("help", withExtension: "html"){
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
