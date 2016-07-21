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
 
 
 INTEGER: NON_ZERO_NUM(NUM)*
 FLOAT: (INTERGER|ZERO)'.'(NUM)*
 CONST: e , PI
 VARIABLE: '{'*'}'

 trigonometric: sin | cos | tan | cot | asin | acos | atan | acot
 logarithm2: log
 logarithm1: lg | ln | lb

 FACTORIAL: ! | !!
 POWER_AND_ROOT: ^ | ~
 MULTIPLY_AND_DIVIDE: * | /
 PLUS_AND_MINUS: + | -
 
 META:  INTEGER | VARIABLE | FLOAT | '('EXP')'
 
 EXP0:  EXP0:  META(POWER_AND_ROOT META)? |
        INTERGER (FACTORIAL) |
        (trigonometric | logarithm1) META |
        logarithm2'('EXP','EXP')'
 EXP1:  EXP0 (MULTIPLY_AND_DIVIDE EXP0)*
 EXP:  (minus)? EXP1 (PLUS_AND_MINUS EXP1)*
 PARSE: VARIABLE = EXP
 */
import UIKit
import Localize_Swift

class Parser: NSObject {
    let lexer : Lexer
    var lookahead : Token!

    init(lexer : Lexer) {
        self.lexer = lexer
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
            error = GrammarError(type: .unExpectedToken, info: "'\(lookahead.text)' \("inputError".localized()) , \("expected".localized()) '\(type)'")
            return (node , error)
        }
    }
    
    func variable() -> (node : EquationNode? , error : GrammarError?) {
        return match(.variable)
    }
    //META:  INTEGER | VARIABLE | FLOAT | '('EXP')'
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
            error = GrammarError(type: .unExpectedToken, info: "'\(lookahead.text)' \("unrecognizable".localized())")
            return (node , error)
        }
    }
/*
     EXP0:  META(POWER_AND_ROOT META)? |
     INTERGER (FACTORIAL) |
     (trigonometric | logarithm1) META |
     logarithm2'('EXP','EXP')'
 */
    func exp0() -> (node : EquationNode? , error : GrammarError?)  {
        var node : EquationNode? , error : GrammarError?
        switch lookahead.type {
        case .trigonometric , .logarithm1:
            let n = match(lookahead.type)
            if let e = n.error {
                error = e
                return (node , error)
            }
            node = n.node!
            
            let l = meta()
            if let e = l.error {
                error = e
                return (node , error)
            }
            let left = l.node!
            
            node!.leftChild = left
            node!.leftChild?.father = node
            return (node , error)
        case .logarithm2 :
            let n = match(.logarithm2)
            if let e = n.error {
                error = e
                return (node , error)
            }
            node = n.node!
            
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
            let left = l.node!
            
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
            let right = r.node!
            
            let rb = match(.rightBracket)
            if let e = rb.error {
                error = e
                return (node , error)
            }
            
            node!.leftChild = left
            node!.rightChild = right
            node!.leftChild?.father = node
            node!.leftChild?.father = node
            return (node , error)
        case .integer :
            let n = meta()
            if let e = n.error {
                error = e
                return (node , error)
            }
            node = n.node!
            
            if lookahead.type == .factorial {
                let f = match(.factorial)
                if let e = f.error {
                    error = e
                    return (node , error)
                }
                let father = f.node!
                
                father.leftChild = node
                father.leftChild?.father = father
                node = father
                return (node , error)
            }else if lookahead.type == .power || lookahead.type == .root {
                let f = match(lookahead.type)
                if let e = f.error {
                    error = e
                    return (node , error)
                }
                let father = f.node!
                
                let r = meta()
                if let e = r.error {
                    error = e
                    return (node , error)
                }
                let right = r.node!
                
                father.leftChild = node
                father.leftChild?.father = father
                father.rightChild = right
                father.rightChild?.father = father
                node = father
                return (node , error)
            }
            return (node , error)
        case .float , .variable , .const, .leftBracket:
            let n = meta()
            if let e = n.error {
                error = e
                return (node , error)
            }
            node = n.node!
            
            if lookahead.type == .power || lookahead.type == .root {
                let f = match(lookahead.type)
                if let e = f.error {
                    error = e
                    return (node , error)
                }
                let father = f.node!
                
                let r = meta()
                if let e = r.error {
                    error = e
                    return (node , error)
                }
                let right = r.node!
                
                father.leftChild = node
                father.leftChild?.father = father
                father.rightChild = right
                father.rightChild?.father = father
                node = father
                return (node , error)
            }
            return (node , error)
        default:
            error = GrammarError(type: .unExpectedToken, info: "'\(lookahead.text)' \("unrecognizable".localized())")
            return (node , error)
        }
    }
    
