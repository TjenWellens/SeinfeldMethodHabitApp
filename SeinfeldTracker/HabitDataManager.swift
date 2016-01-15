//
//  HabitDataManager.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 14/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import Foundation

protocol HabitDataManager {
    func addHabit(habit: Habit)
    func toggleDate(habitMO: HabitMO, date: NSDate)
    func deleteHabit(habitMO: HabitMO)
}
