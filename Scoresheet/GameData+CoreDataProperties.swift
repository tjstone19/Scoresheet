//
//  GameData+CoreDataProperties.swift
//  Scoresheet
//
//  Created by Trevor J. Stone on 7/28/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GameData {

    @NSManaged var clubName: String?
    @NSManaged var gameId: String?
    @NSManaged var teamDivision: String?
    @NSManaged var userName: String?

}
