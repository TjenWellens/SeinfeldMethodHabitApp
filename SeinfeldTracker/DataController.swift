//
//  DataController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 14/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit
import CoreData

class DataController {
    var managedObjectContext: NSManagedObjectContext
    
    init(applicationDocumentsDirectory: NSURL) {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("SeinfeldTracker", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // 1) Managed Object Model
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        // 2) PersistentStoreCoordinator
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let url = applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }catch {
            fatalError("Error migrating store: \(error)")
        }
        
        // 3) ManagedObjectContext
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
    }
    
    func createFetchedHabitsController(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController {
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Habit", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = delegate
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            abort()
        }
        
        return aFetchedResultsController
    }
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("Error saving context")
            }
        }
    }
}

extension DataController: HabitDataManager {
    func addHabit(habit: Habit) {
        let context = self.managedObjectContext
        
        let habitMO = NSEntityDescription.insertNewObjectForEntityForName("Habit", inManagedObjectContext: context) as! HabitMO
        habitMO.name = habit.name
        habitMO.reminder = habit.reminder
        
        addDatesToHabit(habitMO, dates: habit.succeededDates)
        
        saveContext()
        
        if let startDate = habitMO.reminder {
            habitMO.setLocalNotification(startDate)
        }
    }

    func addDatesToHabit(habitMO: HabitMO, dates: [NSDate]) {
        let context = self.managedObjectContext
        
        for date in dates {
            let dayDate = Month.stripTime(date)
            let succeededDateMO = NSEntityDescription.insertNewObjectForEntityForName("HabitSucceeded",
                inManagedObjectContext: context) as! HabitSucceededMO
            succeededDateMO.date = dayDate
            habitMO.addSucceededDate(succeededDateMO)
        }
    }
    
    func addDateToHabit(habitMO: HabitMO, date: NSDate){
        addDatesToHabit(habitMO, dates: [date])
    }
    
    func removeDateFromHabit(habitMO: HabitMO, date: NSDate) {
        let context = self.managedObjectContext
        if let habitSucceededMO: HabitSucceededMO = habitMO.findDate(date){
            habitMO.removeSucceededDate(habitSucceededMO)
            context.deleteObject(habitSucceededMO)
        }
    }
    
    func toggleDate(habitMO: HabitMO, date: NSDate) {
        if habitMO.containsDate(date) {
            removeDateFromHabit(habitMO, date: date)
        } else {
            addDateToHabit(habitMO, date: date)
        }
        saveContext()
    }

    func deleteHabit(habitMO: HabitMO) {
        habitMO.removeNotification()
        managedObjectContext.deleteObject(habitMO)
        saveContext()
    }
}