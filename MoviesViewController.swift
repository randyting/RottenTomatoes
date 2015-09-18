//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/16/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
  
  //  MARK: - Storyboard Properties
  
  @IBOutlet weak var networkErrorLabel: UILabel!
  @IBOutlet weak var moviesTableView: UITableView!
  
  //  MARK: - Properties
  
  var movies: [NSDictionary]?
  let refreshControl = UIRefreshControl()
  
  //  MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initializeReachabilityMonitoring()
    
    initializeNetworkErrorWarningLabel()
    
    moviesTableView.dataSource = self
    moviesTableView.delegate = self
    
    refreshControl.addTarget(self, action: "reloadMovies", forControlEvents: UIControlEvents.ValueChanged)
    moviesTableView.insertSubview(refreshControl, atIndex: 0)
    
    reloadMovies()
  }
  
  //  MARK: - Behavior
  
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
  
  func hideNetworkError() {
    UIView.animateWithDuration(1, animations: { () -> Void in
      self.networkErrorLabel.alpha = 0
    })
  }
  
  func showNetworkError() {
    UIView.animateWithDuration(1, animations: { () -> Void in
      self.networkErrorLabel.alpha = 1
      self.networkErrorLabel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    })
  }
  
  func reloadMovies(){
    
    let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
    let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0.0)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
      
      if let error = error {
        
        print(error.localizedDescription)
        
      } else {
        
        let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
        if let json = json {
          self.movies = json!["movies"] as! [NSDictionary]?
          
          dispatch_async(dispatch_get_main_queue()){
            self.moviesTableView.reloadData()
          }
        }
      }
      dispatch_async(dispatch_get_main_queue()){
        JTProgressHUD.hide()
        self.refreshControl.endRefreshing()
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
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = moviesTableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
    
    let movie = movies![indexPath.row] as NSDictionary
    
    cell.titleLabel.text = movie["title"] as? String
    cell.synopsisLabel.text = movie["synopsis"] as? String
    
    let urlString = movie.valueForKeyPath("posters.thumbnail") as! String
    let posterURL = NSURL(string: urlString)!
    
    cell.posterImageView.setImageWithURL(posterURL)

    
    return cell
  }
  
  // MARK: - Table View Delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    let cell = sender as! UITableViewCell
    let movie = movies![moviesTableView.indexPathForCell(cell)!.row]
    
    let detailsViewController = segue.destinationViewController as! MovieDetailsViewController
    
    detailsViewController.movie = movie
  }
  
}
