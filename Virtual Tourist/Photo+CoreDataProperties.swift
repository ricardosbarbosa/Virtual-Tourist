//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Ricardo Barbosa on 15/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var image: Data?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
