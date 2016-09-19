//
//  MasterViewController.swift
//  RestaurantFinder
//
//  Created by Pasan Premaratne on 5/4/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit

class RestaurantListController: UITableViewController {

    var coordinate: Coordinate?
    
    let foursquareClient = FoursquareClient(clientID: "TDWS3JFM0VPI4C03JFFYY23G5R1LB1J1HZCHLNT2DN1KC4LV", clientSecret: "YXCLSTQGFKGTGPS5I1HKQKR0KBLVFHY2OCLBSF2GPMAJVE24")
    
    let manager = LocationManager()
    
    var venues: [Venue] = []
    {
        didSet
        {
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        manager.getPremission()
        
        manager.onLocationFix = { [weak self] coordinate in
            
            self?.coordinate = coordinate
            self?.foursquareClient.fetchRestaurantsFor(coordinate, category: .Food(nil) ){ result in
                switch result
                {
                case .Success(let venues):
                    self?.venues = venues
                case .Failure(let error):
                    print(error)
                }
                
            }
        }
        
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showDetail"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                let venue = venues[indexPath.row]
                controller.venue = venue
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("RestaurantCell", forIndexPath: indexPath) as! RestaurantCell
        let venue = venues[indexPath.row]
        cell.restaurantTitleLabel.text = venue.name
        cell.restaurantCheckinLabel.text = venue.checkins.description
        cell.restaurantCategoryLabel.text = venue.categoryName
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    @IBAction func refreshRestaurantData(sender: AnyObject)
    {
        
        if let coordinate = coordinate
        {
            foursquareClient.fetchRestaurantsFor(coordinate, category: .Food(nil) ){ result in
                switch result
                {
                case .Success(let venues):
                    self.venues = venues
                case .Failure(let error):
                    print(error)
                }
                
            }
        }
        refreshControl?.endRefreshing()
    }
    

}

