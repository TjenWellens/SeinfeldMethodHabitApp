//
//  MonthDetailViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 13/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class MonthDetailViewController : UICollectionViewController {
    let reuseIdentifier = "DateCell"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var habit: Habit?
    
    func dayNumberForIndexPath(indexPath: NSIndexPath) -> Int {
        return 29;
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DayCell
        cell.backgroundColor = UIColor.yellowColor()
        cell.dayLabel.text = "\(dayNumberForIndexPath(indexPath))"
        return cell
    }
}