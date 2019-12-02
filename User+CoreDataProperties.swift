//
//  User+CoreDataProperties.swift
//  CoreDatacodable
//
//  Created by Suresh Shiga on 02/12/19.
//  Copyright © 2019 Test. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var message: String?
    @NSManaged public var sha: String?
    @NSManaged public var url: String?

}
