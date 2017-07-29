//
//  ViewController.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import UIKit

    //MARK: - Private Methods
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    //MARK: - Properties
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

    //MARK: - UIViewController Properties
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    // None searchbar controllers array
    var species = [StarWarsSpecies]()

    var speciesWrapper: SpeciesWrapper? // holds the last wrapper that we've loaded.
    var isLoadingSpecies = false

    // Create a dictionary to hold the images indexed by the species names.
    var imageCache = Dictionary<String, ImageSearchResult>()

    // Add an array to viewcontroller to hold the search results.
    var speciesSearchResults: Array<StarWarsSpecies>?

    //MARK: - IBOutlets
    @IBOutlet weak var tableview: UITableView?

    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollOptionsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ViewController.showScrollOptions))
        self.navigationItem.rightBarButtonItem = scrollOptionsButton

        // place tableview below status bar, cuz I think it's prettier that way
        self.tableview?.contentInset = UIEdgeInsetsMake(-64.0, 0.0, 0.0, 0.0);

        loadFirstSpecies()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Deselection animation
        tableview!.indexPathsForSelectedRows?.forEach {
            tableview!.deselectRow(at: $0, animated: true)
        }

        // Add a background view to the table view
        let backgroundImage = UIImage(named: "Background")
        let imageView = UIImageView(image: backgroundImage)
        self.tableview!.backgroundView = imageView

        // Adding a Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableview?.startPullToRefresh()
    }

    func refresher() {
        let beatAnimator = BeatAnimator(frame: CGRect(x: 0, y: 0, width: 320, height: 5))
        tableview?.addPullToRefreshWithAction({
            OperationQueue().addOperation {
                sleep(2)
                OperationQueue.main.addOperation {
                    self.tableview?.stopPullToRefresh()
                }
            }
        }, withAnimator: beatAnimator)
    }

    // MARK: Customizing the Table View

    // Displaying Search Results
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return self.speciesSearchResults?.count ?? 0
        } else {
            return self.species.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview!.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell

        var arrayOfSpecies: Array<StarWarsSpecies>?
        if tableView == self.searchDisplayController!.searchResultsTableView {
            arrayOfSpecies = self.speciesSearchResults
        } else {
            arrayOfSpecies = self.species
        }

        if arrayOfSpecies != nil && arrayOfSpecies!.count >= (indexPath as NSIndexPath).row
        {
            let species = arrayOfSpecies![(indexPath as NSIndexPath).row]
            cell.textLabel?.text = species.name

            cell.detailTextLabel?.text = " " // if it's empty or nil it won't update correctly in iOS 8, see http://stackoverflow.com/questions/25793074/subtitles-of-uitableviewcell-wont-update
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true

            cell.imageView?.image = nil
            cell.imageView!.layer.masksToBounds = true
            cell.imageView!.layer.cornerRadius = 22

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
                            print(error.debugDescription)
                        }

                        // Save the image so we won't have to keep fetching it if they scroll
                        self.imageCache[name] = imageSearchResult
                        if let cellToUpdate = self.tableview?.cellForRow(at: indexPath)
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
                let rowsLoaded = self.species.count
                if (!self.isLoadingSpecies && ((indexPath as NSIndexPath).row >= (rowsLoaded - rowsToLoadFromBottom)))
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    // When The project is launched, it makes a call to the API to get a list of Star Wars species in JSON
    func loadFirstSpecies() {
        isLoadingSpecies = true
        StarWarsSpecies.getSpecies { wrapper, error in
            if let error = error
            {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error", message: "Could not load first species \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.addSpeciesFromWrapper(wrapper)
            self.isLoadingSpecies = false
            self.tableview?.reloadData()
        }
    }

    func loadMoreSpecies() {
        self.isLoadingSpecies = true
        refresher()
        if self.species != nil && self.speciesWrapper != nil && self.species.count < self.speciesWrapper!.count
        {
            // there are more species out there!
            StarWarsSpecies.getMoreSpecies(self.speciesWrapper, completionHandler: { wrapper, error in
                if let error = error
                {
                    self.isLoadingSpecies = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more species \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                print("got more!")
                self.addSpeciesFromWrapper(wrapper)
                self.isLoadingSpecies = false
                self.tableview?.reloadData()
            })
        }
    }

    func addSpeciesFromWrapper(_ wrapper: SpeciesWrapper?) {
        self.speciesWrapper = wrapper
        if self.species == nil
        {
            self.species = (self.speciesWrapper?.species)!
        }
        else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil
        {
            self.species = self.species + self.speciesWrapper!.species!
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        if indexPath.row % 2 == 0
        //        {
        //            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
        //        }
        //        else
        //        {
        //            cell.backgroundColor = UIColor.whiteColor()
        //        }

        // cell.backgroundColor = .clearColor()

        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)

    }

    // MARK: Navigation & Segues from Search Results
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let speciesDetailVC = segue.destination as? DetailViewController
        {
            // gotta check if we're currently searching
            if self.searchDisplayController!.isActive {
                let indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForSelectedRow
                if indexPath != nil {
                    speciesDetailVC.species = self.speciesSearchResults?[(indexPath! as NSIndexPath).row]
                }
            } else {
                let indexPath = self.tableview?.indexPathForSelectedRow!
                if indexPath != nil {
                    speciesDetailVC.species = self.species[(indexPath! as NSIndexPath).row]
                }
            }
        }
    }

    // MARK: Search Filter & Search Scope
    func filterContentForSearchText(_ searchText: String, scope: Int) {
        // Filter the array using the filter method
        if self.species == nil {
            self.speciesSearchResults = nil
            return
        }

        // Using lowercaseString on both the species name and the search text makes the search case insensitive.
        self.speciesSearchResults = self.species.filter({ (aSpecies: StarWarsSpecies) -> Bool in
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
            return fieldToSearch!.lowercased().range(of: searchText.lowercased()) != nil
        })
    }

    // The function to handle changes to the search string is searchDisplayController:shouldReloadTableForSearchString
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        // Adjust our filter function to use the scope
        let selectedIndex = controller.searchBar.selectedScopeButtonIndex
        self.filterContentForSearchText(searchString!, scope: selectedIndex)
        return true
    }

    // The search should also reload when the scope changes, not just when the search text changes.
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let searchString = controller.searchBar.text
        self.filterContentForSearchText(searchString!, scope: searchOption)
        return true
    }

    // MARK: Programmatic UITableView Scrolling
    func showScrollOptions() {
        
        let sheet = UIAlertController(title: "Where to", message: "Where would you like to scroll to?", preferredStyle: .actionSheet)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        });
        sheet.addAction(cancelAction)
        
        // Scroll to Top
        let firstRowAction = UIAlertAction(title: "First Row", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
            self.scrollToFirstRow()
            self.dismiss(animated: true, completion: nil)
        });
        sheet.addAction(firstRowAction)
        
        // Last Row
        let lastRowAction = UIAlertAction(title: "Last Row", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
            self.scrollToLastRow()
            self.dismiss(animated: true, completion: nil)
        });
        sheet.addAction(lastRowAction)
        
        // Selected Row
        let selectedRowAction = UIAlertAction(title: "Selected Row", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
            self.scrollToSelectedRow()
            self.dismiss(animated: true, completion: nil)
        });
        sheet.addAction(selectedRowAction)
        
        // Above Header
        let topAction = UIAlertAction(title: "Header", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
            self.scrollToHeader()
            self.dismiss(animated: true, completion: nil)
        });
        sheet.addAction(topAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    // scrollToRowAtIndexPath takes an NSIndexPath which is a way of giving a location in a set of nested arrays
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableview?.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    func scrollToLastRow() {
        let indexPath = IndexPath(row: species.count - 1, section: 0)
        self.tableview?.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func scrollToSelectedRow() {
        let selectedRows = self.tableview?.indexPathsForSelectedRows
        if let selectedRow = selectedRows![0] as? IndexPath {
            self.tableview?.scrollToRow(at: selectedRow, at: .middle, animated: true)
        }
    }
    
    func scrollToHeader() {
        self.tableview?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        refresher()
    }

}

