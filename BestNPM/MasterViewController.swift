//
//  MasterViewController.swift
//  BestNPM
//
//  Created by YourtionGuo on 7/29/15.
//  Copyright (c) 2015 Yourtion. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, NpmDataSourceDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = NSArray()
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.delegate = self
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.delegate = self
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table

        self.reloadTable()
        NpmDataSource.sharedInstance.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSearchResult(result: NSArray!, error: NSError!) {
        self.objects = result
        self.reloadTable()
    }
    
    func getSuggestionsResult(result: Array<String>!, error: NSError!) {
        //print(result);
        self.filteredTableData = result
        self.reloadTable()
    }
    
    func getGetNpmPackageResult(result:AnyObject!, error:NSError!){
        print(result);
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as! NSDictionary
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object.description
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
        if (self.resultSearchController.active) {
            print(self.filteredTableData)
            return self.filteredTableData.count
        }
        else {
            return objects.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if (self.resultSearchController.active) {
            let object = filteredTableData[indexPath.row]
            cell.textLabel!.text = object
        }
        else {
            let object = objects[indexPath.row] as! NSDictionary
            cell.textLabel!.text = object.objectForKey("name") as? String
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.resultSearchController.active) {
            let object = filteredTableData[indexPath.row]
            startSearch(object)
        } else {
             self.performSegueWithIdentifier("showDetail", sender: nil)
        }
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        if(filteredTableData.count > 0){
            objects = NSArray()
            filteredTableData.removeAll(keepCapacity: false)
            self.resultSearchController.searchBar.text = ""
            self.reloadTable()
        }
    }

    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        if(searchController.searchBar.text != ""){
            NpmDataSource.sharedInstance.SuggestionsNpm(searchController.searchBar.text)
        }

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.startSearch(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.resultSearchController.active = false
        self.reloadTable()
    }
    
    func startSearch(keywork:String){
        NpmDataSource.sharedInstance.SearcNpm(keywork)
        self.resultSearchController.active = false
        self.resultSearchController.searchBar.text = keywork
        self.reloadTable()
    }
    
    func reloadTable() {
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.reloadData()
        })
    }
}

