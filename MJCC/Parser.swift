//
//  Parser.swift
//  MJCC
//
//  Created by MJsaka on 16/6/16.
//  Copyright © 2016年 MJsaka. All rights reserved.
//
/*
 
 ZERO: 0
 NON_ZERO_NUM: [1-9]
 NUM: [0-9]
 
 CHAR: [a-zA-Z]
 WORD: CHAR(CHAR|NUM)*
 VARIABLE: '$''{'WORD'}'
 
 INTEGER: NON_ZERO_NUM(NUM)*
 FLOAT: (INTERGER|ZERO)'.'(NUM)*
 CONST: e , PI
 
 trigonometric: sin | cos | tan | cot | asin | acos | atan | acot
 logarithm2: log
 
 FACTORIAL: ! 
 DOUBLE_FACTORIAL: !!
 POWER_AND_ROOT: ^ | ~
 MULTIPLY_AND_DIVIDE: * | /
 PLUS_AND_MINUS: + | -
 
 META:  INTEGER | VARIABLE | FLOAT | '('EXP')'
 
 EXP0:  META(POWER_AND_ROOT META)? |
        INTERGER (FACTORIAL||DOUBLE_FACTORIAL) |
        trigonometric META |
        logarithm1 META |
        logarithm2'('EXP','EXP')'
 EXP1:  EXP0 (MULTIPLY_AND_DIVIDE EXP0)*
 EXP:   EXP1 (PLUS_AND_MINUS EXP1)*
 PARSE:  EXP = EXP
 */
import UIKit

class Parser: NSObject {
    let input : Lexer
    var lookahead : Token
    var error : Bool

    init(input : Lexer) {
        self.input = input
        self.lookahead = input.nextToken()
        self.error = false
    }
    
    func consume() {
        if lookahead.type != .eof {
            lookahead = input.nextToken()
        }
    }
    
    func match(type : TokenType) -> EquationNode{
        if lookahead.type == type {
            let node = EquationNode(token: lookahead)
            consume()
            return node
        }else {
            return unexpectedToken()
        }
    }
    func unexpectedToken() -> EquationNode {
        error = true
        return EquationNode(token: lookahead)
    }
    func variable() -> EquationNode {
        return match(.variable)
    }
    func meta() -> EquationNode {
        switch lookahead.type {
        case .leftBracket :
            match(.leftBracket)
            let node = exp()
            match(.rightBracket)
            return node
        case .variable , .integer , .float :
            return match(lookahead.type)
        default:
            return unexpectedToken()
        }
    }
    func exp0() -> EquationNode  {
        switch lookahead.type {
        case .trigonometric , .logarithm1:
            let node = match(lookahead.type)
            node.leftChild = meta()
            node.leftChild?.father = node
            return node
        case .logarithm2 :
            let node = match(.logarithm2)
            match(.leftBracket)
            node.leftChild = exp()
            match(.comma)
            node.rightChild = exp()
            match(.rightBracket)
            
            node.leftChild?.father = node
            node.leftChild?.father = node
            return node
        case .integer :
            let node = meta()
            if lookahead.type == .factorial || lookahead.type == .doubleFactorial  {
                let father = match(lookahead.type)
                father.leftChild = node
                father.leftChild?.father = father
                return father
            }else if lookahead.type == .power || lookahead.type == .root {
                let father = match(lookahead.type)
                father.leftChild = node
                father.rightChild = meta()
                father.leftChild?.father = father
                father.rightChild?.father = father
                return father
            }else {
                return node
            }
        case .float , .variable , .const, .leftBracket:
            let node = meta()
            if lookahead.type == .power || lookahead.type == .root {
                let father = match(lookahead.type)
                father.leftChild = node
                father.rightChild = meta()
                father.leftChild?.father = father
                father.rightChild?.father = father
                return father
            }else {
                return node
            }
        default:
            return unexpectedToken()
        }
    }
    func exp1() -> EquationNode {
        var node = exp0()
        while lookahead.type == .multiply || lookahead.type == .divide {
            let father = match(lookahead.type)
            father.leftChild = node
            father.rightChild = exp0()
            father.leftChild?.father = father
            father.rightChild?.father = father
            node = father
        }
        return node
    }
    func exp() -> EquationNode {
        var node : EquationNode
        if lookahead.text == "minus" {
            node = match(.minus)
            let t = Token(type: .float, text: "0")
            node.leftChild = EquationNode(token: t)
            node.leftChild?.father = node
            node.rightChild = exp1()
            node.rightChild?.father = node
        }else{
            node = exp1()
        }
        while lookahead.type == .plus || lookahead.type == .minus {
            let father = match(lookahead.type)
            
            father.leftChild = node
            father.rightChild = exp1()
            
            father.leftChild?.father = father
            father.rightChild?.father = father
            node = father
        }
        return node
    }
    func parse() -> [EquationTree] {
        var trees = [EquationTree]()
        repeat{
            let left = variable()
            let root = match(.equal)
            let right = exp()
            root.leftChild = left
            root.rightChild = right
            left.father = root
            right.father = root
            trees.append(EquationTree(root: root))
            match(.simicolon)
        }while lookahead.type != .eof
        match(.eof)
        var results = [String]()
        for tree in trees {
            let r = tree.root.leftChild!.token.text
            if results.contains(r) {
                error = true
            }else{
                results.append(r)
            }
        }
        return reorderTrees(trees)
    }
    
    func reorderTrees(trees : [EquationTree]) -> [EquationTree] {
        var newTrees = [EquationTree]()
        //rs辅助找到每棵树在新森林中的位置，与新森林同步变化
        var rs = [String]()
        for tree in trees {
            newTrees.append(tree)
            rs.append(tree.resultVariable())
        }
        //遍历原森林，找到每一棵树在新森林中的位置，并将原森林中的该树插入到新森林的合适位置
        for tree in trees {
            let vs = tree.variables()
            let r = tree.resultVariable()
            //该树在新森林中的原位置，备删除用
            var index = 0
            for i in 0 ..< rs.count {
                if r == rs[i] {
                    index = i
                    break
                }
            }
            //该树在新森林中的新位置，备插入用
            //如果index树中的变量是i树的结果，则index树应该在i树之后计算
            //即index应大于i，否则应将index树插入到最大的i树之后，即newIndex = i + 1
            var newIndex = index
            for v in vs {
                for i in 0 ..< rs.count{
                    if v == rs[i] && i > newIndex {
                        newIndex = i
                    }
                }
            }
            if newIndex > index {
                rs.insert(rs[index], atIndex: newIndex + 1)
                newTrees.insert(newTrees[index], atIndex: newIndex + 1)
                
                rs.removeAtIndex(index)
                newTrees.removeAtIndex(index)
            }
        }
        //经过上述遍历之后，新森林应该已经正确排序，否则应该是有变量循环引用
        //故再重复上述遍历，检查是否循环引用变量
        for tree in trees {
            let vs = tree.variables()
            let r = tree.resultVariable()
            //该树在新森林中的原位置
            var index = 0
            for i in 0 ..< rs.count {
                if r == rs[i] {
                    index = i
                    break
                }
            }
            //该树在新森林中的新位置，若比原位置大，说明有循环引用
            for v in vs {
                for i in 0 ..< rs.count{
                    if v == rs[i] && i >= index {
                        error = true
                        return newTrees
                    }
                }
            }
        }
        return newTrees
    }
}
