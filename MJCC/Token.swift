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
 
 TRIGONOMETRIC: sin | cos | tan | cot | asin | acos | atan | acot
 logarithm2: log
 
 FACTORIAL: ! 
 DOUBLE_FACTORIAL: !!
 POWER_AND_ROOT: ^ | ~
 MULTIPLY_AND_DIVIDE: * | /
 PLUS_AND_MINUS: + | -
 */

import UIKit
enum TokenType : UInt {
    case eof = 0
    
    case leftBracket //(
    case rightBracket //)
    case comma //,
    case simicolon //;
    
    case variable //${NAME}
    case integer
    case float
    case const
    
    case power //^
    case root  //~

    case trigonometric //cot  tan  sin  cos
    case logarithm1 //ln lg lb
    case logarithm2  // log
    
    case factorial //!  !!
    
    case divide //÷
    case multiply //*
    
    case minus // -
    case plus // +
    
    case equal//=
}

class Token: NSObject {
    let type : TokenType
    let text : String
    required init(type : TokenType , text : String) {
        self.type = type
        self.text = text
    }
    override var description: String {
        return "<'\(type)' , '\(text)'>"
    }
}
