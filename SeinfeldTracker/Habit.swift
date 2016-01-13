//
//  Habit.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import Foundation
struct Habit {
    let name:String
    let reminder:NSDate?
    let succeededDates: [NSDate]
}