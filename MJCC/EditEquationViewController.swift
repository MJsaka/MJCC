//
//  EditEquationViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/7/4.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

protocol FinishEditEquation {
    func finishEditEquation(name name : String ,expr : String)
}

class EditEquationViewController: UIViewController {
    
    var sourceVC : FinishEditEquation!
    var equation : Equation?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var exprField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.hidden = true

        if let e = equation {
            nameField.text = e.name
            exprField.text = e.expr
        }
    }
    
    @IBAction func finishEdit() {
        let name = nameField.text
        let expr = exprField.text
        if name == nil || expr == nil || name == "" || expr == ""{
            let ac = UIAlertController(title: "错误", message: "名称或公式未填写", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
            self.presentViewController(ac, animated: true, completion: nil)
        }else{
            let lexer  = Lexer(input:expr)
            let parser  = Parser(lexer: lexer)
            let t = parser.parse()
            if let e = t.error {
                let ac = UIAlertController(title: "错误", message: "\(e.info)", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }else{
                let trees = t.trees
                var newExpr : String = ""
                for i in 0 ..< trees.count {
                    let tree = trees[i]
                    let e = tree.equationString()
                    newExpr += e + ";\n"
                }
                sourceVC.finishEditEquation(name: name!, expr: newExpr)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
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
