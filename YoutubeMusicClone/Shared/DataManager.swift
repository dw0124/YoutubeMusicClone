//
//  DataManager.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/31.
//

import UIKit
import CoreData

class DataManager {
    static let shared = DataManager()
    
    private init() { }
    
    var container: NSPersistentContainer?
    
    var mainContext: NSManagedObjectContext {
        guard let context = container?.viewContext else {
            fatalError()
        }
        
        return context
    }
    
    func setup(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        container?.loadPersistentStores(completionHandler: { (desc, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    func saveMainContext() {
        mainContext.perform {
            if self.mainContext.hasChanges {
                do {
                    try self.mainContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}
