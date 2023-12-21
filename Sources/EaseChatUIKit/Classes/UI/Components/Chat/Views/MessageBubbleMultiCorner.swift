//
//  MessageMultiCornerBubble.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/9.
//

import UIKit

@objc public class BubbleCornerRadius: NSObject {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
}

@objc open class MessageBubbleMultiCorner: UIView {
    
    public var towards = BubbleTowards.right
    
    private var shapeLayer = CAShapeLayer()
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc required public init(frame: CGRect, forward: BubbleTowards) {
        super.init(frame: frame)
        self.towards = forward
        self.draw(frame)
        self.layer.addSublayer(self.shapeLayer)
        self.layer.mask = self.shapeLayer
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.fillColor = (self.towards == .left ? Appearance.chat.receiveBubbleColor:Appearance.chat.sendBubbleColor).cgColor
        self.shapeLayer.strokeColor = (self.towards == .left ? Appearance.chat.receiveBubbleColor:Appearance.chat.sendBubbleColor).cgColor
        let path = self.roundedRect(bounds: self.bounds)
        self.shapeLayer.path = path
        self.shapeLayer.shouldRasterize = true
    }
    
    func roundedRect(bounds: CGRect) -> CGPath {
        let cornerRadius = self.towards == .left ? BubbleCornerRadius(topLeft: 12, topRight: 16, bottomLeft: 4, bottomRight: 16):BubbleCornerRadius(topLeft: 16, topRight: 12, bottomLeft: 4, bottomRight: 16)
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        let topLeftCenterX = minX + cornerRadius.topLeft
        let topLeftCenterY = minY + cornerRadius.topLeft

        let bottomLeftCenterX = minX + cornerRadius.bottomLeft
        let bottomLeftCenterY = maxY - cornerRadius.bottomLeft

        let bottomRightCenterX = maxX - cornerRadius.bottomRight
        let bottomRightCenterY = maxY - cornerRadius.bottomRight

        let topRightCenterX = maxX - cornerRadius.topRight
        let topRightCenterY = minY + cornerRadius.topRight

        let path = CGMutablePath()

        //顶 左
        path.addArc(center: CGPoint(x: topLeftCenterX, y: topLeftCenterY), radius: cornerRadius.topLeft, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 3 / 2), clockwise: false)
        //顶 右
        path.addArc(center: CGPoint(x: topRightCenterX, y: topRightCenterY), radius: cornerRadius.topRight, startAngle: CGFloat(Double.pi * 3 / 2), endAngle: 0, clockwise: false)
        //底 右
        path.addArc(center: CGPoint(x: bottomRightCenterX, y: bottomRightCenterY), radius: cornerRadius.bottomRight, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: false)
        //底 左
        path.addArc(center: CGPoint(x: bottomLeftCenterX, y: bottomLeftCenterY), radius: cornerRadius.bottomLeft, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: false)
        path.closeSubpath()

        return path
    }

}
