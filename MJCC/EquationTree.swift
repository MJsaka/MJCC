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
    var variables : [EquationNode]
    //三角函数直接逆运算表
    static let trigonometricTransformDict = ["sin"       : "asin",
                            "cos"       : "acos",
                            "tan"       : "atan",
                            "cot"       : "acot",
                            "asin"    : "sin",
                            "acos"    : "cos",
                            "atan"    : "tan",
                            "acot"    : "cot"]
    //四则、乘方、开方直接逆运算表
    static let leftChildTransformDict = ["plus"      : "minus",
                            "minus"     : "plus",
                            "multiply"  : "divide",
                            "divide"    : "multiply",
                            "power"     : "root",
                            "root"      : "power"]
    static let leftChildTransformTokenTypeDict = ["plus"      : TokenType.minus,
                            "minus"     : TokenType.plus,
                            "multiply"  : TokenType.divide,
                            "divide"    : TokenType.multiply,
                            "power"     : TokenType.root,
                            "root"      : TokenType.power]
   
    init(root : EquationNode) {
        self.root = root
        self.variables = [EquationNode]()
        super.init()
        EquationTree.traverseTreePreOrder(root: root) { (node) in
            if node.token.type == TokenType.variable {
                self.variables.append(node)
            }
        }
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

    
    //计算某结点的子式的值
    func subEquationValue(node node : EquationNode) -> Double {
        switch node.token.type {
        case TokenType.integer , TokenType.float:
            return Double(node.token.text)!
        case TokenType.function1 :
            switch node.token.text {
            case "sin":
                return sin(subEquationValue(node: node.leftChild as! EquationNode))
            case "cos" :
                return cos(subEquationValue(node: node.leftChild  as! EquationNode))
            case "tan" :
                return tan(subEquationValue(node: node.leftChild  as! EquationNode))
            case "cot" :
                return tan(M_PI_2 - subEquationValue(node: node.leftChild  as! EquationNode))
            case "arcsin" :
                return asin(subEquationValue(node: node.leftChild as! EquationNode))
            case "arccos" :
                return acos(subEquationValue(node: node.leftChild as! EquationNode))
            case "arctan" :
                return atan(subEquationValue(node: node.leftChild as! EquationNode))
            case "arccot" :
                let t = atan(subEquationValue(node: node.leftChild as! EquationNode))
                return t > 0 ? M_PI_2 - t : 0 - M_PI_2 - t
            default:
                return 0
            }
        case TokenType.function2 :
            //根据换底公式:log(X , Y) = log(a,Y) / log(a,X)
            return log2(subEquationValue(node: node.rightChild as! EquationNode)) / log2(subEquationValue(node: node.leftChild as! EquationNode))
        case TokenType.factorial :
            if node.token.text == "factorial" {
                return Double(factorial(Int(subEquationValue(node: node.leftChild as! EquationNode)), step: 1))
            }else{
                return Double(factorial(Int(subEquationValue(node: node.leftChild as! EquationNode)), step: 2))
            }
        default:
            let l : Double = subEquationValue(node: node.leftChild as! EquationNode)
            let r : Double = subEquationValue(node: node.rightChild as! EquationNode)
            switch node.token.text {
            case "plus":
                return l + r
            case "minus" :
                return l - r
            case "multiply" :
                return l * r
            case "divide" :
                return l / r
            case "power" :
                return pow(l , r)
            case "root" :
                return roo(l, times: r)
            default:
                return 0
            }
        }
    }
    
    //从表达式树生成表达式串
    func equationString() -> String {
        return subString(node : root )
    }
    func subString(node node : EquationNode) -> String{
        var str : String = ""
        var s : String = ""
        var l : String = ""
        var r : String = ""
        
        switch node.token.type {
        case TokenType.variable :
            s = "${" + node.token.text + "}"
        case TokenType.integer , TokenType.float:
            s = node.token.text
        case TokenType.plusAndMinus , TokenType.multiplyAndDivide , TokenType.equal:
            s = " " + operatorNameDict[node.token.text]! + " "
        default:
            s = operatorNameDict[node.token.text]!
        }
        
        if node.token.type == TokenType.function2 {
            l = subString(node: node.leftChild as! EquationNode)
            r = subString(node: node.rightChild as! EquationNode)
            switch l {
            case "2" :
                s = "lb"
                str = s + "(" + r + ")"
            case "10" :
                s = "lg"
                str = s + "(" + r + ")"
            case "\(M_E)" :
                s = "ln"
                str = s + "(" + r + ")"
            default:
                str = s + "(" + l + "," + r + ")"
            }
        }else {
            if let lc = node.leftChild as? EquationNode{
                l = subString(node: lc)
                if lc.token.type.rawValue > node.token.type.rawValue {
                    l = "(" + l + ")"
                }
            }
            if let rc = node.rightChild as? EquationNode {
                r = subString(node: rc)
                if rc.token.type.rawValue > node.token.type.rawValue {
                    r = "(" + r + ")"
                }
            }
            switch node.token.type {
            case TokenType.function1:
                str = s + l
            default:
                str = l + s + r
            }
        }
        return str
    }
    //将树变形为某变量的表达式树：即root的leftchild为该变量，rightchild为该变量的运算式树
    func transformForVariable(index : Int) {
        let variable = variables[index]
        recursionTransform(variable)
    }
    //从该变量出发，循环将其上代往上提，直到该变量提为root的leftchild
    func recursionTransform(variable : EquationNode) {
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
    func transform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        //func(A) = B  ==>  A = -func(B)
        if father.token.type == TokenType.trigonometric {
            trigonometricTransform(variable, father: father, grandfather: grandfather)
            return
        }
        //lg lb ln
        if father.token.type == TokenType.logarithm1 {
            logarithm1Transform(variable, father: father, grandfather: grandfather)
            return
        }
        //log
        if father.token.type == TokenType.logarithm2 {
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
    func trigonometricTransform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        let transNode = EquationNode(token: Token(type: TokenType.trigonometric, text: EquationTree.trigonometricTransformDict[father.token.text]!))
        
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = uncle
        uncle.father = transNode
    }
    //l(b|g|n)(A) = B  ==>  A = (2|10|e) ^ B
    func logarithm1Transform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        let transNode = EquationNode(token: Token(type: TokenType.power, text:"power"))
        var brother : EquationNode!
        switch father.token.text {
        case "ln" :
            brother = EquationNode(token: Token(type: TokenType.const, text: "e"))
        case "lb" :
            brother = EquationNode(token: Token(type: TokenType.integer, text: "2"))
        case "lg" :
            brother = EquationNode(token: Token(type: TokenType.integer, text: "10"))
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
    func logarithm2Transform(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        var transNode : EquationNode
        var brother : EquationNode
        if variable == father.leftChild {
            brother = father.rightChild!
            transNode = EquationNode(token: Token(type: TokenType.root, text:"root"))
        }else{
            brother = father.leftChild!
            transNode = EquationNode(token: Token(type: TokenType.power, text:"power"))
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
    func transformLeftChild(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
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
    func transformRightChild(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild!
        var transNode : EquationNode
        let leftBrother : EquationNode = father.leftChild!
        
        switch father.token.type {
        case TokenType.minus , TokenType.plus :
            transNode = EquationNode(token: Token(type: TokenType.minus, text:"minus"))
        case TokenType.multiply , TokenType.divide :
            transNode = EquationNode(token: Token(type: TokenType.divide, text:"divide"))
        default:
            transNode = EquationNode(token: Token(type: TokenType.logarithm2, text:"log"))
        }
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        leftBrother.father = transNode
        uncle.father = transNode

        switch father.token.type {
        case TokenType.plus , TokenType.multiply:
            transNode.leftChild = uncle
            transNode.rightChild = leftBrother
        case TokenType.minus , TokenType.divide , TokenType.power , TokenType.root:
            transNode.leftChild = leftBrother
            transNode.rightChild = uncle
        default:
            break
        }
        if father.token.text == "root" {
            let node = EquationNode(token: Token(type: TokenType.divide, text: "divide"))
            let lnode = EquationNode(token: Token(type: TokenType.float, text: "1"))
            node.leftChild = lnode
            lnode.father = node
            node.rightChild = transNode
            transNode.rightChild = node
            grandfather.rightChild = node
            node.father = grandfather
        }
    }
}
