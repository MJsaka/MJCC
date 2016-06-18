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
 
 FUNCTION1: sin | cos | tan | cot | arcsin | arccos | arctan | arccot
 FUNCTION1T2: lg | ln | lb
 FUNCTION2: log
 
 FACTORIAL: ! | !!
 POWER_AND_ROOT: ^ | ~
 MULTIPLY_AND_DIVIDE: * | /
 PLUS_AND_MINUS: + | -
 
 META:  INTEGER | VARIABLE | FLOAT | '('EXP')'
 
 EXP0:  META(POWER_AND_ROOT META)? |
        INTERGER FACTORIALIR | 
        FUNCTION1 META |
        FUNCTION2'('EXP','EXP')'
 EXP1:  EXP0 (MULTIPLY_AND_DIVIDE EXP0)*
 EXP:   EXP1 (PLUS_AND_MINUS EXP0)*
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
        if lookahead.type != TokenType.eof {
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
        case TokenType.leftBracket :
            match(TokenType.leftBracket)
            let node = exp()
            match(TokenType.rightBracket)
            return node
        default:
            return match(lookahead.type)
        }
    }
    func exp0() -> EquationNode  {
        switch lookahead.type {
        case TokenType.function1 :
            let node = match(TokenType.function1)
            node.leftChild = meta()
            node.leftChild?.father = node
            return node
        case TokenType.function1t2 :
            let node = EquationNode(token: Token(type: TokenType.function2, text: "log"))
            switch lookahead.text {
            case "ln":
                node.leftChild = EquationNode(token: Token(type: TokenType.float, text: String(M_E)))
            case "lg":
                node.leftChild = EquationNode(token: Token(type: TokenType.float, text: "10"))
            case "lb":
                node.leftChild = EquationNode(token: Token(type: TokenType.float, text: "2"))
            default:
                break
            }
            node.leftChild?.father = node
            match(TokenType.function1t2)
            node.rightChild = meta()
            node.rightChild?.father = node
            return node
        case TokenType.function2 :
            let node = match(TokenType.function2)
            match(TokenType.leftBracket)
            node.leftChild = exp()
            match(TokenType.comma)
            node.rightChild = exp()
            match(TokenType.rightBracket)
            
            node.leftChild?.father = node
            node.leftChild?.father = node
            return node
        case TokenType.integer :
            let node = meta()
            if lookahead.type == TokenType.factorial {
                let father = match(TokenType.factorial)
                father.leftChild = node
                father.leftChild?.father = father
                return father
            }else if lookahead.type == TokenType.powerAndRoot {
                let father = match(TokenType.powerAndRoot)
                father.leftChild = node
                father.rightChild = meta()
                father.leftChild?.father = father
                father.rightChild?.father = father
                return father
            }else {
                return node
            }
        case TokenType.float , TokenType.variable , TokenType.leftBracket:
            let node = meta()
            if lookahead.type == TokenType.powerAndRoot {
                let father = match(TokenType.powerAndRoot)
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
        while lookahead.type == TokenType.multiplyAndDivide {
            let father = match(TokenType.multiplyAndDivide)
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
            node = match(TokenType.plusAndMinus)
            let t = Token(type: TokenType.float, text: "0")
            node.leftChild = EquationNode(token: t)
            node.leftChild?.father = node
            node.rightChild = exp1()
            node.rightChild?.father = node
        }else{
            node = exp1()
        }
        while lookahead.type == TokenType.plusAndMinus {
            let father = match(TokenType.plusAndMinus)
            
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
        let root = match(TokenType.equal)
        let right = exp()
        
        match(TokenType.eof)
        
        root.leftChild = left
        root.rightChild = right
        left.father = root
        right.father = root
        return EquationTree(root: root)
    }
}
