//
//  EquationTree.swift
//  MJCC
//
//  Created by MJsaka on 16/6/17.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

//计算阶乘或双阶乘
public func factorial(n : Int , step : Int) -> Int {
    if n == 0 || n == 1{
        return 1
    }else {
        return n * factorial(n - step , step: step)
    }
}
//迭代计算 a ~ k , 精确到12位小数
//x[n+1] = (k - 1) / k * x[n] + a / (k * x[n]^(k - 1))
public func roo(base : Double ,  times: Double) -> Double {
    var x0 = 1.0 , x = 1.0
    
    repeat {
        x0 = x
        x = (times - 1.0) / times * x0 + base / (times * pow(x0, times - 1.0))
    } while x - x0 > 1E-12
    
    return x
}

class EquationNode: NSObject{
    var father : EquationNode?
    var leftChild : EquationNode?
    var rightChild : EquationNode?
    var token : Token
    //运算符名字转换表
    static let operatorNameDict = ["plus"              : "+",
                            "minus"             : "-",
                            "multiply"          : "*",
                            "divide"            : "/",
                            "power"             : "^",
                            "root"              : "~",
                            "factorial"         : "!",
                            "doubleFactorial"   : "!!",
                            "equal"             : "="]
    init(token : Token) {
        self.token = token
    }
    func name() -> String {
        if let s = EquationNode.operatorNameDict[self.token.text]{
            return s
        }
        return token.text
    }
}

class EquationTree: NSObject {
    let root : EquationNode
    //变量表
    var variablesValue : [String : Double]
    
    /*
    //三角函数直接逆运算表
    private static let trigonometricTransformDict = ["sin"       : "asin",
                            "cos"       : "acos",
                            "tan"       : "atan",
                            "cot"       : "acot",
                            "asin"    : "sin",
                            "acos"    : "cos",
                            "atan"    : "tan",
                            "acot"    : "cot"]
    //四则、乘方、开方直接逆运算表
    private static let leftChildTransformDict = ["plus"      : "minus",
                            "minus"     : "plus",
                            "multiply"  : "divide",
                            "divide"    : "multiply",
                            "power"     : "root",
                            "root"      : "power"]
    private static let leftChildTransformTokenTypeDict : [String : TokenType] =
        ["plus"      : .minus,
         "minus"     : .plus,
         "multiply"  : .divide,
         "divide"    : .multiply,
         "power"     : .root,
         "root"      : .power]
    */
    
    init(root : EquationNode) {
        self.root = root
        self.variablesValue = [String : Double]()
        super.init()
        
    }
    
    static func traverseTreePreOrder(root node : EquationNode , visitor visit : (EquationNode) -> Void) {
        visit(node)
        if let l = node.leftChild {
            traverseTreePreOrder(root: l , visitor: visit)
        }
        if let r = node.rightChild {
            traverseTreePreOrder(root: r, visitor: visit)
        }
    }
    static func traverseTreeInOrder(root node : EquationNode , visitor visit : (EquationNode) -> Void) {
        if let l = node.leftChild {
            traverseTreePreOrder(root: l , visitor: visit)
        }
        visit(node)
        if let r = node.rightChild {
            traverseTreePreOrder(root: r, visitor: visit)
        }
    }
    static func traverseTreePostOrder(root node : EquationNode , visitor visit : (EquationNode) -> Void) {
        if let l = node.leftChild {
            traverseTreePreOrder(root: l , visitor: visit)
        }
        if let r = node.rightChild {
            traverseTreePreOrder(root: r, visitor: visit)
        }
        visit(node)
    }

    //返回结果变量
    func resultVariable() -> String{
        return root.leftChild!.token.text
    }
    //返回所有的变量名
    func variables() -> [String] {
        var variables = [String]()
        EquationTree.traverseTreePreOrder(root: root.rightChild!) { (node) in
            if node.token.type == .variable {
                if !variables.contains(node.token.text){
                    variables.append(node.token.text)
                }
            }
        }
        return variables
    }
    
    func result() -> Double {
        return subEquationValue(node: root.rightChild!)
    }
    
    /*
    //计算变量的值
    func calculateVariable(variable : String) -> Double{
        var variableNode : EquationNode!
        EquationTree.traverseTreePreOrder(root: root) { (node) in
            if node.token.text == variable {
                variableNode = node
            }
        }
        recursionTransform(variableNode)
        return subEquationValue(node: root.rightChild!)
    }
    */
    
