//
//  DetailInfoHeaderExtensionCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/22.
//

import UIKit

@objc open class DetailInfoHeaderExtensionCell: UICollectionViewCell {
    
    public private(set) lazy var icon: UIImageView = {
        UIImageView(frame: .zero).backgroundColor(.clear).contentMode(.scaleAspectFit)
    }()
    
    public private(set) lazy var title: UILabel = {
        UILabel(frame: .zero).font(UIFont.theme.bodyExtraSmall).backgroundColor(.clear).textAlignment(.center)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubViews([self.icon,self.title])
        Theme.registerSwitchThemeViews(view: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.cornerRadius(.small)
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        self.icon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: 32).isActive = true
        self.icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.title.topAnchor.constraint(equalTo: self.icon.bottomAnchor,constant: 5).isActive = true
        self.title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.title.widthAnchor.constraint(equalTo: self.widthAnchor,constant: -10).isActive = true
        self.title.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
}

extension DetailInfoHeaderExtensionCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.contentView.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor98
        self.title.textColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
}
