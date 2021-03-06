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
    var suggestionTimer:NSTimer!


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
        self.navigationItem.title = "BestNPM"
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers.last as? DetailViewController
        }
        
        if #available(iOS 9.0, *) {
            self.resultSearchController.loadViewIfNeeded() // iOS 9
        } else {
            // Fallback on earlier versions
            let _ = self.resultSearchController.view // iOS 8
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
    
    // MARK: - NpmDataSourceDelegate
    
    func getSearchResult(result: NSArray!, error: NSError!) {
        dispatch_async(dispatch_get_main_queue(),{
            self.clearAllNotice()
        })
        if (result != nil) {
            self.objects = result
            self.reloadTable()
        } 
    }
    
    func getSuggestionsResult(result: Array<String>!, error: NSError!) {
        //print(result);
        if (result != nil) {
            self.filteredTableData = result
            self.reloadTable()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDictionary
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.name = object.objectForKey("name") as? String
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.resultSearchController.active) {
            return 44
        }
        else {
            return 90
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            print(self.filteredTableData, terminator: "")
            return self.filteredTableData.count
        }
        else {
            return objects.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.resultSearchController.active) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) 
            let object = filteredTableData[indexPath.row]
            cell.textLabel!.text = object
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NPMCell", forIndexPath: indexPath) as! NPMCell
            let object = objects[indexPath.row] as! NSDictionary
            cell.name!.text = object.objectForKey("name") as? String
            cell.detail!.text = object.objectForKey("description") as? String
            cell.infos!.text = object.objectForKey("modified") as? String
            return cell
        }
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
    
    func reloadTable() {
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.reloadData()
        })
    }

    // MARK: - SearchBar
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        if (suggestionTimer != nil) {
            suggestionTimer.invalidate()
        }
        let keyword = searchController.searchBar.text!
        if(keyword != ""){
            suggestionTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector:"getSuggestions:", userInfo:keyword, repeats: false)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.pleaseWait()
        self.startSearch(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NpmDataSource.sharedInstance.cancleAllRequest()
        self.resultSearchController.active = false
        self.reloadTable()
    }
    
    func getSuggestions(timer: NSTimer!){
        let keyword = timer.userInfo as! String
        NpmDataSource.sharedInstance.SuggestionsNpm(keyword)
    }
    
    func startSearch(keyword:String){
        NpmDataSource.sharedInstance.SearchNpm(keyword)
        self.resultSearchController.active = false
        self.resultSearchController.searchBar.text = keyword
        self.reloadTable()
    }
    
}

