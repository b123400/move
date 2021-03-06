//
//  FancyTransitionProtocol.swift
//  Move
//
//  Created by b123400 on 25/2/2016.
//  Copyright © 2016 b123400. All rights reserved.
//

import Foundation
import UIKit

enum ViewContentAnimationType {
    case NoAnimation
    case Animate
    case AnimateSubviews
}

protocol FancyTransitionViewController {
    func animationTypeForView(view:UIView) -> ViewContentAnimationType
    func viewsToAnimate() -> [UIView]
    func replacementViewsForAnimatingView(view:UIView) -> [UIView]
    
    func screenshotAfterHidingViews(views:[UIView]) -> UIImage
    func hideViewsForTransition(views:[UIView])
    func showViewsAfterTransition(views:[UIView])
}

extension UIViewController : FancyTransitionViewController {
    
    func animationTypeForView(view: UIView) -> ViewContentAnimationType {
        if view.subviews.count == 0 ||
            view.isKindOfClass(UIButton.self) ||
            view.isKindOfClass(UITextView.self) ||
            view.isKindOfClass(UILabel.self) ||
            view.isKindOfClass(UIWebView) {
            return .Animate
        }
        return .AnimateSubviews
    }
    
    func viewsToAnimate() -> [UIView] {
        var outputViews = Set<UIView>()
        var inputViews = Set<UIView>(self.view.subviews)
        
        while !inputViews.isEmpty {
            let thisView = inputViews.first!
            if thisView.hidden || thisView.alpha == 0 {
                inputViews.remove(thisView)
                continue
            }
            switch self.animationTypeForView(thisView) {
            case .Animate:
                inputViews.remove(thisView)
                outputViews.insert(thisView)
                
            case .AnimateSubviews:
                inputViews.remove(thisView)
                inputViews.unionInPlace(thisView.subviews)
                
            case .NoAnimation:
                continue
            }
        }
        return Array(outputViews)
    }
    
    func replacementViewsForAnimatingView(view: UIView) -> [UIView] {
        if let textView = view as? UITextView {
            return rectsFromTextView(textView).map({
                MirrorView(view: textView, bounds: $0)
            })
        }
        return [view]
    }
    
    func hideViewsForTransition(views: [UIView]) {
        for view in views {
            view.hidden = true
        }
    }
    
    func showViewsAfterTransition(views: [UIView]) {
        for view in views {
            view.hidden = false
        }
    }
    
    func screenshotAfterHidingViews(views: [UIView]) -> UIImage {
        self.hideViewsForTransition(views)
        let image = self.view.screenshot()
        self.showViewsAfterTransition(views)
        
        return image
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