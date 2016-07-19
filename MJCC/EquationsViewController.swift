//
//  EquationsViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/30.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class EquationsViewController: UITableViewController , FinishEditEquation{
    
    let collation : UILocalizedIndexedCollation = UILocalizedIndexedCollation.currentCollation()
    var sectionsArray : [Array<Equation>]!
    var sectionsMap : [Int]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateSectionsArray()
        self.updateSectionMap()
        (self.view as! UITableView).sectionIndexBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        (self.view as! UITableView).sectionIndexTrackingBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onEquationNameChangedNotification), name: EquationNameChangedNotification, object: nil)
    }
    
    func onEquationNameChangedNotification() {
        tableView.reloadData()
    }
    
    func finishEditEquation(name name : String ,expr : String) {
        let equation = EquationsManager.insertEquation(name: name, expr: expr)
        let realSection = collation.sectionForObject(equation, collationStringSelector: Selector("name"))
        sectionsArray[realSection].append(equation)
        sectionsArray[realSection] = collation.sortedArrayFromArray(sectionsArray[realSection], collationStringSelector: Selector("name")) as! [Equation]
        if sectionsArray[realSection].count == 1 {
            self.updateSectionMap()
            tableView.reloadData()
        }else{
            for i in 0 ..< sectionsMap.count{
                if sectionsMap[i] == realSection {
                    tableView.reloadSections(NSIndexSet(index: i), withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionsMap.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let realSection = sectionsMap[section]
        return sectionsArray[realSection].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EquationCell", forIndexPath: indexPath)
        // Configure the cell...
        let realSection = sectionsMap[indexPath.section]
        cell.textLabel?.text = sectionsArray[realSection][indexPath.row].name
        return cell
    }
    
    // MARK: - TableView Section Index

    func generateSectionsArray() {
        let sectionTitlesCount = collation.sectionTitles.count
        sectionsArray = [Array<Equation>]()
        for _ in 0 ..< sectionTitlesCount {
            let section = [Equation]()
            sectionsArray.append(section)
        }
        let equations = EquationsManager.equations()
        for equation in equations {
            let sectionIndex = collation.sectionForObject(equation, collationStringSelector: Selector("name"))
            sectionsArray[sectionIndex].append(equation)
        }
        for i in 0 ..< sectionTitlesCount{
            sectionsArray[i] = collation.sortedArrayFromArray(sectionsArray[i], collationStringSelector: Selector("name")) as! [Equation]
        }
    }
    
    func updateSectionMap() {
        sectionsMap = [Int]()
        for y in 0 ..< sectionsArray.count {
            if sectionsArray[y].count > 0 {
                sectionsMap.append(y)
            }
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let realSection = sectionsMap[section]
        return collation.sectionTitles[realSection]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var titles = [String]()
        for i in 0 ..< sectionsMap.count {
            titles.append(collation.sectionTitles[sectionsMap[i]])
        }
        return titles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let equation = sectionsArray[sectionsMap[indexPath.section]].removeAtIndex(indexPath.row)
            EquationsManager.deleteEquation(equation)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if sectionsArray[sectionsMap[indexPath.section]].count == 0 {
                self.updateSectionMap()
                tableView.reloadData()
                tableView.reloadSectionIndexTitles()
            }
        }
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowEditView" {
            let vc = segue.destinationViewController as! EditEquationViewController
            vc.sourceVC = self
        }else if segue.identifier == "ShowCalView"{
            let indexPath = tableView.indexPathForSelectedRow
            let section = indexPath!.section
            let row = indexPath!.row
            let vc = segue.destinationViewController as! CalViewController
            vc.equation = sectionsArray[sectionsMap[section]][row]
        }
    }
    

}
