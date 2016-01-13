//
//  MonthDetailViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 13/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class MonthDetailViewController : UICollectionViewController {
    let DAYS_PER_WEEK = 7
    let sections = 1
    let weeks = 6
    let reuseCellIdentifier = "DateCell"
    let reuseMonthHeaderIdentifier = "MonthHeader"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var habit: Habit?
    var currentMonth: NSDate = NSDate()
    var offsetForMonth: Int {
        // todo: calc
        return 3
    }
    var monthHeader: MonthHeaderReusableView!
    
//    func foo(){
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
//        
//        let year =  components.year
//        let month = components.month
//        let day = components.day
//        
//        print(year)
//        print(month)
//        print(day)
//    }
    
    func extractDayOfMonth(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        return calendar.component(.Day, fromDate: date)
    }

//    func foo2(){
//        
//        let calendar = NSCalendar.currentCalendar()
//        let date = NSDate()
//        let components = calendar.components([.NSMonthCalendarUnit], fromDate: date)
//        components.day = 1
//        let firstDateOfMonth: NSDate = calendar.dateFromComponents(components)!
//        
//        components.month  += 1
//        components.day     = 0
//        let lastDateOfMonth: NSDate = calendar.dateFromComponents(components)!
//
//        let day = calendar.component(.Day, fromDate: date)
//        
//
//    }
    
    func dayNumberForIndexPath(indexPath: NSIndexPath) -> Int? {
        let index = indexPath.row + 1 - offsetForMonth
        guard index > 0 else {
            return nil
        }
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.NSMonthCalendarUnit], fromDate: currentMonth)
        let month = components.month
        components.day = index
        let date = calendar.dateFromComponents(components)!
        let checkMonth = calendar.component(.Month, fromDate: date)
        
        guard checkMonth == month else {
            return nil
        }
        return calendar.component(.Day, fromDate: date)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeks * DAYS_PER_WEEK  // weeks
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! DayCell
        cell.dayLabel.backgroundColor = UIColor.redColor()
        if let day = dayNumberForIndexPath(indexPath) {
            cell.dayLabel.text = "\(day)"
        }else {
            cell.dayLabel.text = "."
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            monthHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseMonthHeaderIdentifier, forIndexPath: indexPath) as! MonthHeaderReusableView
            monthHeader.callback = self
            updateMonth(self.currentMonth)
            return monthHeader
        default:
            fatalError("Unknown viewtype in \(self.dynamicType).")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func updateMonth(date: NSDate){
        self.currentMonth = date
        if let monthHeader = self.monthHeader {
            monthHeader.monthLabel.text = getMonthText(date)
        }
    }
    
    func getMonthText(date: NSDate) -> String {
        let df = NSDateFormatter()
        df.dateFormat = "MMMM"
        return df.stringFromDate(date)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let side: CGFloat = collectionView.frame.size.width / CGFloat(DAYS_PER_WEEK + 1)
        return CGSize(width: side, height: side)
    }
}

extension MonthDetailViewController: NavigateDate {
    
    func navigateDate(direction: DateDirection) {
        let calendar = NSCalendar.currentCalendar()
        var increment: Int
        
        switch direction {
        case .Future:
            increment = 1
        case .Past:
            increment = -1
        }
        
        let newMonth = calendar.dateByAddingUnit(.Month, value: increment, toDate: self.currentMonth, options: NSCalendarOptions())!
        updateMonth(newMonth)
    }
}