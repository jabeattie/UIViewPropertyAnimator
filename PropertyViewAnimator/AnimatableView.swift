//
//  AnimatableView.swift
//  PropertyViewAnimator
//
//  Created by James Beattie on 10/12/2017.
//  Copyright © 2017 James Beattie. All rights reserved.
//

import UIKit

class AnimatableView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    var originalFrame: CGRect = CGRect.zero
    var movementAmount: CGFloat {
        return UIScreen.main.bounds.height / 4
    }

    
}
