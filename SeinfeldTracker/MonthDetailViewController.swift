//
//  MonthDetailViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 13/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class MonthDetailViewController : UICollectionViewController {
    let sections = 1
    let weeks = 6
    let reuseCellIdentifier = "DateCell"
    let reuseMonthHeaderIdentifier = "MonthHeader"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var habit: HabitMO?
    var dataMgr: DataManager?
    
    let month: Month = Month()
    
    var monthHeader: MonthHeaderReusableView!
    
    func dayNumberForIndexPath(indexPath: NSIndexPath, nilNotInMonth: Bool = true) -> Int? {
        return month.dayNumberForIndex(indexPath.row, nilNotInMonth: nilNotInMonth)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeks * Month.DAYS_PER_WEEK  // weeks
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! DayCell
        if let day = dayNumberForIndexPath(indexPath) {
            cell.dayLabel.text = "\(day)"
        }else {
            cell.dayLabel.text = ""
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        var fill = UIColor.lightGrayColor().CGColor
        var border = UIColor.lightGrayColor().CGColor
        
        let dayNr = dayNumberForIndexPath(indexPath)
        if let dayNr = dayNr {
            let dayDate: NSDate = month.dateForDayNr(dayNr)
            if habit!.containsDate(dayDate) {
                fill = UIColor.greenColor().CGColor
                border = UIColor.darkGrayColor().CGColor
            }
        }
        
        let cell = cell as! DayCell
        cell.dayLabel.layer.cornerRadius = cell.dayLabel.bounds.width / CGFloat(2 + 1)
        cell.dayLabel.layer.borderWidth = 3
        cell.dayLabel.layer.backgroundColor = fill
        cell.dayLabel.layer.borderColor = border
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            monthHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseMonthHeaderIdentifier, forIndexPath: indexPath) as! MonthHeaderReusableView
            monthHeader.callback = self
            monthHeader.monthLabel.text = month.name +
            ", \(month.dateName)"
            return monthHeader
        default:
            fatalError("Unknown viewtype in \(self.dynamicType).")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let habit = habit, let dataMgr = dataMgr else {
            return
        }
        guard let dayNr = dayNumberForIndexPath(indexPath) else {
            return
        }
        
        let date = month.dateForDayNr(dayNr)
        dataMgr.toggleDate(habit, date: date)
        self.collectionView!.reloadItemsAtIndexPaths([indexPath])
    }
    
    func updateMonthGUI(){
        if let monthHeader = self.monthHeader {
            monthHeader.monthLabel.text = month.name
        }
        self.collectionView!.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let side: CGFloat = min(collectionView.frame.size.width, collectionView.frame.size.height) / CGFloat(Month.DAYS_PER_WEEK + 1)
        return CGSize(width: side, height: side)
    }
}

extension MonthDetailViewController: NavigateDate {
    
    func navigateDate(direction: NavigateDateDirection) {
        month.navigateDate(direction)
        updateMonthGUI()
    }
}