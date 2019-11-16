//
//  Folder+CoreDataClass.swift
//  task5
//
//  Created by Stanislav on 16.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

public class Folder: NSManagedObject {
    lazy var isRootFolder = false
    
    var getSubFolders : [Folder]{
        var subFolders = [Folder]()
        for f in self.subFolders!{
                subFolders.append(f as! Folder)
        }
        return subFolders
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity =  NSEntityDescription.entity (forEntityName: "Folder",
                                                  in: managedContext)
        
        super.init(entity: entity!, insertInto: managedContext)
    }
    
    static func getRootFolder() -> Folder {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = Folder.createfetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            let foldersList = try managedContext.fetch(request)
            if foldersList.isEmpty {
                let newFolder = Folder()
                newFolder.name = "Root Folder"
                newFolder.isRootFolder = true
                return newFolder
            }
            for f in foldersList {
                if f.owner == nil { return f }
            }
        } catch {
            print("Failed")
        }
        let newFolder = Folder()
        newFolder.name = "Root Folder"
        newFolder.isRootFolder = true
        return newFolder
    }
    
    func clone() -> Folder{
        let newFolder = Folder()
        newFolder.name = name
        getClone(fromFolder: self, intoFolder: newFolder)
        return newFolder
    }
    
    func getClone(fromFolder: Folder, intoFolder: Folder) {
        if fromFolder.subFolders!.count == 0 {
            return
        }
        for f in fromFolder.getSubFolders {
            let folderCopy = Folder()
            folderCopy.name = f.name
            folderCopy.owner = intoFolder
            getClone(fromFolder: f, intoFolder: folderCopy)
        }
    }
    
    func getTotalSubFoldersCount() -> Int {
        return totalSubFoldersCount(folder: self)
    }
    
    fileprivate func totalSubFoldersCount(folder : Folder) -> Int {
        var count = 0
        for f in folder.getSubFolders {
            count += 1 + totalSubFoldersCount(folder: f)
        }
        return count
    }
    
    func delete() {
        managedObjectContext?.delete(self)
        reloadData()
    }
    
    func rename(name: String) {
        self.name = name
        reloadData()
    }
    
    func addChild(folder: Folder) {
        self.addToSubFolders(folder)
        reloadData()
    }
    
    func isHasSubFolderWithName(name: String) -> Bool {
        for f in getSubFolders {
            if f.name == name {
                return true
            }
        }
        return false
    }
    
    func reloadData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }
    
    func isHasPerent(folder: Folder) -> Bool{
        if self == folder { return true }
        var currentFolder = self
        while currentFolder.owner != nil {
            if currentFolder.owner == folder {
                return true
            }
            currentFolder =  currentFolder.owner!
        }
        return false
    }
}
