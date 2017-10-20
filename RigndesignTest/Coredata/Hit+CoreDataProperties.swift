//
//  Hit+CoreDataProperties.swift
//  RigndesignTest
//
//  Created by Matías Contreras Selman on 20-10-17.
//  Copyright © 2017 Station Domain. All rights reserved.
//
//

import Foundation
import CoreData


extension Hit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hit> {
        return NSFetchRequest<Hit>(entityName: "Hit")
    }

    @NSManaged public var author: String?
    @NSManaged public var comment_text: String?
    @NSManaged public var created_at: NSDate?
    @NSManaged public var created_at_i: Int32
    @NSManaged public var num_comments: Int16
    @NSManaged public var objectId: Int32
    @NSManaged public var parent_id: Int32
    @NSManaged public var points: Int16
    @NSManaged public var story_id: Int16
    @NSManaged public var story_text: String?
    @NSManaged public var story_title: String?
    @NSManaged public var story_url: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var active: Bool

}
