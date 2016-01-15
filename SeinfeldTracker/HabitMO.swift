//
//  DataModel.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit
import CoreData

class HabitMO: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var reminder: NSDate?
    @NSManaged var streak: NSNumber?
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
        items.removeObject(habitSucceeded)
    }
}

extension HabitMO {
    func containsDate(dayDate: NSDate) -> Bool {
        return succeededDates.contains({return ($0 as! HabitSucceededMO).date == dayDate})
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
    
    func updateStreak() {
        let newStreak = _calculateStreak()
        if let nsStreak = self.streak {
            print("updateStreak(old: \(nsStreak.integerValue), new: \(newStreak))")
            if nsStreak.integerValue == newStreak {
                return
            }
        }
        print("updateStreak(\(newStreak))")
        self.streak = NSNumber(integer: newStreak)
    }
    
    func _calculateStreak() -> Int {
        let today = Month.stripTime(NSDate())
        let yesterday = Month.previousDay(today)
        var counter = 0
        
        if self.containsDate(today) {
            counter = 1
        }
        
        var date = yesterday
        while self.containsDate(date) {
            counter += 1
            date = Month.previousDay(date)
        }
        
        return counter
    }
}