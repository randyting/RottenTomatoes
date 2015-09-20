//
//  MoviesCollectionViewCell.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/19/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MoviesCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var posterImage: UIImageView!
  
  //  MARK: - Lifecycle
  
  override func prepareForReuse() {
    posterImage.image = nil
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    posterImage.image = nil
    // Initialization code
  }
  
}
