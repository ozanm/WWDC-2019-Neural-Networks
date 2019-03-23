//
//  UIView.swift
//  UIView_Extensions
//

import Foundation
import UIKit

extension UIView {
    public func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: "kCATransitionFade")
    }
}

extension Array {
    func shuffled() -> Array {
        var array = self
        for _ in 0..<array.count {
            array.sort(by: { (_,_) in arc4random() < arc4random() })
        }
        
        return array
    }
}

extension CGRect {
    func scaleUp(scaleUp: CGFloat) -> CGRect {
        let biggerRect = self.insetBy(
            dx: -self.size.width * scaleUp,
            dy: -self.size.height * scaleUp
        )
        
        return biggerRect
    }
}

public extension FloatingPoint {
    /// Rounds the double to decimal places value
    func roundTo(places: Int) -> Self {
        let divisor = Self(Int(pow(10.0, Double(places))))
        return (self * divisor).rounded() / divisor
    }
}
