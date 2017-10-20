//
//  HistsTableViewController.swift
//  RigndesignTest
//
//  Created by Matías Contreras Selman on 20-10-17.
//  Copyright © 2017 Station Domain. All rights reserved.
//

import UIKit

class HitsTableViewController: UITableViewController {

    var hits:[Hit]!
    var selectedRow:Int!
    let cellReuseIdentifier = "customCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load hits from local database
        self.fetchHits()
        self.clearsSelectionOnViewWillAppear = true
        
        /*REFRESHCONTROLL*/
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString()
        
        /*we need to subscribe for notifications to know when the database was updated*/
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func refresh(sender:AnyObject) {
        print("REFRESH")
        CoreDataHelper.shared.getHits()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.hits.count
    }

    @objc func contextDidSave(_ notification: Notification) {
        
        //reload data after animation
        self.fetchHits()
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.tableView.reloadData()
            //in case this was called by the pullToRefresh
            self.refreshControl?.endRefreshing()
        }
    }
    
    func fetchHits() {
        let predicate = String(format: "active = %i", 1)
        self.hits  = CoreDataHelper.shared.fetchObjectsWithPredicate(object: "Hit", predicate: predicate) as! [Hit]
        print("Number of Hits: \(hits.count)")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CustomTableViewCell
        
        //I notice some hits with no title, dont know if this is an error... will have to check with the REST service provider
        let hit = hits[indexPath.row]
        cell.lblTitle.text = self.getHitTitle(hit: hit)
        
        let hit_date = Date.init(timeIntervalSince1970: Double(hit.created_at_i))
        cell.lblSubtitle.text = String(format: "%@ - %@", hit.author!, timeAgoSince(hit_date))
        //cell.lblSubtitle.text = timeAgoSinceDate(date: hit_date, numericDates: true)// calculateTimeAgo(timestamp: "123456")
        // Configure the cell...

        return cell
    }
    
    func getHitTitle(hit: Hit)->String{
        if (hit.story_title != nil && hit.story_title != ""){
            return hit.story_title!
        }
        else if (hit.title != nil && hit.title != ""){
            return hit.title!
        }
        return "No Title"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.hits[indexPath.row].active = false
            //CoreDataHelper.shared.saveContext()
            self.hits?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.performSegue(withIdentifier: "goUrl", sender: self)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goUrl"{
            let destination = segue.destination as! WebViewController
            destination.navTitle = getHitTitle(hit: self.hits[self.selectedRow])
            destination.address = self.hits[self.selectedRow].story_url
        }
    }

}
