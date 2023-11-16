//
//  MessageBubbleWithArrow.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/9.
//

import UIKit


@objc open class MessageBubbleWithArrow: UIView {
    
    private let bubbleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bubbleLayer.fillColor = UIColor.systemBlue.cgColor
        self.bubbleLayer.strokeColor = UIColor.systemBlue.cgColor
        self.bubbleLayer.lineWidth = 2.0
        self.bubbleLayer.lineJoin = .round
        self.bubbleLayer.lineCap = .round
        self.layer.addSublayer(self.bubbleLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let bubblePath = UIBezierPath()
        
        let cornerRadius: CGFloat = 5
        
        let arrowWidth: CGFloat = 5.0
        let arrowHeight: CGFloat = 5.0
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
    
        bubblePath.move(to: CGPoint(x: cornerRadius, y: 0))
        bubblePath.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        bubblePath.addArc(withCenter: CGPoint(x: width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(3 * Double.pi / 2), endAngle: 0, clockwise: true)
        bubblePath.addLine(to: CGPoint(x: width, y: height - cornerRadius - arrowHeight-5))
        bubblePath.addLine(to: CGPoint(x: width + arrowWidth, y: height - cornerRadius-5))
        bubblePath.addLine(to: CGPoint(x: width, y: height - cornerRadius + arrowHeight-5))
        bubblePath.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        bubblePath.addArc(withCenter: CGPoint(x: width - cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
        bubblePath.addLine(to: CGPoint(x: cornerRadius, y: height))
        bubblePath.addArc(withCenter: CGPoint(x: cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        bubblePath.addLine(to: CGPoint(x: 0, y: cornerRadius))
        bubblePath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
        bubblePath.close()
        
        self.bubbleLayer.path = bubblePath.cgPath
    }
}
