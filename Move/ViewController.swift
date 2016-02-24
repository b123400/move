//
//  ViewController.swift
//  Move
//
//  Created by b123400 on 12/6/15.
//  Copyright © 2015 b123400. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? BlowSegue,
            view = self.view as? TouchTrackingView,
            lastPoint = view.lastPoint {
            segue.center = lastPoint
        }
    }
}

