//
//  BRMirrorView.swift
//  Move
//
//  Created by b123400 on 13/6/15.
//  Copyright © 2015 b123400. All rights reserved.
//

import UIKit

class MirrorView: UIView {

    let sourceView : UIView
    let sourceBounds : CGRect
    
    init(view sourceView : UIView, bounds : CGRect) {
        self.sourceView = sourceView
        self.sourceBounds = bounds
        super.init(frame: bounds)
        
        self.clearsContextBeforeDrawing = false
        self.opaque = false
//        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
//        CGContextClearRect(context, rect)
        CGContextTranslateCTM(context, -self.sourceBounds.origin.x, -self.sourceBounds.origin.y)
        self.sourceView.layer.renderInContext(context!)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // make sure the coordinate is correct
        self.frame = self.sourceView.convertRect(self.sourceBounds, toView: self.superview)
    }
}
