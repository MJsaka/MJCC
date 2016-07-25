//
//  EditEquationViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/7/4.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit
import Localize_Swift

protocol FinishEditEquation {
    func finishEditEquation(name name : String ,expr : String)
}

enum EditType {
    case modify
    case creat
}

class EditEquationViewController: UIViewController {
    
    var sourceVC : FinishEditEquation!
    var equation : Equation?
    var editType : EditType!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var exprField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if let e = equation {
            nameField.text = e.name
            exprField.text = e.expr
        }
    }
    
    @IBAction func finishEdit() {
        let name = nameField.text
        let expr = exprField.text
        
        if name == nil || expr == nil || name == "" || expr == ""{
            let ac = UIAlertController(title: "error".localized(), message: "inputError".localized(), preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "ok".localized(), style: .Default, handler: nil))
            self.presentViewController(ac, animated: true, completion: nil)
        }else if editType == .creat && EquationsManager.equations().contains({ $0.name == name }){
            let ac = UIAlertController(title: "error".localized(), message:"\("name".localized()) '\(name!)' \("exist".localized())", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "ok".localized(), style: .Default, handler: nil))
            self.presentViewController(ac, animated: true, completion: nil)
        }else{
            let lexer  = Lexer(input:expr)
            let parser  = Parser(lexer: lexer)
            let t = parser.parse()
            if let e = t.error {
                let ac = UIAlertController(title: "error".localized(), message: "\(e.info)", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "ok".localized() , style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }else{
                let trees = t.trees
                var newExpr : String = ""
                for (_,tree) in trees.enumerate() {
                    let e = tree.equationString()
                    newExpr += e + ";\n"
                }
                sourceVC.finishEditEquation(name: name!, expr: newExpr)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }

}
