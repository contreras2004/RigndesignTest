//
//  CoredataHelper.swift
//  RigndesignTest
//
//  Created by Matías Contreras Selman on 20-10-17.
//  Copyright © 2017 Station Domain. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreData
import SVProgressHUD

class CoreDataHelper: NSObject {
    static let shared = CoreDataHelper()

    let delegate = UIApplication.shared.delegate as! AppDelegate
    let queryUrl = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
    var context:NSManagedObjectContext
    
    override init() {
        self.context = delegate.persistentContainer.viewContext
    }
    
    func getHits(){
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 3
        
        manager.request(self.queryUrl, method: .get).responseJSON { response in
            print(response.result)
            switch (response.result) {
            case .success(let value):
                let json = JSON(value)
                
                //assuming there will be no changes on the data structure of the JSON
                if json["hits"].exists(){
                    self.createHit(json: json["hits"])
                }
                else{
                    print("Data structure on the server has changed.")
                }
                break
            case .failure:
                print("Could not get data from server")
                SVProgressHUD.showError(withStatus: "Sorry, there was an error loading the data from the server.")
                self.saveContext()
                break
            }
        }
    }
    
    func createHit(json: JSON){
        for (_,subJson):(String, JSON) in json {
            
            //check first if the ID of the fetched object is already in the database
            let predicate = String(format: "objectId = %i", subJson["objectID"].int32Value)
            let storedHit = self.fetchObjectsWithPredicate(object: "Hit", predicate: predicate)
            if storedHit?.count == 0{
                if let object = NSEntityDescription.insertNewObject(forEntityName: "Hit", into: self.context) as? Hit {
                    //set the new object properties
                    object.title = subJson["title"].stringValue
                    object.url = subJson["url"].stringValue
                    object.author = subJson["author"].stringValue
                    object.points = subJson["points"].int16Value
                    object.story_text = subJson["story_text"].stringValue
                    object.comment_text = subJson["comment_text"].stringValue
                    object.num_comments = subJson["num_comments"].int16Value
                    object.story_id = subJson["story_id"].int16Value
                    object.story_title = subJson["story_title"].stringValue
                    object.story_url = subJson["story_url"].stringValue
                    object.parent_id = subJson["parent_id"].int32Value
                    object.created_at_i = subJson["created_at_i"].int32Value
                    object.objectId = subJson["objectID"].int32Value
                    object.active = true
                }
            }
        }
        self.saveContext()
    }
    
    func saveContext() -> Void {
        do {
            try self.context.save()
        } catch let error {
            print(error)
        }
    }
    
    func fetchObjectsWithPredicate(object: String, predicate: String)->[Any]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: object)
        let predicate = NSPredicate(format: predicate)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "created_at_i", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try self.context.fetch(fetchRequest)
            return results
            
        } catch let error as NSError {
            print("Error: \(error)")
        }
        return nil
    }
}
