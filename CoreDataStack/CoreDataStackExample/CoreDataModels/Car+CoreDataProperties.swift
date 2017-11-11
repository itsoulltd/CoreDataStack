//
//  Car+CoreDataProperties.swift
//  CoreDataStackExample
//
//  Created by Towhid Islam on 11/11/17.
//  Copyright © 2017 Towhid Islam. All rights reserved.
//
//

import Foundation
import CoreData

extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var driverInfo: DriverInfo?
    @NSManaged public var lincenceNo: NSString?
    @NSManaged public var wheels: NSNumber?

}
