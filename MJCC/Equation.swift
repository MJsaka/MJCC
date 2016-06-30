//
//  Equation.swift
//  MJCC
//
//  Created by MJsaka on 16/6/30.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import CoreData

class Equation: NSManagedObject {
    @NSManaged var name : String
    @NSManaged var expr : String
}
