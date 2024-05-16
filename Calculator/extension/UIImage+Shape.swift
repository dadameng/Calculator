import UIKit

extension UIImage {
    static func drawThickArrow(direction: String, size: CGSize = CGSize(width: 50, height: 50), lineWidth: CGFloat = 10, color: UIColor = .white) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        let path = UIBezierPath()

        let shaftWidth: CGFloat = size.width / 3

        if direction == "left" {
            // Draw the shaft (rectangle)
            path.move(to: CGPoint(x: size.width, y: (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: shaftWidth, y: (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: shaftWidth, y: (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: shaftWidth, y: 0))
            path.addLine(to: CGPoint(x: 0, y: size.height / 2))
            path.addLine(to: CGPoint(x: shaftWidth, y: size.height))
            path.addLine(to: CGPoint(x: shaftWidth, y: size.height - (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: size.width, y: size.height - (size.height - shaftWidth) / 2))
            path.close()
        } else if direction == "right" {
            // Draw the shaft (rectangle)
            path.move(to: CGPoint(x: 0, y: (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: size.width - shaftWidth, y: (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: size.width - shaftWidth, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width - shaftWidth, y: size.height))
            path.addLine(to: CGPoint(x: size.width - shaftWidth, y: size.height - (size.height - shaftWidth) / 2))
            path.addLine(to: CGPoint(x: 0, y: size.height - (size.height - shaftWidth) / 2))
            path.close()
        }

        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
}
