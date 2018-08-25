//
//  CoredataManager.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 18/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit
import CoreData

class CoredataManager: NSObject {
    
    static let shared = CoredataManager()
    
    func saveNewPaper(named name:String, code:String, exam:String, url:String) {
        let counterEntity = NSEntityDescription.entity(forEntityName: "Paper", in: MANAGED_CONTEXT)
        let counter = NSManagedObject(entity: counterEntity!, insertInto: MANAGED_CONTEXT)
        counter.setValue(name, forKey: "displayName")
        counter.setValue("\(name).pdf", forKey: "fileName")
        counter.setValue(code, forKey: "code")
        counter.setValue(url, forKey: "url")
        counter.setValue(exam, forKey: "exam")
        counter.setValue(false, forKey: "isOpened")
        
        do {
            try MANAGED_CONTEXT.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getAllPapers() -> [Paper] {
        let fetchRequest: NSFetchRequest<Paper> = Paper.fetchRequest()
        var papers = [Paper]()
        do {
            let results = try MANAGED_CONTEXT.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            papers = results as! [Paper]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return papers
    }

}
