//
//  CalViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/15.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit
class Variable: NSObject {
    var name :String!
    var nameLabel: UILabel?
    var inputField:UITextField?
    var value : Double?
}

class Result: NSObject {
    var name :String!
    var nameLabel: UILabel?
    var resultLabel: UILabel?
    var value : Double?
}

let EquationNameChangedNotification = "EquationNameChangedNotification"

class CalViewController: UIViewController , FinishEditEquation{

    var equation : Equation!
    private var trees : [EquationTree]!
    
    private var variables : [Variable]!
    private var results : [Result]!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var equationLabelHeight : CGFloat!
    private var variablesViewHeight : CGFloat!
    private var resultsViewHeight : CGFloat!
    private var calButtonHeight : CGFloat!
    private var contentViewHeight : CGFloat!
    
    private var contentView : UIView!
    private var equationLabel : UILabel!
    private var variablesView : UIView!
    private var resultsView : UIView!
    private var calButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = equation.name
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        let input = equation.expr
        let lexer  = Lexer(input:input)
        let parser  = Parser(lexer: lexer)
        trees  = parser.parse().trees
        
        variables = [Variable]()
        results = [Result]()
        
        generateVariablesAndResults()
        
        equationLabelHeight = CGFloat(100)
        variablesViewHeight = CGFloat(50 * variables.count - 20)
        resultsViewHeight = CGFloat(50 * results.count - 20)
        calButtonHeight = CGFloat(60)
        contentViewHeight = equationLabelHeight + variablesViewHeight + resultsViewHeight + calButtonHeight + 80
        
        generateContentView()
        generateEquationLabel()
        generateVariablesView()
        generateCalButton()
        generateResultsView()
    }
    
    func generateVariablesAndResults() {
        for i in 0 ..< trees.count {
            let tree = trees[i]
            let result = Result()
            result.name = tree.resultVariable()
            results.append(result)
        }
        
        for i in 0 ..< trees.count {
            let tree = trees[i]
            let vs = tree.variables()
            for v in vs {
                if variables.contains({ v == $0.name})
                {
                    continue
                }
                if results.contains({ v == $0.name })
                {
                    continue
                }
                let variable = Variable()
                variable.name = v
                variables.append(variable)
            }
        }
    }
    
    func generateContentView() {
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: contentViewHeight))
        contentView.userInteractionEnabled = true
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: contentViewHeight)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentViewConstrain1 = NSLayoutConstraint(item: contentView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: self.view, attribute: .LeadingMargin, multiplier: 1.0, constant: 0)
        let contentViewConstrain2 = NSLayoutConstraint(item: contentView, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 0)
        let contentViewConstrain3 = NSLayoutConstraint(item: contentView, attribute: .TopMargin, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 0)
        let contentViewConstrain4 = NSLayoutConstraint(item: contentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: contentViewHeight)
    
        self.view.addConstraints([contentViewConstrain1,contentViewConstrain2,contentViewConstrain3,contentViewConstrain4])
    }
    
    func generateEquationLabel() {
        equationLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.view.frame.width - 40, height: equationLabelHeight))
        var expr : String = ""
        for i in 0 ..< trees.count {
            let tree = trees[i]
            let e = tree.equationString()
            expr += e + ";\n"
        }
        equationLabel.text = expr
        equationLabel.lineBreakMode = .ByTruncatingMiddle
        equationLabel.textAlignment = .Center
        equationLabel.numberOfLines = 0
        equationLabel.backgroundColor = UIColor.yellowColor()
        contentView.addSubview(equationLabel)
        
        equationLabel.translatesAutoresizingMaskIntoConstraints = false
        let equationTextViewConstrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[equationLabel]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["equationLabel":equationLabel])
        let equationTextViewConstrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:|-20-[equationLabel(%lf)]" , equationLabelHeight) , options: NSLayoutFormatOptions(), metrics: nil, views: ["equationLabel":equationLabel])
        contentView.addConstraints(equationTextViewConstrains1 + equationTextViewConstrains2)
    }
    
    func generateVariablesView() {
        variablesView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: variablesViewHeight))
