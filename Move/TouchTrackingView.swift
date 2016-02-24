//
//  BRTouchTrackingView.swift
//  Move
//
//  Created by b123400 on 21/8/15.
//  Copyright © 2015 b123400. All rights reserved.
//

import Foundation
import UIKit

class TouchTrackingView: UIView {
    
    var lastPoint: CGPoint?
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        self.lastPoint = point
        return super.hitTest(point, withEvent: event)
    }
}