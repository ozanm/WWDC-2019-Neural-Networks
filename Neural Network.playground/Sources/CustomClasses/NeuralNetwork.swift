import UIKit
import CoreML

/*
 * FEEDFORWARD NEURAL NETWORK: BASIC LOGIC OUTLINE
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
*/

public class NeuralNetwork : UIView {
    
    private let layers : [String: [UIView]] = ["Input": [UIView(), UIView(), UIView(), UIView(), UIView()],
                                               "Hidden": [UIView(), UIView(), UIView(), UIView(), UIView(), UIView()],
                                               "Output": [UIView(), UIView(), UIView(), UIView(), UIView()]]
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for i in 0..<layers["Input"]!.count {
            layers["Input"]![i].frame = CGRect(x: 150, y: (35 * i) + (20 * i) + 40, width: 35, height: 35)
            layers["Input"]![i].backgroundColor = UIColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1)
            layers["Input"]![i].layer.cornerRadius = layers["Input"]![i].frame.size.height / 2
            layers["Input"]![i].layer.borderColor = UIColor.white.cgColor
            layers["Input"]![i].layer.borderWidth = 2
            layers["Input"]![i].alpha = 0
            self.addSubview(layers["Input"]![i])
        }
        
        for i in 0..<layers["Hidden"]!.count {
            layers["Hidden"]![i].frame = CGRect(x: 50, y: (35 * i) + (20 * i) + 20, width: 35, height: 35)
            layers["Hidden"]![i].center.x = self.frame.size.width / 2
            layers["Hidden"]![i].backgroundColor = UIColor(red: (66 / 255), green: (66 / 255), blue: (244 / 255), alpha: 1)
            layers["Hidden"]![i].layer.cornerRadius = layers["Hidden"]![i].frame.size.height / 2
            layers["Hidden"]![i].layer.borderColor = UIColor.white.cgColor
            layers["Hidden"]![i].layer.borderWidth = 2
            layers["Hidden"]![i].alpha = 0
            self.addSubview(layers["Hidden"]![i])
        }
        
        for i in 0..<layers["Output"]!.count {
            layers["Output"]![i].frame = CGRect(x: Int(self.frame.size.width - 185), y: (35 * i) + (20 * i) + 40, width: 35, height: 35)
            layers["Output"]![i].backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
            layers["Output"]![i].layer.cornerRadius = layers["Output"]![i].frame.size.height / 2
            layers["Output"]![i].layer.borderColor = UIColor.white.cgColor
            layers["Output"]![i].layer.borderWidth = 2
            layers["Output"]![i].alpha = 0
            self.addSubview(layers["Output"]![i])
        }
    }
    
    public func render(shouldLink: Bool) {
        
        for i in 0..<self.layers["Input"]!.count {
            UIView.animate(withDuration: 0.5) {
                self.layers["Input"]![i].isHidden = false
                self.layers["Input"]![i].alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            for i in 0..<self.layers["Hidden"]!.count {
                UIView.animate(withDuration: 0.5) {
                    self.layers["Hidden"]![i].isHidden = false
                    self.layers["Hidden"]![i].alpha = 1
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            for i in 0..<self.layers["Output"]!.count {
                UIView.animate(withDuration: 0.5) {
                    self.layers["Output"]![i].isHidden = false
                    self.layers["Output"]![i].alpha = 1
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if shouldLink {
                self.link()
            }
        }
    }
    
    public func disable(removeLinks: Bool) {
        
        DispatchQueue.main.async {
            if removeLinks {
                self.delink()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for i in 0..<self.layers["Output"]!.count {
                UIView.animate(withDuration: 0.5) {
                    self.layers["Output"]![i].alpha = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for i in 0..<self.layers["Hidden"]!.count {
                UIView.animate(withDuration: 0.5) {
                    self.layers["Hidden"]![i].alpha = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            for i in 0..<self.layers["Input"]!.count {
                UIView.animate(withDuration: 0.5) {
                    self.layers["Input"]![i].alpha = 0
                }
            }
        }
    }
    
    private func link() {
        
        for i in 0..<layers["Input"]!.count {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(i)) {
                for j in 0..<self.layers["Hidden"]!.count {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(j) - 0.75)) {
                        self.drawLineFromPoint(start: self.layers["Input"]![i].center, toPoint: self.layers["Hidden"]![j].center, ofColor: UIColor.white, inView: self)
                    }
                }
            }
        }
        
        for i in 0..<layers["Hidden"]!.count {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(i + 5)) {
                for j in 0..<self.layers["Output"]!.count {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(j) - 0.75), execute: {
                        self.drawLineFromPoint(start: self.layers["Hidden"]![i].center, toPoint: self.layers["Output"]![j].center, ofColor: UIColor.white, inView: self)
                    })
                }
            }
        }
    }
    
    private func delink() {
        self.layer.sublayers?.forEach({ sublayer in sublayer.isHidden = true })
    }
    
    private func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        
        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        self.layer.insertSublayer(shapeLayer, at: 0)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.5
        shapeLayer.add(animation, forKey: "linkAnimation")
    }
}
