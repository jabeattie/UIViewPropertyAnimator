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
        
        var modifier: CGFloat {
            switch self {
            case .step1:
                return -1
            case .step2:
                return 1
            }
        }
    }
    
    @IBOutlet weak var step1View: AnimatableView!
    @IBOutlet weak var step2View: AnimatableView!
    
    var state: ViewState = .step1
    var viewAnimator: UIViewPropertyAnimator?
    var panGestureRecogniser: UIPanGestureRecognizer?
    
    
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
    
    @IBAction func downButtonTapped(_ sender: UIButton) {
        panningBegan()
        viewAnimator?.addCompletion({ (_) in
            self.panGestureRecogniser?.isEnabled = true
            switch self.state {
            case .step1:
                self.state = .step2
            case .step2:
                self.state = .step1
            }
        })
        viewAnimator?.startAnimation()
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
        step1View.setup(state: .step1)
        step2View.setup(state: .step2)
        
        let step1Showing: Bool = state != .step1
        let step2Showing: Bool = state != .step2
        
        viewAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.9, animations: {
            self.step1View.animate(showing: step1Showing)
            self.step2View.animate(showing: step2Showing)
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
        let springParameters = UISpringTimingParameters(dampingRatio: 0.9, initialVelocity: velocityVector)
        viewAnimator?.continueAnimation(withTimingParameters: springParameters, durationFactor: 1.0)
    }

}