    //计算某结点的子式的值
    private func subEquationValue(node node : EquationNode) -> Double {
        var v : Double!
        switch node.token.type {
        case .variable:
            v = variablesValue[node.token.text]
        case .integer , .float:
            v = Double(node.token.text)!
        case .const :
            if node.token.text == "e" {
                v = M_E
            }
            if node.token.text == "PI" {
                v = M_PI
            }
        case .trigonometric :
            let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let measure = userDefaults.stringForKey("measurement")
            let subValue = subEquationValue(node: node.leftChild!)
            
            switch node.token.text {
            case "sin":
                if measure == "degree" {
                    let angle = subValue / 180 * M_PI
                    v = sin(angle)
                }else{
                    v = sin(subValue)
                }
            case "cos" :
                if measure == "degree" {
                    let angle = subValue / 180 * M_PI
                    v = cos(angle)
                }else {
                    v = cos(subValue)
                }
            case "tan" :
                if measure == "degree" {
                    let angle = subValue / 180 * M_PI
                    v = tan(angle)
                }else{
                    v = tan(subValue)
                }
            case "cot" :
                if measure == "degree" {
                    let angle = subValue / 180 * M_PI
                    v = tan(M_PI_2 - angle)
                }else {
                    v = tan(M_PI_2 - subValue)
                }
            case "asin" :
                let r = asin(subValue)
                if measure == "degree" {
                    v = r * 180 / M_PI
                }else{
                    v = r
                }
            case "acos" :
                let r = acos(subValue)
                if measure == "degree" {
                    v = r * 180 / M_PI
                }else{
                    v = r
                }
            case "atan" :
                let r = atan(subValue)
                if measure == "degree" {
                    v = r * 180 / M_PI
                }else {
                    v = r
                }
            case "acot" :
                let t = atan(subValue)
                let r = t > 0 ? M_PI_2 - t : 0 - M_PI_2 - t
                if measure == "degree" {
                    v = r * 180 / M_PI
                }else{
                    v = r
                }
            default:
                break
            }
        case .logarithm1 :
            switch node.token.text {
            case "lg" :
                v = log10(subEquationValue(node: node.leftChild! ))
            case "ln" :
                v = log(subEquationValue(node: node.leftChild! ))
            case "lb" :
                v = log2(subEquationValue(node: node.leftChild! ))
            default:
                break
            }
        case .logarithm2 :
            //根据换底公式:log(X , Y) = log(a,Y) / log(a,X)
            v = log2(subEquationValue(node: node.rightChild! )) / log2(subEquationValue(node: node.leftChild! ))
        case .factorial :
            if node.token.text == "factorial" {
                v = Double(factorial(Int(subEquationValue(node: node.leftChild! )), step: 1))
            }else {
                v = Double(factorial(Int(subEquationValue(node: node.leftChild! )), step: 2))
            }
        default:
            let l : Double = subEquationValue(node: node.leftChild! )
            let r : Double = subEquationValue(node: node.rightChild! )
            switch node.token.type {
            case .plus:
                v = l + r
            case .minus :
                v = l - r
            case .multiply :
                v = l * r
            case .divide :
                v = l / r
            case .power :
                v = pow(l , r)
            case .root :
                v = pow(l, 1/r)
            default:
                break
            }
        }
        return v
    }
    
