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
    var error : Bool
    
    required init(input : String) {
        self.input = input
        self.p = input.startIndex
        self.c = input[p]
        self.error = false
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
            unexpectedToken()
        }
    }
    func unexpectedToken() {
        error = true
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
                match("(")
                return Token(type: .leftBracket, text: "leftBracket")
            case ")" :
                match(")")
                return Token(type: .rightBracket, text: "rightBracket")
            case "," :
                match(",")
                return Token(type: .comma, text: "comma")
            case ";" :
                match(";")
                return Token(type: .simicolon, text: "simicolon")
            case "=" :
                match("=")
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
                match("^")
                return Token(type: .power, text: "power")
            case "~" :
                match("~")
                return Token(type: .root, text: "root")
            case "*" :
                match("*")
                return Token(type: .multiply,text: "multiply")
            case "/" :
                match("/")
                return Token(type: .divide,text: "divide")
            case "+" :
                match("+")
                return Token(type: .plus,text: "plus")
            case "-" :
                match("-")
                return Token(type: .minus,text: "minus")
            default:
                unexpectedToken()
                return Token(type: .eof, text: "EOF")
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
        var text : String = ""
        match("{")
        while c != "}"{
            text.append(c)
            consume()
        }
        match("}")
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
            unexpectedToken()
        }
        
        return Token(type: type, text: text)
    }
    
}
