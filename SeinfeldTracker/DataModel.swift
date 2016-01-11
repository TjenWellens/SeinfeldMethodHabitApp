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

class HabitMO: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var reminder: NSDate?
    @NSManaged var succeededDates: NSSet
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.reminder = nil
    }
    
}

class HabitSucceededMO: NSManagedObject{
    @NSManaged var date: NSDate?
    @NSManaged var habit: HabitMO
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = NSDate()
    }
}

extension HabitMO {
    func addSucceededDate(date:NSDate){
        let items = self.mutableSetValueForKey("succeededDates")
        items.addObject(date)
    }
    func removeSucceededDate(date:NSDate){
        let items = self.mutableSetValueForKey("succeededDates")
        items.removeObject(date)
    }
}