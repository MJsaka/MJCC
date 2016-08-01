//
//  GrammarError.swift
//  MJCC
//
//  Created by MJsaka on 16/7/18.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit
enum ErrorType {
    case matchError
    case unrecognizableSymbol
    case unexpectedToken
    case cyclicallyReferencedVariable
    case recalculatedResultVariable
    case selfReferencedVariable
}

class GrammarError: NSObject {
    let type : ErrorType
    let info : String
    
    init(type : ErrorType , info : String) {
        self.type = type
        self.info = info
    }
    
    class func matchError(input input : String , expect : String) -> GrammarError {
        return GrammarError(type: .matchError, info: "'\(input)' \("inputError".localized()), \("expect".localized()) '\(expect)'")
    }
    class func unrecognizableSymbol(input : String) -> GrammarError{
        return GrammarError(type: .unrecognizableSymbol, info: "\("unrecognizable".localized()) '\(input)'")
    }
    class func unexpectedToken(input : String) -> GrammarError {
        return GrammarError(type: .unexpectedToken, info: "'\(input)' \("inputError".localized())")
    }
    class func recalculatedResultVariable(variable : String) -> GrammarError {
        return GrammarError(type: .recalculatedResultVariable, info: "\("variable".localized())'\(variable)'\("recalculated".localized())")
    }
    class func cyclicallyReferencedVariable(variable : String) -> GrammarError {
        return GrammarError(type: .cyclicallyReferencedVariable, info: "\("variable".localized())'\(variable)'\("cyclical referenced".localized())")
    }
    class func selfReferencedVariable(variable : String) -> GrammarError {
        return GrammarError(type: .selfReferencedVariable, info: "\("variable".localized())'\(variable)'\("self referenced".localized())")
    }
    
}
