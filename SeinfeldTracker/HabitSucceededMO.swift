//
//  HabitMO.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 14/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit
import CoreData

class HabitSucceededMO: NSManagedObject {
    @NSManaged var date: NSDate
    @NSManaged var habit: HabitMO
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = NSDate()
    }
}