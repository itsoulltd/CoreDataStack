//
//  CoreDataStackTests.swift
//  CoreDataStackTests
//
//  Created by Towhid Islam on 11/11/17.
//  Copyright © 2017 Towhid Islam. All rights reserved.
//

import XCTest
import CoreDataStack

class CoreDataStackTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testStudents(){
        var studets = Student.getAllStudents()
        print("Studets : \(studets.count)")
        Student.add(["name":"James", "age": 18])
        studets = Student.getAllStudents()
        print("Studets : \(studets.count)")
        
        let student = studets.first { (student) -> Bool in
            return student.name == "James"
        }
        if let james = student {
            print(james.serializeIntoInfo())
            //
            james.update(withInfo: ["name":"James", "address": "38, West Verginiya"])
            james.mobileNumbers = ["01711776633","01852009900"]
            //
            print(james.serializeIntoInfo())
        }
    }
    
    func testCar(){
        //DriveInfo is a subclass of KGObject which we want to store in coredata
        let driverInfo = DriverInfo()
        //properties we want to store
        driverInfo.strDriverName = "Sarah"
        driverInfo.iDriverAge = 25
        driverInfo.flDiverHeight = 159
        driverInfo.rcBodySize = CGSize(width: 50, height: 159)
        driverInfo.hairColor = UIColor.black
        
        //get shared Instance of managed object context
        let context = NGCoreDataContext.sharedInstance().defaultContext()
        
        // Car is a subclass of KGCoreObject which is subclass of NSMangedObject
        // insert car into shared managed object context
        if let car = Car.insert(into: context, withProperties: nil){
            car.guid = UUID().uuidString //set a unique identifier
            car.wheels = 4
            car.color = UIColor.blue
            car.driverInfo = driverInfo;
            car.lincenceNo = "1212";
        }
        
        //save managed object context into a sqlite storage
        do {
            try context?.save()
            print("saved")
            if Car.rows(context) > 0 {
                if let cars = Car.read(nil, context: context) as? [Car]{
                    for car in cars{
                        print(car.serializeIntoInfo())
                    }
                }
            }
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
}
