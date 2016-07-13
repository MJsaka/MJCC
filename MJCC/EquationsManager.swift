//
//  EquationsManager.swift
//  MJCC
//
//  Created by MJsaka on 16/6/30.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit
import CoreData

public let EquationsCountChanged = "EquationsCountChanged"

class Equation: NSManagedObject {
    @NSManaged var name : String
    @NSManaged var expr : String
}


class EquationsManager: NSObject {

    class func equations() -> [Equation]{
        let request = NSFetchRequest(entityName: "Equation")
        request.sortDescriptors = Array(arrayLiteral: NSSortDescriptor(key : "name" , ascending : true))
        
        var results = [Equation]()
        do {
            try results += managedObjectContext.executeFetchRequest(request) as! [Equation]
        }catch{
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return results
    }
    
    class func insertEquation(name name : String , expr : String) -> Equation{
        //Get the ManagedObject
        let equation = NSEntityDescription.insertNewObjectForEntityForName("Equation", inManagedObjectContext: managedObjectContext) as! Equation
        //Set the ManagedObject Value for key
        equation.name = name
        equation.expr = expr
        saveContext()
        NSNotificationCenter.defaultCenter().postNotificationName(EquationsCountChanged, object: nil)
        return equation
    }
    
    class func deleteEquation(equation : Equation){
        managedObjectContext.deleteObject(equation)
        NSNotificationCenter.defaultCenter().postNotificationName(EquationsCountChanged, object: nil)
    }
    
    
    // MARK: - Core Data stack
    
    static var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mjsaka.MJCC" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    static var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("MJCC", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.URLByAppendingPathComponent("equations.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "PersistentStoreCoordinator", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    static var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}


