//
//  Lexer.swift
//  MJCC 词法分析
//
//  Created by MJsaka on 16/6/15.
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
 */
import UIKit
import Localize_Swift

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
    func match(x : Character) -> GrammarError? {
        if x == c {
            consume()
            return nil
        }else{
            return GrammarError(type: .unExpectedCharacter, info: "'\(c)' \("inputError".localized()) , \("expected".localized()) '\(x)'")
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
    
    func nextToken() -> (token :Token? , error : GrammarError?) {
        var token :Token? , error : GrammarError?
        while p < input.endIndex
        {
            switch c {
            case " " , "\t" , "\n" , "\r":
                ws()
                continue
            case "{" :
                return variable()
            case "0" ... "9" :
                return number()
            case "a" ... "z" , "A" ... "Z" :
                return functionOrConst()
            case "!" :
                return factorial()
            case "(" :
                error = match("(")
                if error == nil {
                    token = Token(type: .leftBracket, text: "leftBracket")
                }
            case ")" :
                error = match(")")
                if error == nil{
                    token = Token(type: .rightBracket, text: "rightBracket")
                }
            case "," :
                error = match(",")
                if error == nil {
                    token = Token(type: .comma, text: "comma")
                }
            case ";" :
                error = match(";")
                if error == nil {
                    token = Token(type: .simicolon, text: "simicolon")
                }
            case "=" :
                error = match("=")
                if error == nil {
                    token = Token(type: .equal, text: "equal")
                }
            case "^" :
                error = match("^")
                if error == nil {
                    token = Token(type: .power, text: "power")
                }
            case "~" :
                error = match("~")
                if error == nil {
                    token = Token(type: .root, text: "root")
                }
            case "*" :
                error = match("*")
                if error == nil {
                    token = Token(type: .multiply,text: "multiply")
                }
            case "/" :
                error = match("/")
                if error == nil {
                    token = Token(type: .divide,text: "divide")
                }
            case "+" :
                error = match("+")
                if error == nil {
                    token = Token(type: .plus,text: "plus")
                }
            case "-" :
                error = match("-")
                if error == nil {
                    token = Token(type: .minus,text: "minus")
                }
            default:
                error = GrammarError(type: .unExpectedCharacter, info: "\("unrecognizable".localized()) \("character".localized()) '\(c)'")
            }
            return (token , error)
        }//while
        token = Token(type: .eof, text: "eof")
        return (token , error)
    }
    
    func ws() {
        while c == " " || c == "\r" || c == "\n" || c == "\t" {
            consume()
        }
    }
    func factorial() ->  (token :Token? , error : GrammarError?)  {
        var token : Token? , error : GrammarError?
        let type : TokenType = .factorial
        var text : String = "factorial"
        //第一个'!'
        consume()
        //第二个'!'
        if c == "!" {
            text = "doubleFactorial"
            consume()
        }
        token = Token(type: type, text: text)
        return (token , error)
    }
    
    func number() ->  (token :Token? , error : GrammarError?)  {
        var token : Token? , error : GrammarError?
        var text : String = ""
        var type : TokenType = .integer
        if isZero() {
            consume()
            type = .float
            text += "0"
            error = match(".")
            if error != nil {
                return (token , error)
            }
            text += "."
            if !isNumber() {
                error = GrammarError(type: .unExpectedCharacter, info: "expected digtal after '.'".localized())
                return (token , error)
            }
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
                consume()
                type = .float
                text += "."
                if !isNumber() {
                    error = GrammarError(type: .unExpectedCharacter, info: "expected digtal after '.'".localized())
                    return (token , error)
                }
                while isNumber() {
                    text.append(c)
                    consume()
                }
            }
        }
        token = Token(type: type, text: text)
        return (token , error)
    }
    
    func variable() ->  (token :Token? , error : GrammarError?)  {
        var token :Token? , error : GrammarError?
        var text : String = ""
        error = match("{")
        if error != nil {
            return (token , error)
        }
        while p < input.endIndex && c != "}"{
            text.append(c)
            consume()
        }
        error = match("}")
        if error != nil {
            return (token , error)
        }
        token = Token(type: .variable, text: text)
        return (token , error)
    }
    func functionOrConst() ->  (token :Token? , error : GrammarError?)  {
        var token :Token? , error : GrammarError?
        var text : String = ""
        var type : TokenType = .trigonometric
        
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
            error = GrammarError(type: .unExpectedToken, info: "'\(text)' \("unrecognizable".localized())")
            return (token , error)
        }
        token = Token(type: type, text: text)
        return (token , error)
    }
    
}
