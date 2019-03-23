import UIKit

public class Presentation : UIView {
    
    let currentPage : UILabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        let nextPage = UIButton(frame: CGRect(x: 0, y: self.frame.size.height - 70, width: 50, height: 50))
        nextPage.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        nextPage.center.x = self.frame.size.width / 1.25
        nextPage.layer.cornerRadius = nextPage.frame.size.height / 2
        nextPage.layer.masksToBounds = true
        nextPage.setImage(UIImage(named: "nextPage.png"), for: UIControl.State.normal)
        nextPage.addTarget(self, action: #selector(self.moveToNextPage(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(nextPage)
        
        let previousPage = UIButton(frame: CGRect(x: 0, y: self.frame.size.height - 70, width: 50, height: 50))
        previousPage.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        previousPage.center.x = self.frame.size.width / 4
        previousPage.layer.cornerRadius = previousPage.frame.size.height / 2
        previousPage.layer.masksToBounds = true
        previousPage.setImage(UIImage(named: "backPage.png"), for: UIControl.State.normal)
        previousPage.addTarget(self, action: #selector(self.moveToPreviousPage(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(previousPage)
        
        currentPage.frame = CGRect(x: 0, y: self.frame.size.height - 70, width: 75, height: 50)
        currentPage.text = "1"
        currentPage.textColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        currentPage.textAlignment = NSTextAlignment.center
        currentPage.center.x = self.center.x
        currentPage.font = currentPage.font.withSize(45)
        self.addSubview(currentPage)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setup(presentationImages: [UIImage]) {
        var x_pos : CGFloat = 0
        for presentationImage in presentationImages {
            let presentedImage = UIImageView(frame: self.bounds)
            presentedImage.image = presentationImage
            presentedImage.frame.origin.x = x_pos
            self.insertSubview(presentedImage, at: 0)
            x_pos += presentedImage.frame.size.width
        }
    }
    
    @objc func moveToNextPage(_ sender: UIButton!) {
        if Int(currentPage.text!)! + 1 != 44 {
            currentPage.text = "\(Int(currentPage.text!)! + 1)"
            for i in 0..<self.subviews.count - 3 {
                UIView.animate(withDuration: 0.5) {
                    self.subviews[i].frame.origin.x -= self.subviews[i].frame.size.width
                }
            }
        }
    }
    
    @objc func moveToPreviousPage(_ sender: UIButton!) {
        if Int(currentPage.text!)! - 1 != 0 {
            currentPage.text = "\(Int(currentPage.text!)! - 1)"
            for i in 0..<self.subviews.count - 3 {
                UIView.animate(withDuration: 0.5) {
                    self.subviews[i].frame.origin.x += self.subviews[i].frame.size.width
                }
            }
        }
    }
}
