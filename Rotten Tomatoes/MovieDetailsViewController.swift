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
  var thumbnailImage: UIImage?
  
  //  MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeText()
    setupBackgroundImage()
  }
  
  //  MARK: - Setup
  
  func initializeText(){
    self.title = movie["title"] as? String
    titleLabel.text = movie["title"] as? String
    synopsisLabel.text =  movie["synopsis"] as? String
    synopsisLabel.sizeToFit()
  }
  
  func setupBackgroundImage(){
    var urlString = movie.valueForKeyPath("posters.thumbnail") as! String
    let range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
    if let range = range {
      urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
    }
    let posterURL = NSURL(string: urlString)!
    let posterURLRequest = NSURLRequest(URL: posterURL)
    posterImage.setImageWithURLRequest(posterURLRequest, placeholderImage: thumbnailImage, success: { (request, response, image) -> Void in
      self.posterImage.image = image
      }) { (request, response, error) -> Void in
        // Do nothing
    }
  }
  
}