    //从表达式树生成表达式串
    func equationString() -> String {
        return subString(node : root )
    }
    private func subString(node node : EquationNode) -> String{
        let s : String = node.name()
        var l : String = ""
        var r : String = ""
        var str : String

        if let lc = node.leftChild {
            l = subString(node: lc)
        }
        if let rc = node.rightChild {
            r = subString(node: rc)
        }
        
        switch node.token.type {
        case .variable:
            str = "{" + s + "}"
        case .logarithm1 , .trigonometric:
            if node.leftChild!.token.type.rawValue > TokenType.float.rawValue
            {
                l = "(" + l + ")"
            }
            str = s + l
        case .logarithm2 :
            str = s + "(" + l + "," + r  + ")"
        case .power , .root :
            if node.leftChild!.token.type.rawValue > TokenType.float.rawValue
            {
                l = "(" + l + ")"
            }
            if node.rightChild!.token.type.rawValue > TokenType.float.rawValue
            {
                r = "(" + r + ")"
            }
            str = l + s + r
        case .multiply :
            if node.leftChild!.token.type.rawValue > TokenType.multiply.rawValue
            {
                l = "(" + l + ")"
            }
            if node.rightChild!.token.type.rawValue > TokenType.multiply.rawValue
            {
                r = "(" + r + ")"
            }
            str = l + s + r
        case .divide :
            if node.leftChild!.token.type.rawValue > TokenType.multiply.rawValue
            {
                l = "(" + l + ")"
            }
            if node.rightChild!.token.type.rawValue >= TokenType.divide.rawValue
            {
                r = "(" + r + ")"
            }
            str = l + s + r
        case .minus :
            if node.rightChild!.token.type.rawValue >= TokenType.minus.rawValue
            {
                r = "(" + r + ")"
            }
            str = l + s + r
        default:
            str = l + s + r
        }
        return str
    }
    /*
    //将树变形为某变量的表达式树：即root的leftchild为该变量，rightchild为该变量的运算式树
    //从该变量出发，循环将其上代往上提，直到该变量提为root的leftchild
    private func recursionTransform(variable : EquationNode) {
        let father : EquationNode = variable.father!
        if father == root {
            return
        }
        let grandfather : EquationNode = father.father!
        if grandfather == root {
            if father == grandfather.rightChild {
                let uncle = grandfather.leftChild 
                grandfather.leftChild = father
                grandfather.rightChild = uncle
            }
            transform(variable, father: father, grandfather: root )
        }else{
            recursionTransform(father)
            transform(variable, father: father, grandfather: root )
        }
    }
    //     =   |     =   |     =               =      |   =     |    =
    //    / \  |    / \  |    / \             / \     |  / \    |   / \
    //   @   C |  func C | func  B    ==>    A  -@    | A -func |  A  -func
    //  /\     |  / \    |   |                  / \   |    / \  |       |
    // A  B    | A   B   |   A                 B   C  |   B   C |       B
    private func transform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        //func(A) = B  ==>  A = -func(B)
        if father.token.type == .trigonometric {
            trigonometricTransform(variable, father: father, grandfather: grandfather)
            return
        }
        //lg lb ln
        if father.token.type == .logarithm1 {
            logarithm1Transform(variable, father: father, grandfather: grandfather)
            return
        }
        //log
        if father.token.type == .logarithm2 {
            logarithm2Transform(variable, father: father, grandfather: grandfather)
            return
        }
        // A @ B = C  ==>  A = C -@ B
        if variable == father.leftChild {
            transformLeftChild(variable, father: father, grandfather: grandfather)
            return
        }
        // B @ A = C  ==> A = ...
        if variable == father.rightChild {
            transformRightChild(variable, father: father, grandfather: grandfather)
            return
        }
    }
    //func(A) = B  ==>  A = -func(B)
    private func trigonometricTransform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        let transNode = EquationNode(token: Token(type: .trigonometric, text: EquationTree.trigonometricTransformDict[father.token.text]!))
        
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = uncle
        uncle.father = transNode
    }
    //l(b|g|n)(A) = B  ==>  A = (2|10|e) ^ B
    private func logarithm1Transform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        let transNode = EquationNode(token: Token(type: .power, text:"power"))
        var brother : EquationNode!
        switch father.token.text {
        case "ln" :
            brother = EquationNode(token: Token(type: .const, text: "e"))
        case "lb" :
            brother = EquationNode(token: Token(type: .integer, text: "2"))
        case "lg" :
            brother = EquationNode(token: Token(type: .integer, text: "10"))
        default:
            break
        }
        
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = brother
        brother.father = transNode
        transNode.rightChild = uncle
        uncle.father = transNode
    }
    //logA(B) = C  ==>  A = B ~ C
    //logB(A) = C  ==>  A = B ^ C
    private func logarithm2Transform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        var transNode : EquationNode
        var brother : EquationNode
        if variable == father.leftChild {
            brother = father.rightChild!
            transNode = EquationNode(token: Token(type: .root, text:"root"))
        }else{
            brother = father.leftChild!
            transNode = EquationNode(token: Token(type: .power, text:"power"))
        }
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = brother
        brother.father = transNode
        transNode.rightChild = uncle
        uncle.father = transNode
    }
    // A + B = C  ==>  A = C - B
    // A - B = C  ==>  A = C + B
    // A * B = C  ==>  A = C / B
    // A / B = C  ==>  A = C * B
    // A ^ B = C  ==>  A = C ~ B
    // A ~ B = C  ==>  A = C ^ B
    private func transformLeftChild(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        let transNode = EquationNode(token: Token(type: EquationTree.leftChildTransformTokenTypeDict[father.token.text]! , text: EquationTree.leftChildTransformDict[father.token.text]!))
        let rightBrother = father.rightChild!
        
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = uncle
        uncle.father = transNode
        transNode.rightChild = rightBrother
        rightBrother.father = transNode
    }
    // B + A = C  ==>  A = C - B
    // B * A = C  ==>  A = C / B
    // B - A = C  ==>  A = B - C
    // B / A = C  ==>  A = B / C
    // B ^ A = C  ==>  A = log(B , C)
    // B ~ A = C  ==>  A = 1 / log(B , C)
    private func transformRightChild(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        var transNode : EquationNode
        let leftBrother : EquationNode = father.leftChild!
        
        switch father.token.type {
        case .minus , .plus :
            transNode = EquationNode(token: Token(type: .minus, text:"minus"))
        case .multiply , .divide :
            transNode = EquationNode(token: Token(type: .divide, text:"divide"))
        default:
            transNode = EquationNode(token: Token(type: .logarithm2, text:"log"))
        }
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        leftBrother.father = transNode
        uncle.father = transNode

        switch father.token.type {
        case .plus , .multiply:
            transNode.leftChild = uncle
            transNode.rightChild = leftBrother
        case .minus , .divide , .power , .root:
            transNode.leftChild = leftBrother
            transNode.rightChild = uncle
        default:
            break
        }
        if father.token.text == "root" {
            let node = EquationNode(token: Token(type: .divide, text: "divide"))
            let lnode = EquationNode(token: Token(type: .float, text: "1"))
            node.leftChild = lnode
            lnode.father = node
            node.rightChild = transNode
            transNode.rightChild = node
            grandfather.rightChild = node
            node.father = grandfather
        }
    }
    */
}
