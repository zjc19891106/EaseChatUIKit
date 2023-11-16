//
//  EmptyView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/18.
//

import UIKit

@objc open class EmptyStateView: UIView {
    
    lazy var imageContainer: UIImageView = {
        UIImageView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Init a empty state view.
    /// - Parameters:
    ///   - frame: CGRect
    ///   - emptyImage: UIImage?
    @objc public required convenience init(frame: CGRect,emptyImage: UIImage?) {
        self.init(frame: frame)
        self.setupView()
        self.imageContainer.image = emptyImage
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(self.imageContainer)
        self.imageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.imageContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.imageContainer.widthAnchor.constraint(equalToConstant: 107).isActive = true
        self.imageContainer.heightAnchor.constraint(equalToConstant: 107).isActive = true
    }
    
}
