//
//  DetailViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    
    var habit: Habit? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let habit = self.habit else { return }
        guard let nameLabel = self.nameLabel else { return }
        
        nameLabel.text = habit.name
        
        let df = NSDateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        let dateTexts: [String] = habit.succeededDates.map({df.stringFromDate($0)})
        datesLabel.text = dateTexts.joinWithSeparator(", ")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

