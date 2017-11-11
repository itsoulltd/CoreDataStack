//
//  NGCoreObject+Extension.swift
//  CoreDataStackExample
//
//  Created by Towhid Islam on 11/11/17.
//  Copyright © 2017 Towhid Islam. All rights reserved.
//

import Foundation
import CoreDataStack

extension NGObjectProtocol{ //Search
    
    func matchAnyStringProperty(_ search: String) -> Bool{
        let source = serializeIntoInfo()
        var match = false
        for (key, value) in source! {
            if ((value is NSNull) == false && (value is String)){
                let comp = (source?[key] as! String).lowercased()
                match = comp.contains(search.lowercased())
                if match {
                    break
                }
            }
        }
        return match
    }
    
}

extension NGObjectProtocol{ //GroupBy
    
    static func groupBy<T: NGObject>(_ key: String, onCollection source: [T]) -> NSDictionary?{
        //Checking NGObject, NSArray or NSDictionary or NSSet
        if let firstValue = source.first?.value(forKey: key), firstValue is T || firstValue is NSArray || firstValue is NSDictionary || firstValue is NSSet {
            print("NGObject or NSArray or NSDictionary or NSSet NOT Supported as Group Value Type");
            return nil
        }
        //
        let result = NSMutableDictionary()
        let sortCommend = AlphabeticalSort()
        let sorted = sortCommend.sort(source, forKeyPath: key) as! [T]
        //Algo Goes ON
        var runningItem: T? = sorted.first
        if let value = runningItem?.value(forKeyPath: key) as? NSCopying{
            result.setObject(NSMutableArray(), forKey: value)
        }
        //
        for nextItem in sorted {
            let nextValue = nextItem.value(forKeyPath: key) as! NSCopying
            if let runningValue = runningItem?.value(forKeyPath: key) as? NSCopying {
                if NGCoreObject.hasSameValue(runningValue, b: nextValue) == false {
                    result.setObject(NSMutableArray(), forKey: nextValue)
                    runningItem = nextItem
                }
            }
            let mutable = result[nextValue] as! NSMutableArray
            mutable.add(nextItem)
        }
        return result
    }
    
    fileprivate static func hasSameValue(_ a: NSCopying, b: NSCopying) -> Bool{
        if (a is NSString && b is NSString) {
            return (a as! NSString) == (b as! NSString)
        }else if (a is NSNumber && b is NSNumber){
            return (a as! NSNumber).stringValue == (b as! NSNumber).stringValue
        }else if (a is NSValue && b is NSValue){
            return (a as! NSValue) == (b as! NSValue)
        }
        return false
    }
    
}
