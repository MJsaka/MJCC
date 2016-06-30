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

    init(input : Lexer) {
        self.input = input
        lookahead = input.nextToken()
        print(lookahead)
    }
    
    func consume() {
        if lookahead.type != .eof {
            lookahead = input.nextToken()
            print(lookahead)
        }
    }
    
    func match(type : TokenType) -> EquationNode{
        if lookahead.type == type {
            let node = EquationNode(token: lookahead)
            consume()
            return node
        }else {
            let ex : NSException = NSException(name: "GrammarError", reason: "expect \(type) but found \(lookahead.type)", userInfo: nil)
            ex.raise()
            return EquationNode(token: lookahead)
        }
    }
    func meta() -> EquationNode {
        switch lookahead.type {
        case .leftBracket :
            match(.leftBracket)
            let node = exp()
            match(.rightBracket)
            return node
        default:
            return match(lookahead.type)
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
            let ex : NSException = NSException(name: "GrammarError", reason: "unexpected token type: \(lookahead.type)", userInfo: nil)
            ex.raise()
            return EquationNode(token: lookahead)
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
    func parse() -> EquationTree {
        let left = exp()
        let root = match(.equal)
        let right = exp()
        
        match(.eof)
        
        root.leftChild = left
        root.rightChild = right
        left.father = root
        right.father = root
        return EquationTree(root: root)
    }
}
