import UIKit

open class ChromaSliderTrackLayer: CALayer{
    public let gradient = CAGradientLayer()
    
    override public init() {
        super.init()
        gradient.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()]
        self.addSublayer(gradient)
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public protocol ChromaShadeSliderDelegate {
    func shadeSliderChoseColor(_ slider: ChromaShadeSlider, color: UIColor)
}

open class ChromaShadeSlider: UIControl {
    open var currentValue: CGFloat = 0.0 //range of {-1,1}
    
    public let trackLayer = ChromaSliderTrackLayer()
    public let handleView = ChromaHandle()
    open var handleWidth: CGFloat{ return self.bounds.height }
    open var handleCenterX: CGFloat = 0.0
    open var delegate: ChromaShadeSliderDelegate?
    
    open var primaryColor = UIColor.gray {
        didSet {
            self.changeColorHue(to: currentColor)
            self.updateGradientTrack(for: primaryColor)
        }
    }
    /* The computed color of the primary color with shading based on the currentValue */
    open var currentColor: UIColor {
        get {
            if currentValue < 0 { //darken
                return primaryColor.darkerColor(-currentValue)
            } else { //lighten
                return primaryColor.lighterColor(currentValue)
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        self.backgroundColor = nil
        handleCenterX = self.bounds.width/2
        
        trackLayer.backgroundColor = UIColor.blue.cgColor
        trackLayer.masksToBounds = true
        trackLayer.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()] //disable implicit animations
        self.layer.addSublayer(trackLayer)
        
        handleView.color = UIColor.blue
        handleView.circleLayer.borderWidth = 3
        handleView.isUserInteractionEnabled = false //disable interaction for touch events
        self.addSubview(handleView)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapRecognized))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
        
        self.layoutLayerFrames()
        self.changeColorHue(to: currentColor)
        self.updateGradientTrack(for: primaryColor)
    }
    
    override open func didMoveToSuperview() {
        self.updateGradientTrack(for: primaryColor)
    }
    
    open func layoutLayerFrames(){
        trackLayer.frame = self.bounds.insetBy(dx: handleWidth/2, dy: self.bounds.height/4) //Make half the height of the bounds
        trackLayer.cornerRadius = trackLayer.bounds.height/2
        
        self.updateGradientTrack(for: primaryColor)
        self.updateHandleLocation()
        self.layoutHandleFrame()
    }
    
    //Lays out handle according to the currentValue on slider
    open func layoutHandleFrame(){
        handleView.frame = CGRect(x: handleCenterX - handleWidth/2, y: self.bounds.height/2 - handleWidth/2, width: handleWidth, height: handleWidth)
    }
    
    open func changeColorHue(to newColor: UIColor){
        handleView.color = newColor
        if currentValue != 0 { //Don't call delegate if the color hasnt changed
            self.delegate?.shadeSliderChoseColor(self, color: newColor)
        }
    }
    
    open func updateGradientTrack(for color: UIColor){
        trackLayer.gradient.frame = trackLayer.bounds
        trackLayer.gradient.startPoint = CGPoint(x: 0, y: 0.5)
        trackLayer.gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        //Gradient is for astetics - the slider is actually between black and white
        trackLayer.gradient.colors = [color.darkerColor(0.65).cgColor, color.cgColor, color.lighterColor(0.65).cgColor]
    }
    
    //Updates handeles location based on currentValue
    open func updateHandleLocation(){
        handleCenterX = (currentValue+1)/2 * (bounds.width - handleView.bounds.width) +  handleView.bounds.width/2
        handleView.color = currentColor
        self.layoutHandleFrame()
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        if handleView.frame.contains(location) {
            return true
        }
        return false
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        //Update for center point
        handleCenterX = location.x
        handleCenterX = fittedValueInBounds(handleCenterX) //adjust value to fit in bounds if needed
        
        
        //Update current value
        currentValue = ((handleCenterX - handleWidth/2)/trackLayer.bounds.width - 0.5) * 2  //find current value between {-1,1} of the slider
        
        //Update handle color
        self.changeColorHue(to: currentColor)
        
        //Update layers frames
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.layoutHandleFrame()
        CATransaction.commit()
        
        self.sendActions(for: .valueChanged)
        return true
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.sendActions(for: .editingDidEnd)
    }
    
  @objc func doubleTapRecognized(_ recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: self)
        guard handleView.frame.contains(location) else {
            return
        }
        //Tap is on handle
        
        resetHandleToCenter()
    }
    
    open func resetHandleToCenter(){
        
        handleCenterX = self.bounds.width/2
        self.layoutHandleFrame()
        handleView.color = primaryColor
        currentValue = 0.0
        
        self.sendActions(for: .valueChanged)
        self.delegate?.shadeSliderChoseColor(self, color: currentColor)
    }
    
    /* Helper Methods */
    //Returns a CGFloat for the highest/lowest possble value such that it is inside the views bounds
    private func fittedValueInBounds(_ value: CGFloat) -> CGFloat {
        return min(max(value, trackLayer.frame.minX), trackLayer.frame.maxX)
    }
    
}

 extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
 }
