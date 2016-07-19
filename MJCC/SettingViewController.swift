//
//  SettingViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/7/19.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {

    @IBOutlet weak var measurementLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    override func viewWillAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let measure = userDefaults.stringForKey("measurement")
        self.measurementLabel.text = measure
    }

}
