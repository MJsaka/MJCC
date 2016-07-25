//
//  CalViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/15.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit
import Localize_Swift

class Variable: NSObject {
    var name :String!
    var nameLabel: UILabel!
    var inputField:UITextField!
    var value : Double?
}

class Result: NSObject {
    var name :String!
    var nameLabel: UILabel!
    var resultLabel: UILabel!
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
    private var expressionView : UITextView!
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
        for (_,tree) in trees.enumerate() {
            let result = Result()
            result.name = tree.resultName()
            results.append(result)
        }
        
        for (_,tree) in trees.enumerate() {
            let variablesNames = tree.variables()
            for v in variablesNames {
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
        expressionView = UITextView(frame: CGRect(x: 20, y: 20, width: self.view.frame.width - 40, height: equationLabelHeight))
        var expr : String = ""
        for (_,tree) in trees.enumerate() {
            let e = tree.equationString()
            expr += e + ";\n"
        }
        expressionView.text = expr
        expressionView.textAlignment = .Justified
        expressionView.backgroundColor = UIColor.yellowColor()
        expressionView.selectable = true
        expressionView.editable = false
        contentView.addSubview(expressionView)
        
        expressionView.translatesAutoresizingMaskIntoConstraints = false
        let equationTextViewConstrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[expressionView]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["expressionView":expressionView])
        let equationTextViewConstrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:|-20-[expressionView(%lf)]" , equationLabelHeight) , options: NSLayoutFormatOptions(), metrics: nil, views: ["expressionView":expressionView])
        contentView.addConstraints(equationTextViewConstrains1 + equationTextViewConstrains2)
    }
    
    func generateVariablesView() {
        variablesView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: variablesViewHeight))
//        variablesView.backgroundColor = UIColor.brownColor()
        contentView.addSubview(variablesView)
        variablesView.translatesAutoresizingMaskIntoConstraints = false
        let constrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[variablesView]|", options: .AlignAllCenterY, metrics: nil, views: ["variablesView":variablesView])
        let constrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:[expressionView]-20-[variablesView(%lf)]",variablesViewHeight), options: .AlignAllCenterX, metrics: nil, views: ["expressionView":expressionView,"variablesView":variablesView])
        contentView.addConstraints(constrains1 + constrains2)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        for (i,variable) in variables.enumerate(){
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
            if let valueString = userDefaults.stringForKey("\(equation.name).\(variable.name)") {
                textField.text = valueString
            }else{
                textField.text = ""
            }
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
        calButton.setTitle("calculate".localized() , forState: .Normal)
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
        
        for (i,result) in results.enumerate(){
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
        for (_,variable) in variables.enumerate() {
            let name = variable.name
            if let t = variable.inputField.text , v = Double(t) {
                variable.value = v
            }else{
                let ac = UIAlertController(title: "error".localized(), message: "\("variable".localized()) '\(name)' \("inputError".localized())", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "ok".localized(), style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
                return
            }
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        for variable in variables {
            userDefaults.setObject(variable.inputField.text, forKey: "\(equation.name).\(variable.name)")
        }

        for (_,tree) in trees.enumerate() {
            for variable in variables {
                tree.variablesValue[variable.name] = variable.value!
            }
            for result in results {
                if let value = result.value {
                    tree.variablesValue[result.name] = value
                }
            }
            
            let resultName = tree.resultName()
            let resultValue = tree.result()
            let index = results.indexOf({ resultName == $0.name })
            let result = results[index!]
            result.value = resultValue
            result.resultLabel.text = "\(resultValue)"
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
            vc.editType = .modify
        }
    }


}

