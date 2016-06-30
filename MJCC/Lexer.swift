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
                return Token(type: .leftBracket, text: "leftBracket")
            case ")" :
                consume()
                return Token(type: .rightBracket, text: "rightBracket")
            case "," :
                consume()
                return Token(type: .comma, text: "comma")
            case "=" :
                consume()
                return Token(type: .equal, text: "equal")
            case "{" :
                return variable()
            case "0" ... "9" :
                return number()
            case "a" ... "z" , "A" ... "Z" :
                return functionOrConst()
            case "!" :
                return factorial()
            case "^" :
                consume()
                return Token(type: .power, text: "power")
            case "~" :
                consume()
                return Token(type: .root, text: "root")
            case "*" :
                consume()
                return Token(type: .multiply,text: "multiply")
            case "/" :
                consume()
                return Token(type: .divide,text: "divide")
            case "+" :
                consume()
                return Token(type: .plus,text: "plus")
            case "-" :
                consume()
                return Token(type: .minus,text: "minus")
            default:
                break
            }
        }
        return Token(type: .eof, text: "EOF")
    }
    
    func ws() {
        while c == " " || c == "\r" || c == "\n" || c == "\t" {
            consume()
        }
    }
    func factorial() -> Token {
        var type : TokenType = .factorial
        var text : String = "factorial"
        match("!")
        if c == "!" {
            type = .doubleFactorial
            text = "doubleFactorial"
            match("!")
        }
        return Token(type: type, text: text)
    }
    
    func number() -> Token {
        var text : String = ""
        var type : TokenType = .integer
        if isZero() {
            type = .float
            match("0")
            text += "0"
            match(".")
            text += "."
            while isNumber() {
                text.append(c)
                consume()
            }
        }else{
            while isNumber() {
                text.append(c)
                consume()
            }
            if isDot() {
                type = .float
                match(".")
                text += "."
                while isNumber() {
                    text.append(c)
                    consume()
                }
            }
        }
        return Token(type: type, text: text)
    }
    
    func variable() -> Token {
        var text : String = String("{")
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
        text += "}"
        return Token(type: .variable, text: text)
    }
    func functionOrConst() -> Token {
        var text : String = String(c)
        var type : TokenType = .trigonometric
        consume()
        
        while isLetter() {
            text.append(c)
            consume()
        }
        switch text {
        case "cot" , "tan" , "sin" , "cos" , "asin" , "acos" , "atan" , "acot":
            type = .trigonometric
        case "lg" , "ln" , "lb" :
            type = .logarithm1
        case "log" :
            type = .logarithm2
        case "e" , "PI" :
            type = .const
        default:
            let ex : NSException = NSException(name: "TokeyError", reason: "unknown fuction \"\(text)\"", userInfo: nil)
            ex.raise()
        }
        
        return Token(type: type, text: text)
    }
    
}
