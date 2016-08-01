//
//  MeasurementSelectViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/7/19.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class MeasurementSelectViewController: UITableViewController {

    @IBOutlet weak var degreeCell: UITableViewCell!
    @IBOutlet weak var radiansCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let measure = userDefaults.stringForKey("measurement")
        if measure == "degree" {
            degreeCell.accessoryType = .Checkmark
            radiansCell.accessoryType = .None
        }else{
            degreeCell.accessoryType = .None
            radiansCell.accessoryType = .Checkmark
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if indexPath.row == 0 {
            degreeCell.accessoryType = .Checkmark
            radiansCell.accessoryType = .None
            userDefaults.setObject("degree", forKey: "measurement")
        }else{
            degreeCell.accessoryType = .None
            radiansCell.accessoryType = .Checkmark
            userDefaults.setObject("radians", forKey: "measurement")
        }
    }
}
