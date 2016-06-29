//
//  ViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/15.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    var input : String!
    var lexer : Lexer!
    var parser : Parser!
    var tree : EquationTree!
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("degree", forKey: "measurement")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func calculate(sender: UIBarButtonItem) {
        input = inputTextView.text
        lexer  = Lexer(input:input)
        parser  = Parser(input: lexer)
        tree  = parser.parse()
        inputTextView.text = tree.equationString()
        tree.transformForVariable(0)
        outputTextView.text = tree.equationString()
        resultLabel.text = tree.variables[0].token.text + " = \(tree.subEquationValue(node: tree.root.rightChild! ))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTreeView" {
            if self.tree == nil {
                input = inputTextView.text
                lexer  = Lexer(input:input)
                parser  = Parser(input: lexer)
                tree  = parser.parse()
            }
            let treeViewController = segue.destinationViewController as! TreeViewController
            treeViewController.tree = self.tree
        }
    }


}

