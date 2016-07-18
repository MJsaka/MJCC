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
    let lexer : Lexer
    var lookahead : Token!

    init(lexer : Lexer) {
        self.lexer = lexer
//        print("\(lookahead.type) : \(lookahead.text)")
    }
    
    func consume() -> GrammarError?{
        let t = lexer.nextToken()
        if let error = t.error {
            return error
        }else{
            lookahead = t.token!
            return nil
        }
    }
    
    func match(type : TokenType) -> (node : EquationNode? , error : GrammarError?){
        var node : EquationNode? , error : GrammarError?
        if lookahead.type == type {
            node = EquationNode(token: lookahead)
            error = consume()
            return (node , error)
        }else{
            error = GrammarError(type: .unExpectedToken, info: "expected '\(type)' but found '\(lookahead.type)'")
            return (node , error)
        }
    }
    func variable() -> (node : EquationNode? , error : GrammarError?) {
        return match(.variable)
    }
    func meta() -> (node : EquationNode? , error : GrammarError?) {
        var node : EquationNode? , error : GrammarError?
        switch lookahead.type {
        case .leftBracket :
            let l = match(.leftBracket)
            if let e = l.error{
                error = e
                return (node , error)
            }
            let n = exp()
            if let e = n.error {
                error = e
                return (node , error)
            }
            node = n.node!
            let r = match(.rightBracket)
            if let e = r.error{
                error = e
                return (node , error)
            }
            return (node , error)
        case .variable , .integer , .float , .const:
            return match(lookahead.type)
        default:
            error = GrammarError(type: .unExpectedToken, info: "unexpected token '\(lookahead.text)'")
            return (node , error)
        }
    }
    func exp0() -> (node : EquationNode? , error : GrammarError?)  {
        var node : EquationNode? , error : GrammarError?
        switch lookahead.type {
        case .trigonometric , .logarithm1:
            node = match(lookahead.type).node!
            let l = meta()
            if let e = l.error {
                error = e
                return (node , error)
            }
            node!.leftChild = l.node!
            node!.leftChild?.father = node
            return (node , error)
        case .logarithm2 :
            node = match(.logarithm2).node!
            let lb = match(.leftBracket)
            if let e = lb.error {
                error = e
                return (node , error)
            }
            let l = exp()
            if let e = l.error {
                error = e
                return (node , error)
            }
            node!.leftChild = l.node
            let comma = match(.comma)
            if let e = comma.error {
                error = e
                return (node , error)
            }
            let r = exp()
            if let e = r.error {
                error = e
                return (node , error)
            }
            node!.rightChild = r.node
            match(.rightBracket)
            
            node!.leftChild?.father = node
            node!.leftChild?.father = node
            return (node , error)
        case .integer :
            node = meta().node!
            if lookahead.type == .factorial {
                let father = match(.factorial).node!
                father.leftChild = node
                father.leftChild?.father = father
                node = father
                return (node , error)
            }else if lookahead.type == .power || lookahead.type == .root {
                let father = match(lookahead.type).node!
                father.leftChild = node
                let r = meta()
                if let e = r.error {
                    error = e
                    return (node , error)
                }
                father.leftChild?.father = father
                father.rightChild?.father = father
                node = father
                return (node , error)
            }else {
                return (node , error)
            }
        case .float , .variable , .const, .leftBracket:
            node = meta().node!
            if lookahead.type == .power || lookahead.type == .root {
                let father = match(lookahead.type).node!
                father.leftChild = node
                let r = meta()
                if let e = r.error {
                    error = e
                    return (node , error)
                }
                father.leftChild?.father = father
                father.rightChild?.father = father
                node = father
                return (node , error)
            }else {
                return (node , error)
            }
        default:
            error = GrammarError(type: .unExpectedToken, info: "unexpected token '\(lookahead.text)'")
            return (node , error)
        }
    }
    func exp1() -> (node : EquationNode? , error : GrammarError?) {
        var node : EquationNode? , error : GrammarError?
        let exp = exp0()
        if let e = exp.error {
            error = e
            return (node , error)
        }
        node = exp.node!
        while lookahead.type == .multiply || lookahead.type == .divide {
            let father = match(lookahead.type).node!
            father.leftChild = node
            let r = exp0()
            if let e = r.error {
                error = e
                return (node , error)
            }
            let right = r.node!
            father.rightChild = right
            father.leftChild?.father = father
            father.rightChild?.father = father
            node = father
        }
        return (node , error)
    }
    func exp() -> (node : EquationNode? , error : GrammarError?) {
        var node : EquationNode? , error : GrammarError?
        if lookahead.text == "minus" {
            node = match(.minus).node!
            let t = Token(type: .float, text: "0")
            node!.leftChild = EquationNode(token: t)
            node!.leftChild?.father = node
            
            let r = exp1()
            if let e = r.error {
                error = e
                return (node , error)
            }
            let right = r.node!
            node!.rightChild = right
            node!.rightChild!.father = node
        }else{
            let exp = exp1()
            if let e = exp.error {
                error = e
                return (node , error)
            }else{
                node = exp.node!
            }
        }
        while lookahead.type == .plus || lookahead.type == .minus {
            let f = match(lookahead.type)
            if let e = f.error {
                error = e
                return (node , error)
            }
            let father = f.node!
            father.leftChild = node
            let r = exp1()
            if let e = r.error {
                error = e
                return (node , error)
            }
            let right = r.node!
            father.rightChild = right
            
            father.leftChild!.father = father
            father.rightChild!.father = father
            node = father
        }
        return (node , error)
    }
    func parse() -> (trees : [EquationTree] , error : GrammarError?) {
        var trees = [EquationTree]() , error : GrammarError?
        let t = lexer.nextToken()
        if let e = t.error {
            error = e
            return (trees , error)
        }else{
            self.lookahead = t.token!
        }
        repeat{
            let left = variable()
            if let e = left.error {
                error = e
                return (trees , error)
            }
            let root = match(.equal)
            if let e = root.error {
                error = e
                return (trees , error)
            }
            let right = exp()
            if let e = right.error {
                error = e
                return (trees , error)
            }
            root.node!.leftChild = left.node!
            root.node!.rightChild = right.node!
            left.node!.father = root.node!
            right.node!.father = root.node!
            trees.append(EquationTree(root: root.node!))
            
            let simicolon = match(.simicolon)
            if let e = simicolon.error {
                error = e
                return (trees , error)
            }
        }while lookahead.type != .eof
        
        match(.eof)
        
        var results = [String]()
        for tree in trees {
            let r = tree.root.leftChild!.token.text
            if results.contains(r) {
                error = GrammarError(type: .redefinedResultVariable, info: "redefined result variable '\(r)'")
                return (trees , error)
            }else{
                results.append(r)
            }
        }
        return reorderTrees(trees)
    }
    
    func reorderTrees(trees : [EquationTree]) -> (trees : [EquationTree] , error : GrammarError?) {

        var newTrees = [EquationTree]() , error : GrammarError?
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
                        error = GrammarError(type: .cyclicallyReferencedVariable, info: "variable '\(v)' cyclical referenced")
                        return (newTrees , error)
                    }
                }
            }
        }
        return (newTrees , error)
    }
}
