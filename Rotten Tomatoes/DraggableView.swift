//
//  DraggableView.swift
//  Rotten Tomatoes
//
//  Created by Randy Ting on 9/20/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class DraggableView: UIView {
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let aTouch = touches.first!
    let location = aTouch.locationInView(self.superview)
    
    let previousLocation = aTouch.previousLocationInView(self.superview)
    
    if location.y < (self.superview?.nextResponder() as! MovieDetailsViewController).tabBarController!.tabBar.frame.origin.y {
      UIView.beginAnimations("Dragging View", context: nil)
      self.frame = CGRectOffset(self.frame, 0, (location.y - previousLocation.y))
      self.frame.size.height -= (location.y - previousLocation.y)
      UIView.commitAnimations()
    }

  }

}
