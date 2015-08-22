//
//  BRMirrorView.swift
//  Move
//
//  Created by b123400 on 13/6/15.
//  Copyright © 2015 b123400. All rights reserved.
//

import UIKit

class BRMirrorView: UIView {

    let sourceView : UIView
    let sourceBounds : CGRect
    
    init(view sourceView : UIView, bounds : CGRect) {
        self.sourceView = sourceView
        self.sourceBounds = bounds
        // TODO: change to nil later
        let rect = sourceView.convertRect(bounds, toView: sourceView.superview)
        super.init(frame: rect)
        
        self.clearsContextBeforeDrawing = false
        self.opaque = true
//        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
//        CGContextClearRect(context, rect)
        CGContextTranslateCTM(context, -self.sourceBounds.origin.x, -self.sourceBounds.origin.y)
        self.sourceView.layer.renderInContext(context!)
    }

}
