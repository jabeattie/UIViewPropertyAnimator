//
//  ViewController.swift
//  PropertyViewAnimator
//
//  Created by James Beattie on 10/12/2017.
//  Copyright © 2017 James Beattie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum ViewState {
        case step1
        case step2
    }

    
    @IBOutlet weak var step2ImageView: UIImageView!
    @IBOutlet weak var step1ImageView: UIImageView!
    
    var state: ViewState = .step1
    var viewAnimator: UIViewPropertyAnimator?
    var panGestureRecogniser: UIPanGestureRecognizer?
    var originalStep1Frame: CGRect = CGRect.zero
    var originalStep2Frame: CGRect = CGRect.zero
    var movementAmount: CGFloat {
        return UIScreen.main.bounds.height / 4
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        if let gestureRecogniser = panGestureRecogniser {
            view.addGestureRecognizer(gestureRecogniser)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        
        switch recognizer.state {
        case .began:
            panningBegan()
        case .ended:
            let velocity = recognizer.velocity(in: self.view)
            panningEnded(with: translation, velocity: velocity)
        default:
            panningChanged(translation: translation)
        }
    }

    func panningBegan() {
        guard !(viewAnimator?.isRunning ?? false) else { return }
        if originalStep1Frame == CGRect.zero {
            originalStep1Frame = step1ImageView.frame
        }
        if originalStep2Frame == CGRect.zero {
            originalStep2Frame = step2ImageView.frame
        }
        let step1Opacity: Float
        let step2Opacity: Float
        let targetStep1Frame: CGRect
        let targetStep2Frame: CGRect
        switch state {
        case .step1:
            targetStep1Frame = step1ImageView.frame.offsetBy(dx: 0, dy: -movementAmount)
            targetStep2Frame = originalStep2Frame
            step2ImageView.frame = originalStep2Frame.offsetBy(dx: 0, dy: movementAmount)
            step1Opacity = 0.0
            step2Opacity = 1.0
        case .step2:
            step1Opacity = 1.0
            step2Opacity = 0.0
            targetStep1Frame = originalStep1Frame
            targetStep2Frame = step2ImageView.frame.offsetBy(dx: 0, dy: movementAmount)
        }
        
        viewAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.75, animations: {
            self.step1ImageView.layer.opacity = step1Opacity
            self.step1ImageView.frame = targetStep1Frame
            self.step2ImageView.layer.opacity = step2Opacity
            self.step2ImageView.frame = targetStep2Frame
        })
    }
    
    func panningChanged(translation: CGPoint) {
        guard !(viewAnimator?.isRunning ?? false) else { return }
        
        let translatedY = self.view.center.y + translation.y
        var progress: CGFloat
        switch state {
        case .step1:
            progress = 1 - (translatedY / self.view.center.y)
        case .step2:
            progress = (translatedY / self.view.center.y) - 1
        }
        
        progress = max(0.001, min(0.999, progress))
        
        viewAnimator?.fractionComplete = progress
    }
    
    func panningEnded(with translation: CGPoint, velocity: CGPoint) {
        panGestureRecogniser?.isEnabled = false
        let screenHeight = UIScreen.main.bounds.size.height
        
        switch state {
        case .step1:
            if translation.y <= -screenHeight / 2 || velocity.y <= -100 {
                viewAnimator?.isReversed = false
                viewAnimator?.addCompletion({ (finalPosition) in
                    self.state = .step2
                    self.panGestureRecogniser?.isEnabled = true
                })
            } else {
                viewAnimator?.isReversed = true
                viewAnimator?.addCompletion({ (finalPosition) in
                    self.state = .step1
                    self.panGestureRecogniser?.isEnabled = true
                })
            }
        case .step2:
            if translation.y >= screenHeight / 2 || velocity.y >= 100 {
                viewAnimator?.isReversed = false
                viewAnimator?.addCompletion({ (finalPosition) in
                    self.state = .step1
                    self.panGestureRecogniser?.isEnabled = true
                })
            } else {
                viewAnimator?.isReversed = true
                viewAnimator?.addCompletion({ (finalPosition) in
                    self.state = .step2
                    self.panGestureRecogniser?.isEnabled = true
                })
            }
        }
        
        let velocityVector = CGVector(dx: velocity.x / 100, dy: velocity.y / 100)
        let springParameters = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: velocityVector)
        viewAnimator?.continueAnimation(withTimingParameters: springParameters, durationFactor: 1.0)
    }

}