//    EXP1:  EXP0 (MULTIPLY_AND_DIVIDE EXP0)*
    func exp1() -> (node : EquationNode? , error : GrammarError?) {
        var node : EquationNode? , error : GrammarError?
        let exp = exp0()
        if let e = exp.error {
            error = e
            return (node , error)
        }
        node = exp.node!
        
        while lookahead.type == .multiply || lookahead.type == .divide {
            let f = match(lookahead.type)
            if let e = f.error {
                error = e
                return (node , error)
            }
            let father = f.node!
            
            let r = exp0()
            if let e = r.error {
                error = e
                return (node , error)
            }
            let right = r.node!
            
            father.leftChild = node
            father.rightChild = right
            father.leftChild?.father = father
            father.rightChild?.father = father
            node = father
        }
        return (node , error)
    }
//    EXP:  (minus)? EXP1 (PLUS_AND_MINUS EXP1)*
    func exp() -> (node : EquationNode? , error : GrammarError?) {
        var node : EquationNode? , error : GrammarError?
        if lookahead.text == "minus" {
            let n = match(.minus)
            if let e = n.error {
                error = e
                return (node , error)
            }
            node = n.node!
            
            let r = exp1()
            if let e = r.error {
                error = e
                return (node , error)
            }
            let right = r.node!
            
            let t = Token(type: .float, text: "0")
            node!.leftChild = EquationNode(token: t)
            node!.leftChild?.father = node
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
            
            let r = exp1()
            if let e = r.error {
                error = e
                return (node , error)
            }
            let right = r.node!
            
            father.leftChild = node
            father.rightChild = right
            father.leftChild!.father = father
            father.rightChild!.father = father
            node = father
        }
        return (node , error)
    }
//    PARSE: VARIABLE = EXP
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
            let l = variable()
            if let e = l.error {
                error = e
                return (trees , error)
            }
            let left = l.node!
            
            let t = match(.equal)
            if let e = t.error {
                error = e
                return (trees , error)
            }
            let root = t.node!
            
            let r = exp()
            if let e = r.error {
                error = e
                return (trees , error)
            }
            let right = r.node!
            
            root.leftChild = left
            root.rightChild = right
            left.father = root
            right.father = root
            trees.append(EquationTree(root: root))
            
            let simicolon = match(.simicolon)
            if let e = simicolon.error {
                error = e
                return (trees , error)
            }
        }while lookahead.type != .eof
        
        let eof = match(.eof)
        if let e = eof.error {
            error = e
            return (trees , error)
        }
        //判断是否有结果变量重复定义
        var results = [String]()
        for tree in trees {
            let r = tree.root.leftChild!.token.text
            if results.contains(r) {
                error = GrammarError(type: .redefinedResultVariable, info: "\("result".localized()) \("variable".localized()) '\(r)' \("redefined".localized())")
                return (trees , error)
            }else{
                results.append(r)
            }
        }
        //按照计算顺序重新排序trees
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
                        error = GrammarError(type: .cyclicallyReferencedVariable, info: "\("variable".localized()) '\(v)' \("cyclical referenced".localized())")
                        return (newTrees , error)
                    }
                }
            }
        }
        return (newTrees , error)
    }
}
