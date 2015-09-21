//
//  DVDViewController.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/18/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class DVDViewController: MoviesViewController {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    urlForAPI = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "DVDs"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
