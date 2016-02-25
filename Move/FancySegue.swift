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
    var duration: Double = 1.0
    
    var containerView : UIView {
        // not sure if this is a good container view...
        return self.destinationViewController.view.superview!
    }
    
    public override func perform() {
        
        // the default order is:
        // [top]
        // source animating views
        // source screenshot
        // destination animating views
        // destination screenshot
        // destination
        // [bottom]

        // Capture a screenshot, so we can capture another screenshot without flasing, kinda stupid
        let window = UIApplication.sharedApplication().windows[0]
        let tempOverlayView = UIImageView(image: window.screenshot())
        tempOverlayView.frame = window.bounds
        window.addSubview(tempOverlayView)

        // Capture a screenshot without the animating views
        let sourceViews = self.prepareViews(
            self.sourceViewController,
            backgroundView: self.sourceBackgroundView)
        let sourceBounds = self.sourceViewController.view.convertRect(self.sourceViewController.view.bounds, toView: nil)

        self.sourceViewController.presentViewController(
            self.destinationViewController,
            animated: false) {
                let destinationViews = self.prepareViews(
                    self.destinationViewController,
                    backgroundView: self.destinationBackgroundView)
                
                let allViews = [self.destinationBackgroundView] + destinationViews + [self.sourceBackgroundView] + sourceViews
                
                for view in allViews {
                    self.containerView.addSubview(view)
                }
                self.sourceBackgroundView.frame = self.containerView.convertRect(sourceBounds, fromView: nil)
                self.destinationBackgroundView.frame = self.destinationViewController.view.frame
                
                tempOverlayView.removeFromSuperview()
                
                self.performAnimation(
                    sourceViews,
                    destinationViews: destinationViews) {
                        for view in allViews {
                            view.removeFromSuperview()
                        }
                }
        }
    }
    
    func performAnimation(sourceViews:[UIView], destinationViews:[UIView], callback:()->Void) {
        // modify this by subclassing
        // this is a sample of fadeing out the views
        for view in destinationViews {
            view.layer.opacity = 0
        }
        UIView.animateWithDuration(self.duration, animations: {
            for view in sourceViews + [self.sourceBackgroundView] {
                view.layer.opacity = 0
            }
            for view in destinationViews {
                view.layer.opacity = 1
            }
        }, completion: {
                _ in
                callback()
        })
    }
    
    func prepareViews(controller:UIViewController, backgroundView:UIImageView) -> [UIView] {
        let viewsToHide = controller.viewsToAnimate()
        let viewsToAnimate = viewsToHide.flatMap {
            controller.replacementViewsForAnimatingView($0)
        }
        
        let screenshot = controller.screenshotAfterHidingViews(viewsToHide)
        backgroundView.image = screenshot
        return viewsToAnimate.map {
            MirrorView(view: $0, bounds: $0.bounds)
        }
    }
}