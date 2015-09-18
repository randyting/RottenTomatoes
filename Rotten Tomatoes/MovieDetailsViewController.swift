//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/16/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
  
  //  MARK: - Storyboard Objects
  
  @IBOutlet weak var posterImage: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisLabel: UILabel!
  
  var movie: NSDictionary!
  
  //  MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = movie["title"] as? String
   
    titleLabel.text = movie["title"] as? String
    synopsisLabel.text =  movie["synopsis"] as? String
    
    var urlString = movie.valueForKeyPath("posters.thumbnail") as! String
    let range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
    
    if let range = range {
      urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
    }
    
    let posterURL = NSURL(string: urlString)!
    
    posterImage.setImageWithURL(posterURL)
  }
  
}
