//
//  ViewController.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    //None searchbar controllers array
    var species:Array<StarWarsSpecies>?
    var speciesWrapper:SpeciesWrapper? // holds the last wrapper that we've loaded.
    var isLoadingSpecies = false

    //Create a dictionary to hold the images indexed by the species names.
    var imageCache = Dictionary<String, ImageSearchResult>()

    //Add an array to viewcontroller to hold the search results.
    var speciesSearchResults:Array<StarWarsSpecies>?

    
    @IBOutlet weak var tableview: UITableView?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // place tableview below status bar, cuz I think it's prettier that way
        self.tableview?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        
        self.loadFirstSpecies()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "Background")
        let imageView = UIImageView(image: backgroundImage)
        self.tableview!.backgroundView = imageView
        
        // Adding a Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    


    //MARK: Customizing the Table View
    
    // Displaying Search Results
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return self.speciesSearchResults?.count ?? 0
        } else {
            return self.species?.count ?? 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview!.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        
        var arrayOfSpecies:Array<StarWarsSpecies>?
        if tableView == self.searchDisplayController!.searchResultsTableView {
            arrayOfSpecies = self.speciesSearchResults
        } else {
            arrayOfSpecies = self.species
        }
        
        if arrayOfSpecies != nil && arrayOfSpecies!.count >= indexPath.row
        {
            let species = arrayOfSpecies![indexPath.row]
            cell.textLabel?.text = species.name
            cell.detailTextLabel?.text = " " // if it's empty or nil it won't update correctly in iOS 8, see http://stackoverflow.com/questions/25793074/subtitles-of-uitableviewcell-wont-update
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            cell.imageView?.image = nil
            
            
            // Caching Images
            if let name = species.name {
                // Before retrieving the image, it is checking the cache to see if we already have it.
                if let cachedImageResult = imageCache[name]
                {
                    cell.imageView?.image = cachedImageResult.image // will work fine even if image is nil
                    cell.detailTextLabel?.text = cachedImageResult.fullAttribution()
                }
                else
                {
                    // load image from web
                    // this isn't ideal since it will keep running even if the cell scrolls off of the screen
                    // if we had lots of cells we'd want to stop this process when the cell gets reused
                    DuckDuckGoSearchController.imageFromSearchString(name, completionHandler: {
                        (imageSearchResult, error) in
                        if error != nil {
                            print(error)
                        }
                        
                        // Save the image so we won't have to keep fetching it if they scroll
                        self.imageCache[name] = imageSearchResult
                        if let cellToUpdate = self.tableview?.cellForRowAtIndexPath(indexPath)
                        {
                            if cellToUpdate.imageView?.image == nil
                            {
                                cellToUpdate.imageView?.image = imageSearchResult?.image // will work fine even if image is nil
                                cellToUpdate.detailTextLabel?.text = imageSearchResult?.fullAttribution()
                                cellToUpdate.setNeedsLayout() // need to reload the view, which won't happen otherwise since this is in an async call
                            }
                        }
                    })
                }
            }
            
            // See if we need to load more species
            if tableView != self.searchDisplayController!.searchResultsTableView {
                // See if we need to load more species
                let rowsToLoadFromBottom = 5;
                let rowsLoaded = self.species!.count
                if (!self.isLoadingSpecies && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
                {
                    if let totalRows = self.speciesWrapper?.count {
                        let remainingSpeciesToLoad = totalRows - rowsLoaded;
                        if (remainingSpeciesToLoad > 0)
                        {
                            self.loadMoreSpecies()
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // When The project is launched, it makes a call to the API to get a list of Star Wars species in JSON
    func loadFirstSpecies()
    {
        isLoadingSpecies = true
        StarWarsSpecies.getSpecies { wrapper, error in
            if let error = error
            {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error", message: "Could not load first species \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addSpeciesFromWrapper(wrapper)
            self.isLoadingSpecies = false
            self.tableview?.reloadData()
        }
    }
    
    func loadMoreSpecies()
    {
        self.isLoadingSpecies = true
        if self.species != nil && self.speciesWrapper != nil && self.species!.count < self.speciesWrapper!.count
        {
            // there are more species out there!
            StarWarsSpecies.getMoreSpecies(self.speciesWrapper, completionHandler: { wrapper, error in
                if let error = error
                {
                    // TODO: improved error handling
                    self.isLoadingSpecies = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more species \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got more!")
                self.addSpeciesFromWrapper(wrapper)
                self.isLoadingSpecies = false
                self.tableview?.reloadData()
            })
        }
    }
    
    func addSpeciesFromWrapper(wrapper: SpeciesWrapper?)
    {
        self.speciesWrapper = wrapper
        if self.species == nil
        {
            self.species = self.speciesWrapper?.species
        }
        else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil
        {
            self.species = self.species! + self.speciesWrapper!.species!
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row % 2 == 0
//        {
//            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
//        }
//        else
//        {
//            cell.backgroundColor = UIColor.whiteColor()
//        }
        
        //cell.backgroundColor = .clearColor()
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)

    }
    
    // MARK: Navigation & Segues from Search Results
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let speciesDetailVC = segue.destinationViewController as? DetailViewController
        {
            // gotta check if we're currently searching
            if self.searchDisplayController!.active {
                let indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForSelectedRow
                if indexPath != nil {
                    speciesDetailVC.species = self.speciesSearchResults?[indexPath!.row]
                }
            } else {
                let indexPath = self.tableview?.indexPathForSelectedRow!
                if indexPath != nil {
                    speciesDetailVC.species = self.species?[indexPath!.row]
                }
            }
        }
    }
    
    // MARK: Search Filter & Search Scope
    func filterContentForSearchText(searchText: String, scope: Int) {
        // Filter the array using the filter method
        if self.species == nil {
            self.speciesSearchResults = nil
            return
        }
        
        // Using lowercaseString on both the species name and the search text makes the search case insensitive.
        self.speciesSearchResults = self.species!.filter({( aSpecies: StarWarsSpecies) -> Bool in
            // pick the field to search
            var fieldToSearch: String?
            switch (scope) {
            case (0):
                fieldToSearch = aSpecies.name
            case (1):
                fieldToSearch = aSpecies.language
            case (2):
                fieldToSearch = aSpecies.classification
            default:
                fieldToSearch = nil
            }
            if fieldToSearch == nil {
                self.speciesSearchResults = nil
                return false
            }
            return fieldToSearch!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }
    
    // The function to handle changes to the search string is searchDisplayController:shouldReloadTableForSearchString
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        //Adjust our filter function to use the scope
        let selectedIndex = controller.searchBar.selectedScopeButtonIndex
        self.filterContentForSearchText(searchString!, scope: selectedIndex)
        return true
    }
    
    //The search should also reload when the scope changes, not just when the search text changes.
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let searchString = controller.searchBar.text
        self.filterContentForSearchText(searchString!, scope:searchOption)
        return true
    }
    
}

