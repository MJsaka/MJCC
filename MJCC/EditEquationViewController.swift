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
            let parser  = Parser(input: lexer)
            let _  = parser.parse()
            if lexer.error || parser.error {
                let ac = UIAlertController(title: "错误", message: "公式语法错误", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }else{
                sourceVC.finishEditEquation(name: name!, expr: expr!)
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
