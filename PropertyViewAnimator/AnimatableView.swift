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
    var originalTitleFrame: CGRect = CGRect.zero
    var movementAmount: CGFloat {
        return UIScreen.main.bounds.height / 4
    }
    var localState = ViewController.ViewState.step1
    
    func setup(state: ViewController.ViewState) {
        localState = state
        switch state {
        case .step1:
            break
        case .step2:
            if originalFrame == CGRect.zero {
                originalFrame = imageView.frame
                imageView.frame = imageView.frame.offsetBy(dx: 0, dy: localState.modifier*movementAmount)
            }
        }
    }

    func animate(showing: Bool) {
        if originalFrame == CGRect.zero {
            originalFrame = imageView.frame
        }
        if originalTitleFrame == CGRect.zero {
            originalTitleFrame = title.frame
        }
        switch showing {
        case false:
            imageView.frame = imageView.frame.offsetBy(dx: 0, dy: localState.modifier*movementAmount)
            title.frame = title.frame.offsetBy(dx: 0, dy: localState.modifier*movementAmount / 2)
            imageView.layer.opacity = 0
            title.layer.opacity = 0
            content.layer.opacity = 0
        case true:
            imageView.frame = originalFrame
            title.frame = originalTitleFrame
            imageView.layer.opacity = 1
            title.layer.opacity = 1
            content.layer.opacity = 1
        }
    }
    
}
