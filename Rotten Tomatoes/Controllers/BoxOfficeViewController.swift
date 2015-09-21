//
//  BoxOfficeViewController.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/18/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class BoxOfficeViewController: MoviesViewController {
  
  

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    urlForAPI = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Box Office"
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
