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
    let globalBounds : CGRect
    
    init(view sourceView : UIView, bounds : CGRect) {
        self.sourceView = sourceView
        self.sourceBounds = bounds
        self.globalBounds = self.sourceView.convertRect(bounds, toView: nil)
        super.init(frame: bounds)
        
        self.clearsContextBeforeDrawing = false
        self.opaque = false
        self.layer.fillMode = kCAFillModeBoth
        
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
        if let superview = self.superview {
            self.frame = superview.convertRect(self.globalBounds, fromView: nil)
        }
    }
}
