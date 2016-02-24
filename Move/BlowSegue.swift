//
//  BRBlowSegue.swift
//  Move
//
//  Created by b123400 on 12/6/15.
//  Copyright © 2015 b123400. All rights reserved.
//

import UIKit

var animator : UIDynamicAnimator?

public class BlowSegue: UIStoryboardSegue {
    public var center: CGPoint
    public var duration: CFTimeInterval = 5.0
    var animators: [UIDynamicAnimator] = []
    var animatedViews: [UIView] = []
    var startedEntering = false

    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        center = CGPoint(x: source.view.frame.midX, y: source.view.frame.midY)
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    
    override public func perform() {
        
        let viewsToScan = Set<UIView>() //self.viewsToScan(self.sourceViewController.view)
        let views = Set<UIView>()
        
        let textViews = views.filter { (view) -> Bool in
            if let _ = view as? UITextView { return true }
            if let _ = view as? UILabel { return true }
            return false
        }
        
        animator = UIDynamicAnimator(referenceView: self.sourceViewController.view)
        
        let field = UIFieldBehavior.radialGravityFieldWithPosition(self.center)
        field.strength = -20
        field.smoothness = 1
        animator?.addBehavior(field)
        
        for textView in textViews {
            guard (textView as? UITextView != nil) else { continue }
            let textView = textView as! UITextView
            
            let rects = rectsFromTextView(textView)
            let newViews = rects.map({ (rect) -> UIView in
                MirrorView(view: textView, bounds: rect)
            })
            
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.toValue = 0
            fadeAnimation.removedOnCompletion = false
            fadeAnimation.fillMode = "both"
            fadeAnimation.duration = self.duration/2.0
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            fadeAnimation.delegate = self
            
            for thisNewView in newViews {
                textView.superview!.addSubview(thisNewView)
                field.addItem(thisNewView)
                thisNewView.layer.addAnimation(fadeAnimation, forKey: "blow")
                self.animatedViews.append(thisNewView)
            }

            animator?.addBehavior(field);
            
            let coverView = self.coverViewWithView(self.sourceViewController.view, animatingViews: views)
            textView.superview!.insertSubview(coverView, aboveSubview: textView)
        }
        
//        self.sourceViewController.presentViewController(self.destinationViewController, animated: false) {
//            
//        }
    }
    
    func enterDestinationController() {
        
        // TODO: capture shit
        let viewsToAnimate = Set<UIView>()
        let textViews = viewsToAnimate.filter { (view) -> Bool in
            if let _ = view as? UITextView { return true }
            if let _ = view as? UILabel { return true }
            return false
        }

        for textView in textViews {
            guard (textView as? UITextView != nil) else { continue }
            let textView = textView as! UITextView
            
            let rects = rectsFromTextView(textView)
            let newViews = rects.map({ (rect) -> UIView in
                MirrorView(view: textView, bounds: rect)
            })
            
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 0
            fadeAnimation.removedOnCompletion = false
            fadeAnimation.fillMode = "both"
            fadeAnimation.duration = self.duration/2
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fadeAnimation.delegate = self
            
            for thisNewView in newViews {
                // TODO: insert to the correct view
                let originalCenter = thisNewView.center
                thisNewView.center = self.center
                self.sourceViewController.view.addSubview(thisNewView)
                
                let thisAnimator = UIDynamicAnimator(referenceView: self.sourceViewController.view)
                self.animators.append(thisAnimator)
                
                let field = UIFieldBehavior.springField()
                field.strength = 3
                field.position = originalCenter
                thisAnimator.addBehavior(field)
                field.addItem(thisNewView)
                
                let behavior = UIDynamicItemBehavior(items: [thisNewView])
                behavior.resistance = 4
                field.addChildBehavior(behavior)
                
//                let gravity = UIFieldBehavior.radialGravityFieldWithPosition(originalCenter)
//                gravity.strength = 1
//                gravity.smoothness = 1
//                thisAnimator.addBehavior(gravity)
//                gravity.addItem(thisNewView)

                thisNewView.layer.addAnimation(fadeAnimation, forKey: "blow")
            }
        }
    }

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag && !startedEntering {
            startedEntering = true
            self.animatedViews.forEach({ (view:UIView) -> () in
                view.removeFromSuperview()
            })
            self.animatedViews = []
            self.animators = []
            self.enterDestinationController()
        }
    }
    
    func coverViewWithView(view:UIView, animatingViews:Set<UIView>) -> UIView {
        // TODO: Add capture logic
        let coverView = UIView(frame: view.bounds)
        coverView.backgroundColor = UIColor.whiteColor()
        return coverView;
    }

    func rectsFromTextView(textView:UITextView) -> [CGRect] {
        var rects : [CGRect] = []
        
        var position : UITextPosition? = textView.beginningOfDocument
        while position != nil {
            guard let nextPosition = textView.positionFromPosition(position!, offset: 1) else { break }
            
            guard let textRange = textView.textRangeFromPosition(
                position!,
                toPosition: nextPosition)
                else { break }
            
            position = nextPosition

            let rect = textView.firstRectForRange(textRange)
            if rects.count > 0 && rects.last! == rect {
                continue
            }
            if rect.size.width == 0 || rect.size.height == 0 {
                continue
            }
            rects.append(rect)
        }
        return rects
    }

}
