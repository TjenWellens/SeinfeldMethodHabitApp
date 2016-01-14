//
//  DataModel.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit
import CoreData
import Foundation

// HABIT

class HabitMO: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var reminder: NSDate?
    @NSManaged var succeededDates: NSSet
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.reminder = nil
    }
    
}

extension HabitMO {
    func addSucceededDate(habitSucceeded:HabitSucceededMO){
        let items = self.mutableSetValueForKey("succeededDates")
        habitSucceeded.habit = self
        items.addObject(habitSucceeded)
    }
    func removeSucceededDate(habitSucceeded:HabitSucceededMO){
        let items = self.mutableSetValueForKey("succeededDates")
        print("HabitMO.removeSucceededDate(\(habitSucceeded))")
        items.removeObject(habitSucceeded)
    }
}

extension HabitMO {
    func containsDate(dayDate: NSDate) -> Bool {
        return succeededDates.contains({return ($0 as! HabitSucceededMO).date == dayDate})
    }
    
    func deleteDate(dayDate: NSDate) -> Bool {
        // todo: optimize
        for item in succeededDates {
            let dateMO = item as! HabitSucceededMO
            if dateMO.date == dayDate{
                removeSucceededDate(dateMO)
                return true
            }
        }
        return false
    }
    
    func findDate(dayDate: NSDate) -> HabitSucceededMO? {
        for item in succeededDates {
            let dateMO = item as! HabitSucceededMO
            if dateMO.date == dayDate{
                return dateMO
            }
        }
        return nil
    }
}

// DATE

class HabitSucceededMO: NSManagedObject {
    @NSManaged var date: NSDate
    @NSManaged var habit: HabitMO
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = NSDate()
    }
}