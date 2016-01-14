//
//  // Source: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1
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
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//            let docURL = urls[urls.endIndex-1]
//            /* The directory the application uses to store the Core Data store file.
//            This code uses a file named "DataModel.sqlite" in the application's documents directory.
//            */
//            let storeURL = docURL.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
//            do {
//                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
//            } catch {
//                fatalError("Error migrating store: \(error)")
//            }
//        }
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
        // TODO
        aFetchedResultsController.delegate = delegate
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            abort()
        }
        
        return aFetchedResultsController
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

protocol DataManager {
    func addHabit(habit: Habit)
    func toggleDate(habitMO: HabitMO, date: NSDate)
}

extension DataController: DataManager {
    func addHabit(habit: Habit) {
        let context = self.managedObjectContext
        
        let habitMO = NSEntityDescription.insertNewObjectForEntityForName("Habit", inManagedObjectContext: context) as! HabitMO
        habitMO.name = habit.name
        habitMO.reminder = habit.reminder
        
        addDatesToHabit(habitMO, dates: habit.succeededDates)
        
        saveContext()
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
            context.deleteObject(habitSucceededMO)
            habitMO.removeSucceededDate(habitSucceededMO)
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
}