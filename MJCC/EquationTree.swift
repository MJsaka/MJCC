//
//  EquationTree.swift
//  MJCC
//
//  Created by MJsaka on 16/6/17.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class BNode: NSObject {
    var father : BNode?
    var leftChild : BNode?
    var rightChild : BNode?
}
class BTree: NSObject {
    let root : BNode
    init(root : BNode) {
        self.root = root
    }
    static func traverseTreePreOrder(root node : BNode , visitor visit : (BNode) -> Void) {
        visit(node)
        if let l = node.leftChild {
            traverseTreePreOrder(root: l , visitor: visit)
        }
        if let r = node.rightChild {
            traverseTreePreOrder(root: r, visitor: visit)
        }
    }
    static func traverseTreeInOrder(root node : BNode , visitor visit : (BNode) -> Void) {
        if let l = node.leftChild {
            traverseTreePreOrder(root: l , visitor: visit)
        }
        visit(node)
        if let r = node.rightChild {
            traverseTreePreOrder(root: r, visitor: visit)
        }
    }
    static func traverseTreePostOrder(root node : BNode , visitor visit : (BNode) -> Void) {
        if let l = node.leftChild {
            traverseTreePreOrder(root: l , visitor: visit)
        }
        if let r = node.rightChild {
            traverseTreePreOrder(root: r, visitor: visit)
        }
        visit(node)
    }
}

class EquationNode: BNode {
    var token : Token
    init(token : Token) {
        self.token = token
    }
}

class EquationTree: BTree {
    var variables : [EquationNode]
    //三角函数直接运算表
    let directTransDict1 = ["sin"       : "arcsin",
                            "cos"       : "arccos",
                            "tan"       : "arctan",
                            "cot"       : "arccot",
                            "arcsin"    : "sin",
                            "arccos"    : "cos",
                            "arctan"    : "tan",
                            "arccot"    : "cot"]
    //四则、乘方、开方直接逆运算表
    let directTransDict2 = ["plus"      : "minus",
                            "minus"     : "plus",
                            "multiply"  : "divide",
                            "divide"    : "multiply",
                            "power"     : "root",
                            "root"      : "power"]
    //运算符名字转换表
    let operatorNameDict = ["plus"              : "+",
                            "minus"             : "-",
                            "multiply"          : "*",
                            "divide"            : "/",
                            "power"             : "^",
                            "root"              : "~",
                            "factorial"         : "!",
                            "doubleFactorial"   : "!!",
                            "equal"             : "=",
                            "sin"               : "sin",
                            "cos"               : "cos",
                            "tan"               : "tan",
                            "cot"               : "cot",
                            "arcsin"            : "arcsin",
                            "arccos"            : "arccos",
                            "arctan"            : "arctan",
                            "arccot"            : "arccot",
                            "log"               : "log"]
    override init(root : BNode) {
        self.variables = [EquationNode]()
        super.init(root: root)
        BTree.traverseTreePreOrder(root: root) { (node) in
            let n = node as! EquationNode
            if n.token.type == TokenType.variable {
                self.variables.append(n)
            }
        }
    }
    //从表达式树生成表达式串
    func equationString() -> String {
        return subString(node : root as! EquationNode)
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
        let father : EquationNode = variable.father as! EquationNode
        if father == root {
            return
        }
        let grandfather : EquationNode = father.father as! EquationNode
        if grandfather == root {
            if father == grandfather.rightChild {
                let uncle = grandfather.leftChild as! EquationNode
                grandfather.leftChild = father
                grandfather.rightChild = uncle
            }
            transform(variable, father: father, grandfather: root as! EquationNode)
        }else{
            recursionTransform(father)
            transform(variable, father: father, grandfather: root as! EquationNode)
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
        if father.token.type == TokenType.function1 {
            directTransform1(variable, father: father, grandfather: grandfather)
            return
        }
        //log
        if father.token.type == TokenType.function2 {
            transformFunction2(variable, father: father, grandfather: grandfather)
            return
        }
        // A @ B = C  ==>  A = C -@ B
        if variable == father.leftChild {
            directTransform2(variable, father: father, grandfather: grandfather)
            return
        }
        if variable == father.rightChild {
            transformRightChild(variable, father: father, grandfather: grandfather)
            return
        }
    }
    //func(A) = B  ==>  A = -func(B)
    func directTransform1(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild as! EquationNode
        let transNode = EquationNode(token: Token(type: TokenType.function1, text: directTransDict1[father.token.text]!))
        
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = uncle
        uncle.father = transNode
    }
    // A + B = C  ==>  A = C - B
    // A - B = C  ==>  A = C + B
    // A * B = C  ==>  A = C / B
    // A / B = C  ==>  A = C * B
    // A ^ B = C  ==>  A = C ~ B
    // A ~ B = C  ==>  A = C ^ B
    func directTransform2(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild as! EquationNode
        let transNode = EquationNode(token: Token(type: father.token.type, text: directTransDict2[father.token.text]!))
        let rightBrother = father.rightChild as! EquationNode
        
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        transNode.leftChild = uncle
        uncle.father = transNode
        transNode.rightChild = rightBrother
        rightBrother.father = transNode
    }
    //logA(B) = C  ==>  A = B ~ C
    //logB(A) = C  ==>  A = B ^ C
    func transformFunction2(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild as! EquationNode
        var transNode : EquationNode
        var brother : EquationNode
        if variable == father.leftChild {
            brother = father.rightChild as! EquationNode
            transNode = EquationNode(token: Token(type: TokenType.powerAndRoot, text:"root"))
        }else{
            brother = father.leftChild as! EquationNode
            transNode = EquationNode(token: Token(type: TokenType.powerAndRoot, text:"power"))
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
    // B + A = C  ==>  A = C - B
    // B - A = C  ==>  A = B - C
    // B * A = C  ==>  A = C / B
    // B / A = C  ==>  A = B / C
    // B ^ A = C  ==>  A = log(B , C)
    // B ~ A = C  ==>  A = 1 / log(B , C)
    func transformRightChild(variable : EquationNode , father : EquationNode , grandfather : EquationNode)
    {
        let uncle : EquationNode = grandfather.rightChild as! EquationNode
        var transNode = EquationNode(token: Token(type: TokenType.powerAndRoot, text:"log"))
        let leftBrother : EquationNode = father.leftChild as! EquationNode
        
        switch father.token.text {
        case "plus" , "minus" :
            transNode = EquationNode(token: Token(type: TokenType.plusAndMinus, text:"minus"))
        case "multiply" , "divide" :
            transNode = EquationNode(token: Token(type: TokenType.multiplyAndDivide, text:"divide"))
        default:
            break
        }
        grandfather.leftChild = variable
        variable.father = grandfather
        grandfather.rightChild = transNode
        transNode.father = grandfather
        
        leftBrother.father = transNode
        uncle.father = transNode

        switch father.token.text {
        case "plus" , "multiply":
            transNode.leftChild = uncle
            transNode.rightChild = leftBrother
        case "minus" , "divide":
            transNode.leftChild = leftBrother
            transNode.rightChild = uncle
        case "power" , "root":
            transNode.leftChild = leftBrother
            transNode.rightChild = uncle
        default:
            break
        }
        if father.token.text == "root" {
            let node = EquationNode(token: Token(type: TokenType.multiplyAndDivide, text: "divide"))
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
