//
//  BRFancySegue.swift
//  Move
//
//  Created by b123400 on 25/2/2016.
//  Copyright © 2016 b123400. All rights reserved.
//

import Foundation
import UIKit

public class FancySegue : UIStoryboardSegue {
    
    let sourceBackgroundView = UIImageView()
    let destinationBackgroundView = UIImageView()
    
    var containerView : UIView {
        // not sure if this is a good container view...
        return self.sourceViewController.view.superview!
    }
    
    public override func perform() {
        let destinationViews = self.prepareViews(
            self.destinationViewController,
            backgroundView: self.destinationBackgroundView)
        self.addDestinationViewsToControler(destinationViews)
        let sourceViews = self.prepareViews(
            self.sourceViewController,
            backgroundView: self.sourceBackgroundView)
        self.addSourceViewsToContainer(sourceViews)
    }
    
    func prepareViews(controller:UIViewController, backgroundView:UIImageView) -> [UIView] {
        let viewsToHide = controller.viewsToAnimate()
        let viewsToAnimate = viewsToHide.flatMap {
            controller.replacementViewsForAnimatingView($0)
        }
        
        let screenshot = controller.screenshotAfterHidingViews(viewsToHide)
        self.sourceBackgroundView.frame = CGRectMake(
            0, 0,
            CGRectGetWidth(self.sourceViewController.view.frame),
            CGRectGetHeight(self.sourceViewController.view.frame))
        
        backgroundView.image = screenshot
        self.containerView.addSubview(backgroundView)
        return viewsToAnimate.map {
            MirrorView(view: $0, bounds: $0.bounds)
        }
    }
    
    // Override this if you want to move views front/back
    func addSourceViewsToContainer(views:[UIView]) {
        for view in views {
            self.containerView.addSubview(view)
        }
    }

    // Override this if you want to move views front/back
    func addDestinationViewsToControler(views:[UIView]) {
        for view in views {
            self.containerView.addSubview(view)
        }
    }
}