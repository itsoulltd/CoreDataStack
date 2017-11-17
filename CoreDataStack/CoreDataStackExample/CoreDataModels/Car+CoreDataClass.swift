//
//  Car+CoreDataClass.swift
//  CoreDataStackExample
//
//  Created by Towhid Islam on 11/11/17.
//  Copyright © 2017 Towhid Islam. All rights reserved.
//
//

import Foundation
import CoreData
import CoreDataStack

@objc(Car)
public class Car: NGCoreObject {

    public class func exist(byGuid guid: String) -> Bool{
        let obj = Car.read(["guid":guid], context: NGKeyedContext.sharedInstance().context(forKey: "Model"))
        return obj != nil
    }
}
