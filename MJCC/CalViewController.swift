//
//  CalViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/15.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class CalViewController: UIViewController{

    var equation : Equation!
    var tree : EquationTree!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var contentView : UIView!
    var equationLabel : UILabel!
    var variablesLabel : [UILabel]!
    var variablesValueField : [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = equation.name
        let input = equation.expr
        let lexer  = Lexer(input:input)
        let parser  = Parser(input: lexer)
        tree  = parser.parse()
        
        generateContentView()
    }
    
    func generateContentView() {
        let variables = tree.variables()
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 120 + 50 * CGFloat(variables.count) + 60))
        contentView.userInteractionEnabled = true
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 120 + 50 * CGFloat(variables.count) + 60)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentViewConstrain1 = NSLayoutConstraint(item: contentView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: self.view, attribute: .LeadingMargin, multiplier: 1.0, constant: 0)
        let contentViewConstrain2 = NSLayoutConstraint(item: contentView, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 0)
        let contentViewConstrain3 = NSLayoutConstraint(item: contentView, attribute: .TopMargin, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 0)
        let contentViewConstrain4 = NSLayoutConstraint(item: contentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 120 + 50 * CGFloat(variables.count) + 60)
    
        self.view.addConstraints([contentViewConstrain1,contentViewConstrain2,contentViewConstrain3,contentViewConstrain4])
        
        equationLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.view.frame.width - 40, height: 80))
        equationLabel.text = tree.equationString()
        equationLabel.lineBreakMode = .ByTruncatingTail
        equationLabel.textAlignment = .Center
        equationLabel.numberOfLines = 0
        equationLabel.backgroundColor = UIColor.yellowColor()
        contentView.addSubview(equationLabel)
        
        equationLabel.translatesAutoresizingMaskIntoConstraints = false
        let equationTextViewConstrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[equationLabel]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["equationLabel":equationLabel])
        let equationTextViewConstrains2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[equationLabel(80)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["equationLabel":equationLabel])
        contentView.addConstraints(equationTextViewConstrains1)
        contentView.addConstraints(equationTextViewConstrains2)
        
        variablesLabel = [UILabel]()
        variablesValueField = [UITextField]()
        for i in 0 ..< variables.count{
            let label = UILabel(frame: CGRect(x: 20, y: 120 + 50 * CGFloat(i), width: 100, height: 30))
            label.text = variables[i]
            label.backgroundColor = UIColor.orangeColor()
            label.textAlignment = .Center
            variablesLabel.append(label)
            contentView.addSubview(label)
            
            let textField = UITextField(frame: CGRect(x: 140, y: 120 + 50 * CGFloat(i), width: 200, height: 30))
            textField.backgroundColor = UIColor.whiteColor()
            textField.borderStyle = .RoundedRect
            textField.keyboardType = .DecimalPad
            contentView.addSubview(textField)
            variablesValueField.append(textField)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            let constrains1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label(100)]-20-[textField]-20-|", options: .AlignAllCenterY, metrics: nil, views: ["label":label,"textField":textField])
            let constrains2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%f-[label(30)]" , 120 + 50 * CGFloat(i)), options: NSLayoutFormatOptions(), metrics: nil, views: ["label":label])
            let constrains3 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%f-[textField(30)]" , 120 + 50 * CGFloat(i)), options: NSLayoutFormatOptions(), metrics: nil, views: ["textField":textField])
            contentView.addConstraints(constrains1)
            contentView.addConstraints(constrains2)
            contentView.addConstraints(constrains3)
        }
        let button : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blueColor()
        button.setTitle("计算", forState: .Normal)
        button.addTarget(self, action: #selector(CalViewController.calculate(_:)), forControlEvents: .TouchUpInside)

        let buttonConstrain1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[button]-20-|", options: .AlignAllCenterX, metrics: nil, views: ["button" : button])
        let buttonConstrain2 = NSLayoutConstraint.constraintsWithVisualFormat(String(format: "V:|-%f-[button(40)]" , 120 + 50 * CGFloat(variablesLabel.count)), options: .AlignAllCenterX, metrics: nil, views: ["button" : button])
        contentView.addConstraints(buttonConstrain1)
        contentView.addConstraints(buttonConstrain2)
    }
    
    @IBAction func calculate(sender: UIBarButtonItem) {
        var index : Int = -1
        for i in  0 ..< variablesValueField.count {
            let variable = variablesLabel[i].text
            if let valueText = variablesValueField[i].text {
                if let value = Double(valueText){
                    tree.variablesValue[variable!] = value
                }else{
                    index = i
                }
            }
        }
        if index != -1 {
            let v = tree.calculateVariable(variablesLabel[index].text!)
            variablesValueField[index].text = "\(v)"
        }else{
            let ex : NSException = NSException(name: "VariableValue", reason: "please leave one variable not assigned", userInfo: nil)
            ex.raise()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 120 + 50 * CGFloat(variablesLabel.count) + 60)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTreeView" {
            let treeViewController = segue.destinationViewController as! TreeViewController
            treeViewController.tree = self.tree
        }
    }


}

