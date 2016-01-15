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
}

// Relation: succeededDates

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

// Utility methods

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

// Notification

extension HabitMO {
    func setLocalNotification(startDate: NSDate) {
        let notification: UILocalNotification = UILocalNotification()
        let calendar = NSCalendar.currentCalendar()

        // text
        notification.alertTitle = self.name
        notification.alertBody = "Don't break the chain!"

        // date stuff
        notification.fireDate = startDate
        notification.timeZone = calendar.timeZone
        notification.repeatInterval = .Day

        /* Action settings */
        notification.hasAction = true
        notification.alertAction = nil // defaults to localized("View") because alertBody
        // .category -> for more actions like complete in notification instead of view

        // need id for removal of notifications
        notification.userInfo = [
                "HabitMO.name" : self.name
        ]
        
        // extra stuff
        notification.soundName = UILocalNotificationDefaultSoundName

        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func removeNotification() {
        let app = UIApplication.sharedApplication()
        
        guard let notifications = app.scheduledLocalNotifications else { return }
        
        // delete notifications with name in userInfo
        for notification in notifications {
            guard let userInfo = notification.userInfo else { continue }
            guard let nameObj = userInfo["HabitMO.name"] else { continue }
            guard let name = nameObj as? String else { continue }
            
            if self.name == name {
                app.cancelLocalNotification(notification)
            }
        }
    }
}