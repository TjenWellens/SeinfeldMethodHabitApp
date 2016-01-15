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

    var habit: HabitMO?
    var dataMgr: HabitDataManager?
    
    let month: Month = Month()
    
    var monthHeader: MonthHeaderReusableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _updateTitle()
    }
    
    func _updateTitle(){
        if let habit = habit {
            habit.updateStreak()
            self.title = "\(habit.name) (\(habit.streak ?? 0))"
        }
    }
    
    func _dayNumberForIndexPath(indexPath: NSIndexPath, nilNotInMonth: Bool = true) -> Int? {
        return month.dayNumberForIndex(indexPath.row, nilNotInMonth: nilNotInMonth)
    }

    // sections
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections
    }

    // itemsPerSection
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeks * Month.DAYS_PER_WEEK  // weeks
    }

    // Cell.create
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! DayCell
        if let day = _dayNumberForIndexPath(indexPath) {
            cell.dayLabel.text = "\(day)"
        }else {
            cell.dayLabel.text = ""
        }
        return cell
    }

    // Cell.willDisplay()
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        var fill = UIColor.lightGrayColor().CGColor
        var border = UIColor.lightGrayColor().CGColor
        
        let dayNr = _dayNumberForIndexPath(indexPath)
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

    // Header.create()
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            monthHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseMonthHeaderIdentifier, forIndexPath: indexPath) as! MonthHeaderReusableView
            monthHeader.callback = self
            monthHeader.monthLabel.text = month.name
            return monthHeader
        default:
            fatalError("Unknown viewtype in \(self.dynamicType).")
        }
    }

    // Click
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let habit = habit, let dataMgr = dataMgr else {
            return
        }
        guard let dayNr = _dayNumberForIndexPath(indexPath) else {
            return
        }
        
        let date = month.dateForDayNr(dayNr)
        dataMgr.toggleDate(habit, date: date)
        self.collectionView!.reloadItemsAtIndexPaths([indexPath])
        _updateTitle()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let side: CGFloat = min(collectionView.frame.size.width, collectionView.frame.size.height) / CGFloat(Month.DAYS_PER_WEEK + 1)
        return CGSize(width: side, height: side)
    }
}

// Navigate to next or previous month
extension MonthDetailViewController: NavigateDate {
    func navigateDate(direction: NavigateDateDirection) {
        month.navigateDate(direction)
        updateMonthGUI()
    }

    func updateMonthGUI(){
        if let monthHeader = self.monthHeader {
            monthHeader.monthLabel.text = month.name
        }
        self.collectionView!.reloadData()
    }
}