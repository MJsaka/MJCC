//
//  EquationsViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/30.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class EquationsViewController: UITableViewController {
    
    var equations : [Equation]!
    var sectionTitles : [(title : String , count : Int)]!

    override func viewDidLoad() {
        super.viewDidLoad()
        equations = EquationsManager.equations()
        self.updateSectionIndex()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updateSectionIndex() {
        sectionTitles = [(title : String , count : Int)]()
        for equation in equations {
            let name = equation.name
            let title = name.substringToIndex(name.startIndex.advancedBy(1))
            if sectionTitles.endIndex > 0 &&
                title == sectionTitles[sectionTitles.endIndex - 1].title {
                sectionTitles[sectionTitles.endIndex - 1].count += 1
            }else {
                sectionTitles.append((title , 1))
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionTitles[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EquationCell", forIndexPath: indexPath)
        // Configure the cell...
        var equationIndex = 0
        for i in 0 ..< indexPath.section {
            equationIndex += sectionTitles[i].count
        }
        equationIndex += indexPath.row

        cell.textLabel?.text = equations[equationIndex].name
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section].title
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sectionTitles.map { (sectionTitle) -> String in
            let name = sectionTitle.title
            return name.substringToIndex(name.startIndex.advancedBy(1))
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 28
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
