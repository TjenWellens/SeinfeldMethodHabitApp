//
//  DetailViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class AddHabitViewController: UIViewController {
    
    @IBOutlet weak var nameTxt: UITextField!

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var habit: Habit?
    
    @IBAction func done() {
        let name = nameTxt.text!
        let reminder = datePicker.date
        habit = Habit(name: name, reminder: reminder)
        performSegueWithIdentifier("didAdd", sender: self)
    }
    
}
