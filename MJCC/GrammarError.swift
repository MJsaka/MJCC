//
//  GrammarError.swift
//  MJCC
//
//  Created by MJsaka on 16/7/18.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit
enum ErrorType {
    case unExpectedToken
    case unExpectedCharacter
    case cyclicallyReferencedVariable
    case redefinedResultVariable
}

class GrammarError: NSObject {
    let type : ErrorType
    let info : String
    
    init(type : ErrorType , info : String) {
        self.type = type
        self.info = info
    }
}
