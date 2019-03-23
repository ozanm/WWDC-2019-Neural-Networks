import UIKit

public class MaskedLabel {
    public init() {}
    
    public func maskedImage(size: CGSize, text: String) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        
        // draw the text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.white
        ]
        if text.components(separatedBy: " ").first != text.components(separatedBy: " ").last {
            var textSize = "\(text.components(separatedBy: " ").first!) ".size(withAttributes: attributes)
            var point = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
            text.components(separatedBy: " ").first!.draw(at: point, withAttributes: attributes)
            point = CGPoint(x: ((size.width - textSize.width) / 2) - 25, y: size.height - textSize.height)
            textSize = text.components(separatedBy: " ").last!.size(withAttributes: attributes)
            text.components(separatedBy: " ").last!.draw(at: point, withAttributes: attributes)
        } else {
            var textSize = text.size(withAttributes: attributes)
            var point = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
            text.draw(at: point, withAttributes: attributes)
        }
        
        // capture the image and end context
        
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // create image mask
        
        guard let cgimage = maskImage?.cgImage, let dataProvider = cgimage.dataProvider else { return nil }
        
        let bytesPerRow = cgimage.bytesPerRow
        let bitsPerPixel = cgimage.bitsPerPixel
        let width = cgimage.width
        let height = cgimage.height
        let bitsPerComponent = cgimage.bitsPerComponent
        
        guard let mask = CGImage(maskWidth: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, provider: dataProvider, decode: nil, shouldInterpolate: false) else { return nil }
        
        // create the actual image
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIGraphicsGetCurrentContext()?.clip(to: rect, mask: mask)
        UIColor.white.withAlphaComponent(0.9).setFill()
        UIBezierPath(rect: rect).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // return image
        
        return image
    }
}
