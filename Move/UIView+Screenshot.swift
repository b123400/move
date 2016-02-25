//
//  UIView+Screenshot.swift
//  Move
//
//  Created by b123400 on 26/2/2016.
//  Copyright © 2016 b123400. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}