//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/16/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit
import AFNetworking
import JTProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
  
  //  MARK: - Storyboard Properties
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var networkErrorLabel: UILabel!
  @IBOutlet weak var moviesTableView: UITableView!
  @IBOutlet weak var viewTypeSelectionToolBar: UIToolbar!
  @IBOutlet weak var moviesCollectionView: UICollectionView!
  
  //  MARK: - Properties
  
  var movies: [NSDictionary]?
  var filteredMovies: [NSDictionary]?
  let refreshControl = UIRefreshControl()
  let gridRefreshControl = UIRefreshControl()
  var urlForAPI = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
  var navBarHairlineImageView: UIImageView?
  var gridSearchBar = UISearchBar()
  var searchValue = ""
  var gridSearchIsActive = false
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  //  MARK: - Lifecycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navBarHairlineImageView?.hidden = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /* Uncomment to show network error message anytime there is no internet connection regardless of API call */
    // initializeReachabilityMonitoring()
    
    navBarHairlineImageView = self.findHairlineImageViewUnder(navigationController?.navigationBar)
    
    initializeNetworkErrorWarningLabel()
    
    searchBar.delegate = self
    setReturnKeyToDoneForSearchBar(searchBar)
    
    moviesTableView.dataSource = self
    moviesTableView.delegate = self
    moviesTableView.setContentOffset(CGPointMake(0, searchBar.frame.size.height), animated: false)
    moviesTableView.frame.size.height -= self.tabBarController!.tabBar.frame.height
    
    gridSearchBar.frame = CGRectMake(0, 0, moviesCollectionView.frame.width, searchBar.frame.height)
    moviesCollectionView.addSubview(gridSearchBar)
    gridSearchBar.delegate = self
    
    moviesCollectionView.dataSource = self
    moviesCollectionView.delegate = self
    moviesCollectionView.frame.size.height -= self.tabBarController!.tabBar.frame.height
    moviesCollectionView.hidden = true
    
    refreshControl.addTarget(self, action: "reloadMovies", forControlEvents: UIControlEvents.ValueChanged)
    moviesTableView.insertSubview(refreshControl, atIndex: 0)
    gridRefreshControl.addTarget(self, action: "reloadMovies", forControlEvents: UIControlEvents.ValueChanged)
    moviesCollectionView.insertSubview(gridRefreshControl, atIndex: 0)
    moviesCollectionView.alwaysBounceVertical = true;
    
    reloadMovies()
    moviesCollectionView.setContentOffset(CGPointMake(0, gridSearchBar.frame.size.height), animated: false)
  }
  
  //  MARK: - Helper
  
  func setReturnKeyToDoneForSearchBar (searchBar: UISearchBar) {
    for subviews in searchBar.subviews {
      if (subviews.conformsToProtocol(UITextInputTraits)) {
        let textField = subviews as! UITextField
        textField.returnKeyType = UIReturnKeyType.Done
      } else {
        for subview in subviews.subviews {
          if (subview.conformsToProtocol(UITextInputTraits)) {
            let textField = subview as! UITextField
            textField.returnKeyType = UIReturnKeyType.Done
          }
        }
      }
    }
  }
  
  func findHairlineImageViewUnder(view: UIView?) -> UIImageView? {
    if view is UIImageView && view!.bounds.size.height <= 1.0 {
      return view as! UIImageView?
    }
    for subview in view!.subviews {
      let imageView = self.findHairlineImageViewUnder(subview)
      if let imageView  = imageView {
        return imageView
      }
    }
    return nil
  }
  
  func setPosterImageForImageView(imageView: UIImageView, movie: NSDictionary) {
    let urlString = movie.valueForKeyPath("posters.thumbnail") as! String
    let posterURL = NSURL(string: urlString)!
    let posterURLRequest = NSURLRequest(URL: posterURL)
    
    imageView.setImageWithURLRequest(posterURLRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if response.statusCode != 0 {
          self.hideNetworkError()
          imageView.image = image
          UIView.animateWithDuration(1) { () -> Void in
            imageView.alpha = 0
            imageView.alpha = 1
          }
        } else {
          imageView.image = image
        }
      })
      }) { (request, response, error) -> Void in
        dispatch_async(dispatch_get_main_queue()){
          self.showNetworkError()
        }
    }
    
  }
  
  func filterMoviesWithSearchText(searchText: String) -> [NSDictionary] {
    let filteredMovies = self.movies!.filter({ (movie: NSDictionary) -> Bool in
      let stringMatch = (movie["title"] as! String).rangeOfString(searchText)
      return (stringMatch != nil)
    }) as [NSDictionary]
    
    return filteredMovies
  }
  
  //  MARK: - Initialization
  
  func initializeReachabilityMonitoring(){
    AFNetworkReachabilityManager.sharedManager().startMonitoring()
    
    AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (AFNetworkReachabilityStatus) -> Void in
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        switch (AFNetworkReachabilityStatus){
        case .NotReachable:
          self.showNetworkError()
        case .ReachableViaWiFi:
          self.hideNetworkError()
        case .ReachableViaWWAN:
          self.hideNetworkError()
        case .Unknown:
          self.showNetworkError()
        }
      })
    }
    
  }
  
  func initializeNetworkErrorWarningLabel(){
    let warningIcon = UIImage(named: "warningIcon")!
    let scaledWarningIcon = UIImage(CIImage: CIImage(image: warningIcon)!, scale: 2.5, orientation: warningIcon.imageOrientation)
    
    let attachment = NSTextAttachment()
    attachment.image = scaledWarningIcon
    let warningIconAttributedString = NSAttributedString(attachment: attachment)
    let warningString = NSMutableAttributedString()
    warningString.appendAttributedString(warningIconAttributedString)
    warningString.appendAttributedString(NSAttributedString(string: " Network Error"))
    networkErrorLabel.attributedText = warningString
    
    networkErrorLabel.alpha = 0
  }
  
  //  MARK: - Behavior
  
  @IBAction func viewTypeChanged(sender: AnyObject) {
    let viewTypeControl = sender as! UISegmentedControl
    switch viewTypeControl.selectedSegmentIndex {
    case 0:
      moviesTableView.hidden = false
      moviesCollectionView.hidden = true
    case 1:
      moviesTableView.hidden = true
      moviesCollectionView.hidden = false
    default:
      assert(true, "Tried to access view type that does not exist.")
    }
  }
  
  func hideNetworkError() {
    UIView.animateWithDuration(1, animations: { () -> Void in
      if self.networkErrorLabel.alpha == 1 {
        self.moviesTableView.frame.origin.y -= self.networkErrorLabel.frame.height
        self.moviesTableView.frame.size.height += self.networkErrorLabel.frame.height
        self.moviesCollectionView.frame.origin.y -= self.networkErrorLabel.frame.height
        self.moviesCollectionView.frame.size.height += self.networkErrorLabel.frame.height
      }
      self.networkErrorLabel.alpha = 0
    })
  }
  
  func showNetworkError() {
    UIView.animateWithDuration(1, animations: { () -> Void in
      if self.networkErrorLabel.alpha == 0 {
        self.moviesTableView.frame.origin.y += self.networkErrorLabel.frame.height
        self.moviesTableView.frame.size.height -= self.networkErrorLabel.frame.height
        self.moviesCollectionView.frame.origin.y += self.networkErrorLabel.frame.height
        self.moviesCollectionView.frame.size.height -= self.networkErrorLabel.frame.height
      }
      self.networkErrorLabel.alpha = 1
      self.networkErrorLabel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
      
    })
  }
  
  func reloadMovies(){
    
    let request = NSURLRequest(URL: urlForAPI, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0.0)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
      
      if let error = error {
        
        print(error.localizedDescription)
        dispatch_async(dispatch_get_main_queue()){
          self.showNetworkError()
        }
        
      } else {
        
        let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
        if let json = json {
          self.movies = json!["movies"] as! [NSDictionary]?
          if self.searchValue.characters.count == 0 {
            self.filteredMovies = self.movies
          } else {
            self.filteredMovies = self.filterMoviesWithSearchText(self.searchValue)
          }
          
          
          dispatch_async(dispatch_get_main_queue()){
            self.hideNetworkError()
            self.moviesTableView.reloadData()
            self.moviesCollectionView.reloadData()
            if self.gridSearchIsActive {
              self.gridSearchBar.becomeFirstResponder()
              self.setReturnKeyToDoneForSearchBar(self.gridSearchBar)
            }
          }
        }
      }
      dispatch_async(dispatch_get_main_queue()){
        JTProgressHUD.hide()
        self.refreshControl.endRefreshing()
        self.gridRefreshControl.endRefreshing()
      }
    }
    
    task.resume()
    JTProgressHUD.show()
    
  }
  
  func hasConnectivity() -> Bool {
    return AFNetworkReachabilityManager.sharedManager().reachable
  }
  
  
  //  MARK: - Table View Data Source
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let filteredMovies = filteredMovies {
      return filteredMovies.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = moviesTableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
    
    let movie = filteredMovies![indexPath.row] as NSDictionary
    
    cell.titleLabel.text = movie["title"] as? String
    cell.synopsisLabel.text = movie["synopsis"] as? String
    
    self.setPosterImageForImageView(cell.posterImageView, movie: movie)
    
    return cell
  }
  
  // MARK: - Table View Delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: - Search Bar Delegate
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    searchValue = searchText
    gridSearchBar.text = searchText
    self.searchBar.text = searchText
    
    if searchValue == "" {
      filteredMovies = movies
      gridSearchIsActive = false
      searchBar.performSelector("resignFirstResponder", withObject: nil, afterDelay: 0)
    } else {
      gridSearchIsActive = true
      filteredMovies = filterMoviesWithSearchText(searchValue)
    }
    
    moviesTableView.reloadData()
    moviesCollectionView.reloadData()
    searchBar.becomeFirstResponder()
    setReturnKeyToDoneForSearchBar(searchBar)
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    gridSearchIsActive = false
    searchBar.resignFirstResponder()
  }
  
  //  MARK: - Collection View Delegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
  }
  
  //  MARK: - Collection View Datasource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let filteredMovies = filteredMovies {
      return filteredMovies.count
    } else {
      return 0
    }
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MoviesCollectionViewCell
    
    let movie = filteredMovies![indexPath.row] as NSDictionary
    
    self.setPosterImageForImageView(cell.posterImage, movie: movie)
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let headerView =
      collectionView.dequeueReusableSupplementaryViewOfKind(kind,
        withReuseIdentifier: "GridHeaderView",
        forIndexPath: indexPath)
      return headerView
    default:
      assert(false, "Unexpected element kind")
    }
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var movie: NSDictionary?
    
    let detailsViewController = segue.destinationViewController as! MovieDetailsViewController
    
    if (sender as? MovieTableViewCell != nil) {
      let cell = sender as! MovieTableViewCell
      movie = filteredMovies![moviesTableView.indexPathForCell(cell)!.row]
      detailsViewController.thumbnailImage = cell.posterImageView.image
    } else if (sender as? MoviesCollectionViewCell != nil){
      let cell = sender as! MoviesCollectionViewCell
      movie = filteredMovies![moviesCollectionView.indexPathForCell(cell)!.row]
      detailsViewController.thumbnailImage = cell.posterImage.image
    }
    
    detailsViewController.movie = movie
    
  }
  
}

