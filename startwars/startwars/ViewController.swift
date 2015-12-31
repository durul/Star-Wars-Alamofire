//
//  ViewController.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var species:Array<StarWarsSpecies>?
    var speciesWrapper:SpeciesWrapper? // holds the last wrapper that we've loaded
    var isLoadingSpecies = false

    //Create a dictionary to hold the images indexed by the species names
    var imageCache = Dictionary<String, ImageSearchResult>()

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

    //MARK: Customizing the Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.species == nil
        {
            return 0
        }
        return self.species!.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if self.species != nil && self.species!.count >= indexPath.row  {
            let species = self.species![indexPath.row]
            
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
            if self.species != nil && self.species!.count >= indexPath.row
            {
                let species = self.species![indexPath.row]
                cell.textLabel?.text = species.name
                cell.detailTextLabel?.text = species.classification
                
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
        if indexPath.row % 2 == 0
        {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
        }
        else
        {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let speciesDetailVC = segue.destinationViewController as? DetailViewController {
            if let indexPath = self.tableview?.indexPathForSelectedRow {
                speciesDetailVC.species = self.species?[indexPath.row]
                }
            }
        }
}

