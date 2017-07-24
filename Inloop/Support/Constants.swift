//
//  Constants.swift
//  Inloop
//
//  Created by Roland Beke on 21.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

enum Constants {

    private static let api = "https://inloop-contacts.appspot.com/_ah/api/"
    
    static let ordersUrl = api + "contactendpoint/v1/contact"
    static let detailUrl = api + "orderendpoint/v1/order/"
    static let addUrl = api + "contactendpoint/v1/contact"
    
    static let mailDomain = "@somewhere.com"
}


/*
 self.dataStack?.performInNewBackgroundContext { context in
 
 for jsonItem in items {
 
 guard let entity = NSEntityDescription.entity(forEntityName: "CDItem", in: context) else { return }
 
 let item = NSManagedObject(entity: entity, insertInto: context)
 item.setValue(jsonItem["name"], forKey: "name")
 item.setValue(jsonItem["count"], forKey: "count")
 
 guard let id = jsonItem["id"] as? [String : Any], let int = id["id"] as? String else { return }
 item.setValue(NSNumber(value: Int(int)!), forKey: "id")
 guard let userId = self.userId,
 let user = try? context.fetch(userId, inEntityNamed: "CDUser")
 else { return }
 
 item.setValue(user, forKey: "user")
 }
 
 try? context.save()
 
 print("item saved")
 }
 
 var newItems: [[String: Any]] = []
 
 for var item in items {
 let idDict = item["id"] as? [String: Any]
 item["id"] = idDict?["id"]
 newItems.append(item)
 //item.removeValue(forKey: "id")
 //item.set(value: idDict["id"], forKey: "id")
 //idDict["id"]
 }
 
 self.dataStack?.performInNewBackgroundContext { context in
 
 
 
 let safeParent = try! context.fetch(self.userId!, inEntityNamed: "CDUser")
 guard let entity = NSEntityDescription.entity(forEntityName: "CDItem", in: context) else { fatalError("Couldn't find entity named: CDItem") }
 let relationships = entity.relationships(forDestination: safeParent!.entity)
 var predicate: NSPredicate?
 let firstRelationship = relationships.first
 
 if let firstRelationship = firstRelationship {
 predicate = NSPredicate(format: "%K = %@", firstRelationship.name, safeParent!)
 }
 
 context.changes(newItems, inEntityNamed: "CDItem", predicate: nil, parent: safeParent, parentRelationship: firstRelationship?.inverseRelationship, operations: .all, completion: { error in
 
 
 print("sync error: \(String(describing: error))")
 })
 }
 
 NotificationCenter.default.addObserver(self, selector: #selector(self.changeNotification), name: .NSManagedObjectContextObjectsDidChange, object: self.dataStack!.mainContext)

 
 func changeNotification(notification: NSNotification) {
 let deletedObjects = notification.userInfo?[NSDeletedObjectsKey]
 let insertedObjects = notification.userInfo?[NSInsertedObjectsKey]
 print("updated")
 }
 */
