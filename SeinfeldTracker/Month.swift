//
//  Month.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 14/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import Foundation

class Month {
    static let DAYS_PER_WEEK = 7
    
    // first day of selected month
    var date: NSDate = Month.getFirstDayOfMonth(NSDate())
    let calendar = NSCalendar.currentCalendar()
    
    var offsetFirstDay: Int {
        let weekday = calendar.component(.Weekday, fromDate: date)
        return weekday - 1
    }
    var name: String {
        return Month.getMonthText(date)
    }
    
    var dateName: String {
        return Month.getDateText(date)
    }
    
    func extractDayOfMonth(date: NSDate) -> Int {
        return calendar.component(.Day, fromDate: date)
    }
    
    func dayNumberForIndex(index: Int) -> Int? {
        let index = index + 1 - offsetFirstDay
        guard index > 0 else {
            return nil
        }
        
        let dayDate = Month.getDayOfMonth(index, monthDate: date)
        if let dateUnwrapped = dayDate {
            return calendar.component(.Day, fromDate: dateUnwrapped)
        }
        return nil
    }
    
    static func getDayOfMonth(day: Int, monthDate: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Year], fromDate: monthDate)
        components.day = day
        
        let date = calendar.dateFromComponents(components)!
        
        // check if still same month
        let month = calendar.component(.Month, fromDate: date)
        guard components.month == month else {
            return nil
        }
        return date
    }
    
    static func getFirstDayOfMonth(date: NSDate) -> NSDate{
        return Month.getDayOfMonth(1, monthDate: date)!
    }
    
    static func getMonthText(date: NSDate) -> String {
        let df = NSDateFormatter()
        df.dateFormat = "MMMM"
        return df.stringFromDate(date)
    }
    
    static func getDateText(date: NSDate) -> String {
        let df = NSDateFormatter()
        df.dateFormat = "ddMMyy"
        return df.stringFromDate(date)
    }
    
}

extension Month: NavigateDate {
    
    func navigateDate(direction: NavigateDateDirection) {
        var increment: Int
        
        switch direction {
        case .Future:
            increment = 1
        case .Past:
            increment = -1
        }
        
        let newMonthDate = calendar.dateByAddingUnit(.Month, value: increment, toDate: date, options: NSCalendarOptions())!
        
        self.date = newMonthDate
    }
}
