//
//  NewContactRequestCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objcMembers open class NewContactRequest: NSObject {
    var userId: String = ""
    var time: TimeInterval = 0
}

@objcMembers open class NewContactRequestCell: UITableViewCell {
    
    public private(set) var request: NewContactRequest = NewContactRequest()
    
    public var agreeClosure: ((String) -> Void)?
    
    lazy var avatar: UIImageView = {
        UIImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)).cornerRadius(Appearance.avatarRadius).image(Appearance.avatarPlaceHolder)
    }()
    
    lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-76, height: 16)).font(UIFont.theme.titleMedium).textColor(UIColor.theme.neutralColor1).isUserInteractionEnabled(false).backgroundColor(.clear).text("Contact".chat.localize)
    }()
    
    lazy var date: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-66, y: self.nickName.frame.minY+2, width: 50, height: 16)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear)
    }()
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-self.avatar.frame.maxX-12-76, height: 16)).font(UIFont.theme.bodyMedium).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear)
    }()
    
    lazy var add: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.contentView.frame.width-76, y: self.nickName.frame.minY+2, width: 72, height: 28)).cornerRadius(.small).title("Add".chat.localize, .normal).textColor(UIColor.theme.neutralColor98, .normal).font(UIFont.theme.labelMedium).addTargetFor(self, action: #selector(addFriend), for: .touchUpInside)
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubViews([self.avatar,self.nickName,self.content,self.add])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.frame = CGRect(x: 16, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)
        self.nickName.frame =  CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX, width: self.contentView.frame.width-self.avatar.frame.maxX-12-76, height: 16)
        self.content.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-self.avatar.frame.maxX-12-76, height: 16)
        self.add.frame = CGRect(x: self.contentView.frame.width-76, y: self.nickName.frame.minY+2, width: 72, height: 28)
    }
    
    @objc public func refresh(request: NewContactRequest) {
        self.request = request
        self.nickName.text = "contactID".chat.localize + ": " + request.userId
        self.content.text = "NewRequestDetail".chat.localize
    }
    
    @objc private func addFriend() {
        self.agreeClosure?(self.request.userId)
    }
}

extension NewContactRequestCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickName.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.content.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.date.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.add.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
    
    
}