//        variablesView.backgroundColor = UIColor.brownColor()
        contentView.addSubview(variablesView)
        variablesView.translatesAutoresizingMaskIntoConstraints = false
        let constrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[variablesView]|", options: .AlignAllCenterY, metrics: nil, views: ["variablesView":variablesView])
        let constrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:[equationLabel]-20-[variablesView(%lf)]",variablesViewHeight), options: .AlignAllCenterX, metrics: nil, views: ["equationLabel":equationLabel,"variablesView":variablesView])
        contentView.addConstraints(constrains1 + constrains2)
        
        for i in 0 ..< variables.count{
            let variable = variables[i]
            let name = variable.name
            let label = UILabel(frame: CGRect(x: 20, y: 50 * CGFloat(i), width: 100, height: 30))
            label.text = name
            label.backgroundColor = UIColor.orangeColor()
            label.textAlignment = .Center
            variablesView.addSubview(label)
            variable.nameLabel = label
            
            let textField = UITextField(frame: CGRect(x: 140, y: 50 * CGFloat(i), width: 200, height: 30))
            textField.backgroundColor = UIColor.whiteColor()
            textField.borderStyle = .RoundedRect
            textField.keyboardType = .DecimalPad
            textField.text = ""
            variablesView.addSubview(textField)
            variable.inputField = textField
            
            label.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            let constrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label]-20-[textField]-20-|", options: .AlignAllCenterY, metrics: nil, views: ["label":label,"textField":textField])
            let constrain = NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: .Equal, toItem: label, attribute: .Width, multiplier: 2.0, constant: 0)
            let constrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%f-[label(30)]" , 50 * CGFloat(i)), options: NSLayoutFormatOptions(), metrics: nil, views: ["label":label])
            let constrains3 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%f-[textField(30)]" , 50 * CGFloat(i)), options: NSLayoutFormatOptions(), metrics: nil, views: ["textField":textField])
            variablesView.addConstraints(constrains1 + constrains2 + constrains3)
            variablesView.addConstraint(constrain)
        }
    }
    
    func generateCalButton() {
        calButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: calButtonHeight))
        contentView.addSubview(calButton)
        calButton.translatesAutoresizingMaskIntoConstraints = false
        calButton.backgroundColor = UIColor.blueColor()
        calButton.setTitle("计算", forState: .Normal)
        calButton.addTarget(self, action: #selector(CalViewController.calculate(_:)), forControlEvents: .TouchUpInside)
        
        let buttonConstrain1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[calButton]-20-|", options: .AlignAllCenterX, metrics: nil, views: ["calButton" : calButton])
        let buttonConstrain2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:[variablesView]-20-[calButton(%lf)]" , calButtonHeight), options: .AlignAllCenterX, metrics: nil, views: ["variablesView":variablesView,"calButton" : calButton])
        contentView.addConstraints(buttonConstrain1 + buttonConstrain2)
    }
    
    func generateResultsView() {
        resultsView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: resultsViewHeight))
//        resultsView.backgroundColor = UIColor.brownColor()
        contentView.addSubview(resultsView)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        let constrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[resultsView]|", options: .AlignAllCenterY, metrics: nil, views: ["resultsView":resultsView])
        let constrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:[calButton]-20-[resultsView(%lf)]" , resultsViewHeight), options: .AlignAllCenterX, metrics: nil, views: ["resultsView":resultsView,"calButton":calButton])
        contentView.addConstraints(constrains1 + constrains2)
        
        for i in 0 ..< results.count{
            let result = results[i]
            let name = result.name
            let label = UILabel(frame: CGRect(x: 20, y: 50 * CGFloat(i), width: 100, height: 30))
            label.text = name
            label.backgroundColor = UIColor.greenColor()
            label.textAlignment = .Center
            resultsView.addSubview(label)
            result.nameLabel = label
            
            let resultLabel = UILabel(frame: CGRect(x: 20, y: 50 * CGFloat(i), width: 200, height: 30))
            resultLabel.backgroundColor = UIColor.greenColor()
            resultLabel.textAlignment = .Center
            resultsView.addSubview(resultLabel)
            result.resultLabel = resultLabel
            
            label.translatesAutoresizingMaskIntoConstraints = false
            resultLabel.translatesAutoresizingMaskIntoConstraints = false
            let constrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label]-20-[resultLabel]-20-|", options: .AlignAllCenterY, metrics: nil, views: ["label":label,"resultLabel":resultLabel])
            let constrain = NSLayoutConstraint(item: resultLabel, attribute: .Width, relatedBy: .Equal, toItem: label, attribute: .Width, multiplier: 2.0, constant: 0)
            let constrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%lf-[label(30)]" , 50 * CGFloat(i)), options: NSLayoutFormatOptions(), metrics: nil, views: ["label":label])
            let constrains3 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%lf-[resultLabel(30)]" , 50 * CGFloat(i)), options: NSLayoutFormatOptions(), metrics: nil, views: ["resultLabel":resultLabel])
            resultsView.addConstraints(constrains1 + constrains2 + constrains3)
            resultsView.addConstraint(constrain)
        }
    }
    
    
    @IBAction func calculate(sender: UIBarButtonItem) {
        //判断是否所有变量都已经赋值
        for i in 0 ..< variables.count {
            let variable = variables[i]
            let name = variable.name
            if let v = Double(variable.inputField!.text!) {
                variable.value = v
            }else{
                let ac = UIAlertController(title: "变量值错误", message: "变量\(name)的输入值有误，请重新输入", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
                break
            }
        }
        for i in 0 ..< trees.count {
            let tree = trees[i]
            
            for variable in variables {
                tree.variablesValue[variable.name] = variable.value!
            }
            for result in results {
                if let value = result.value {
                    tree.variablesValue[result.name] = value
                }
            }
            
            let resultVariable = tree.resultVariable()
            let result = tree.result()
            for i in 0 ..< results.count {
                if results[i].name == resultVariable {
                    results[i].value = result
                    results[i].resultLabel!.text = "\(result)"
                    break
                }
            }
        }
    }
    
    func finishEditEquation(name name : String ,expr : String) {
        if equation.name != name {
            equation.name = name
            NSNotificationCenter.defaultCenter().postNotificationName(EquationNameChangedNotification, object: self, userInfo: nil)
        }
        if equation.expr != expr {
            equation.expr = expr
        }
    }
   
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        scrollView.contentSize = CGSize(width: size.width, height:contentViewHeight)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEditView" {
            let vc = segue.destinationViewController as! EditEquationViewController
            vc.sourceVC = self
            vc.equation = equation
        }
    }


}

