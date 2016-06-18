//
//  Token.swift
//  MJCC
//
//  Created by MJsaka on 16/6/15.
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
 */

import UIKit
enum TokenType : UInt {
    case eof = 0
    
    case leftBracket = 1 //(
    case rightBracket = 2 //)
    case comma  = 3 //,
    
    case variable = 4 //${NAME}
    case integer = 5
    case float = 6
    
    case powerAndRoot = 7  //^  ~

    case function1 = 8 //cot  tan  sin  cos
    case function1t2 = 9 //lg ln lb  -->  log
    case function2 = 10 // log
    
    case factorial = 11 //!  !!
    case multiplyAndDivide  = 12 //*  /
    case plusAndMinus  = 13 //+  -
    
    case equal  = 14 //=
}

class Token: NSObject {
    let type : TokenType
    let text : String
    required init(type : TokenType , text : String) {
        self.type = type
        self.text = text
    }
    override var description: String {
        return "<'\(type)','\(text)'>"
    }
}
