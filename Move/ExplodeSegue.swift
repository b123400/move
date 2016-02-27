//
//  ExplodeSegue.swift
//  Move
//
//  Created by b123400 on 26/2/2016.
//  Copyright © 2016 b123400. All rights reserved.
//

import Foundation
import UIKit

class ExplodeSegue : FancySegue {
    var center: CGPoint // based in window
    var animators : [UIDynamicAnimator] = []

    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        center = source.view.convertPoint(CGPoint(x: source.view.frame.midX, y: source.view.frame.midY), toView: nil)
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func performAnimation(sourceViews: [UIView], destinationViews: [UIView], callback: () -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var enterAnimations : [UIView:CAAnimation] = [:]
            for view in sourceViews {
                enterAnimations[view] = self.enterAnimationForView(view)
            }
            let fadeAnimation = self.fadeOutAnimation()
            dispatch_async(dispatch_get_main_queue()) {
                CATransaction.begin()
                let startTiming = CACurrentMediaTime() + 0.5
                fadeAnimation.beginTime = startTiming
                for (view, anim) in enterAnimations {
                    anim.beginTime = startTiming
                    view.layer.addAnimation(anim, forKey: nil)
                    view.layer.addAnimation(fadeAnimation, forKey: nil)
                }
                self.sourceBackgroundView.layer.addAnimation(fadeAnimation, forKey: nil)
                CATransaction.commit()
                
                for view in destinationViews {
                    view.layer.opacity = 0
                }
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64((self.duration/2.0+0.5) * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    for view in destinationViews {
                        let originalCenter = view.center
                        view.center = self.center
                        
                        let thisAnimator = UIDynamicAnimator(referenceView: self.containerView)
                        self.animators.append(thisAnimator)
                        
                        let field = UIFieldBehavior.springField()
                        field.strength = 3
                        field.position = originalCenter
                        thisAnimator.addBehavior(field)
                        field.addItem(view)
                        
                        let behavior = UIDynamicItemBehavior(items: [view])
                        behavior.resistance = 4
                        field.addChildBehavior(behavior)
                        view.layer.opacity = 1
                    }
                });
            }
        }
    }
    
    func enterAnimationForView(view:UIView) -> CAAnimation {
        let (x, y) = self.velocityForView(view)
        let moveAnimation = self.animationWithInitialVelocity(x, y: y, friction: 5, duration: self.duration/2.0)
        return moveAnimation
    }
    
    func fadeOutAnimation() -> CAAnimation {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue = 0
        fadeAnimation.removedOnCompletion = false
        fadeAnimation.fillMode = "both"
        fadeAnimation.duration = self.duration/2.0
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        fadeAnimation.delegate = self
        return fadeAnimation
    }
    
    func animationWithInitialVelocity(x:Double, y:Double, friction:Double, duration:Double, step:Int = 100) -> CAAnimation {
        let durationPerFrame = duration / Double(step)
        let moveAnimation = CAKeyframeAnimation(keyPath: "transform")
        var values : [NSValue] = []
        
        let xFriction = x > 0 ? -friction : friction
        let yFriction = y > 0 ? -friction : friction
        
        // 0 = v = u + at
        let xStopTime = (-x / xFriction)
        let yStopTime = (-y / yFriction)
        
        for i in 0..<step {
            let timePassed = Double(i) * durationPerFrame
            // s = ut + 0.5 * a * t^2
            let xDistance = xStopTime > 0 && timePassed > xStopTime
                ? x*xStopTime + 0.5*xFriction*pow(xStopTime, 2)
                : x*timePassed + 0.5*xFriction*pow(timePassed,2)

            let yDistance = yStopTime > 0 && timePassed > yStopTime
                ? y*yStopTime + 0.5*yFriction*pow(yStopTime, 2)
                : y*timePassed + 0.5*yFriction*pow(timePassed,2)
            
            let transform = CATransform3DMakeTranslation(CGFloat(xDistance), CGFloat(yDistance), 0)
            values.append(NSValue(CATransform3D: transform))
        }
        moveAnimation.values = values
        moveAnimation.duration = duration
        return moveAnimation
    }
    
    func velocityForView(view:UIView) -> (Double, Double) {
        
        // 50 ~ 500
        // 50 + 400 * (0 ~ 1)
        // 50 + 400 * (100 ~ 600)
        
        let minDistance = 100.0
        let maxDistance = 600.0
        let baseVelocity = 30.0
        let extraVelocity = 1000.0
        let point = view.center
        let xDistance = Double(point.x - center.x) // -
        let yDistance = Double(point.y - center.y)
        let distance = min(maxDistance, max(minDistance, sqrt(pow(xDistance,2)+pow(yDistance,2)))) // 100 ~ 600
        var percentage = (distance - minDistance) / (maxDistance - minDistance) // 0 ~ 1
        percentage = 1 - percentage
        percentage = pow(percentage, 2)
        let velocity = baseVelocity + extraVelocity * percentage
        let angle = atan(yDistance/xDistance)
        
        var xVelocity = velocity * cos(angle)
        var yVelocity = velocity * sin(angle)
        
        xVelocity = abs(xVelocity) * ( xDistance<0 ? -1 : 1 )
        yVelocity = abs(yVelocity) * ( yDistance<0 ? -1 : 1 )

        return (xVelocity, yVelocity)
    }
}