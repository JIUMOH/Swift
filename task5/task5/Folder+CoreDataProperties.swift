//
//  Folder+CoreDataProperties.swift
//  task5
//
//  Created by Stanislav on 16.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func createfetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var name: String?
    @NSManaged public var owner: Folder?
    @NSManaged public var subFolders: NSSet?

}

// MARK: Generated accessors for subFolders
extension Folder {

    @objc(addSubFoldersObject:)
    @NSManaged public func addToSubFolders(_ value: Folder)

    @objc(removeSubFoldersObject:)
    @NSManaged public func removeFromSubFolders(_ value: Folder)

    @objc(addSubFolders:)
    @NSManaged public func addToSubFolders(_ values: NSSet)

    @objc(removeSubFolders:)
    @NSManaged public func removeFromSubFolders(_ values: NSSet)

}
