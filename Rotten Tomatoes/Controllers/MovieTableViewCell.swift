//
//  MovieTableViewCell.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/16/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
  
  //  MARK: - Storyboard Objects
  

  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisLabel: UILabel!
  
  //  MARK: - Lifecycle
  
  override func prepareForReuse() {
    posterImageView.image = nil
    titleLabel.text = ""
    synopsisLabel.text = ""
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    posterImageView.image = nil
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
