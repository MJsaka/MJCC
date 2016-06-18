//
//  Lexer.swift
//  MJCC 词法分析
//
//  Created by MJsaka on 16/6/15.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class Lexer: NSObject {
    let input : String
    var p : String.Index
    var c : Character
    
    required init(input : String) {
        self.input = input
        self.p = input.startIndex
        self.c = input[p]
    }
    func consume() {
        p = p.successor()
        if p < input.endIndex {
            c = input[p]
        }else{
            c = "\0"
        }
    }
    func match(x : Character) {
        if x == c {
            consume()
        }else{
            let ex : NSException = NSException(name: "TokenError", reason: "expect \(x) but found \(c)", userInfo: nil)
            ex.raise()
        }
    }
    func isLetter() -> Bool {
        return c >= "a" && c <= "z" || c >= "A" && c <= "Z"
    }
    func isLowerCaseLetter() -> Bool {
        return c >= "a" && c <= "z"
    }
    func isNumber() -> Bool {
        return c >= "0" && c <= "9"
    }
    func isZero() -> Bool {
        return c == "0"
    }
    func isDot() -> Bool {
        return c == "."
    }
    
    func nextToken() -> Token {
        while p < input.endIndex
        {
            switch c {
            case " " , "\t" , "\n" , "\r":
                ws()
                continue
            case "(" :
                consume()
                return Token(type: TokenType.leftBracket, text: "leftBracket")
            case ")" :
                consume()
                return Token(type: TokenType.rightBracket, text: "rightBracket")
            case "," :
                consume()
                return Token(type: TokenType.comma, text: "comma")
            case "=" :
                consume()
                return Token(type: TokenType.equal, text: "equal")
            case "$" :
                return variable()
            case "0" ... "9" :
                return number()
            case "a" ... "z" , "A" ... "Z" :
                return function()
            case "!" :
                return factorial()
            case "^" :
                consume()
                return Token(type: TokenType.powerAndRoot, text: "power")
            case "~" :
                consume()
                return Token(type: TokenType.powerAndRoot, text: "root")
            case "*" :
                consume()
                return Token(type: TokenType.multiplyAndDivide,text: "multiply")
            case "/" :
                consume()
                return Token(type: TokenType.multiplyAndDivide,text: "divide")
            case "+" :
                consume()
                return Token(type: TokenType.plusAndMinus,text: "plus")
            case "-" :
                consume()
                return Token(type: TokenType.plusAndMinus,text: "minus")
            default:
                break
            }
        }
        return Token(type: TokenType.eof, text: "EOF")
    }
    
    func ws() {
        while c == " " || c == "\r" || c == "\n" || c == "\t" {
            consume()
        }
    }
    func factorial() -> Token {
        var text : String = "factorial"
        match("!")
        if c == "!" {
            match("!")
            text = "doubleFactorial"
        }
        if c == "!" {
            let ex : NSException = NSException(name: "TokeyError", reason: "too much '!'", userInfo: nil)
            ex.raise()
        }
        return Token(type: TokenType.factorial, text: text)
    }
    
    func number() -> Token {
        var text : String = String(c)
        var type : TokenType = TokenType.integer
        if isZero() {
            type = TokenType.float
            consume()
            text.append(c)
            match(".")
        }
        consume()
        while isNumber() {
            text.append(c)
            consume()
        }
        if isDot() {
            type = TokenType.float
            text.append(c)
            consume()
            while isNumber() {
                text.append(c)
                consume()
            }
        }
       
        return Token(type: type, text: text)
    }
    
    func variable() -> Token {
        var text : String = String()
        consume()
        match("{")
        if !isLetter(){
            let ex : NSException = NSException(name: "TokeyError", reason: "first character for variable name must be letter", userInfo: nil)
            ex.raise()
        }
        text.append(c)
        consume()
        while isLetter() || isNumber() {
            text.append(c)
            consume()
        }
        match("}")
        return Token(type: TokenType.variable, text: text)
    }
    func function() -> Token {
        var text : String = String(c)
        var type : TokenType = TokenType.function1
        consume()
        
        while isLetter() {
            text.append(c)
            consume()
        }
        switch text {
        case "cot" , "tan" , "sin" , "cos" , "arcsin" , "arccos" , "arctan" , "arccot" :
            type = TokenType.function1
        case "ln" , "lg" , "lb" :
            type = TokenType.function1t2
        case "log" :
            type = TokenType.function2
        default:
            let ex : NSException = NSException(name: "TokeyError", reason: "unknown fuction \"\(text)\"", userInfo: nil)
            ex.raise()
        }
        
        return Token(type: type, text: text)
    }
    
}
