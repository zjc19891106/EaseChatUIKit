//
//  GroupListCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objcMembers open class GroupListCell: UITableViewCell {

    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)).cornerRadius(.large).backgroundColor(.clear)
    }()
    
    public private(set) lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).backgroundColor(.clear)
    }()

    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.nickName])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.center = CGPoint(x: self.avatar.center.x, y: self.contentView.center.y)
        self.nickName.center = CGPoint(x: self.nickName.center.x, y: self.contentView.center.y)
    }
    
    func refresh(info: ChatGroup,keyword: String) {
        let nickName = info.groupName.isEmpty ? info.groupId:info.groupName
        self.nickName.attributedText = self.highlightKeywords(keyword: keyword, in: nickName ?? "")
        self.avatar.image(with: "", placeHolder: Appearance.Conversation.groupPlaceHolder)
    }
    
    func highlightKeywords(keyword: String, in string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString {
            AttributedText(string).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        }
        if !keyword.isEmpty {
            var range = (string as NSString).range(of: keyword, options: .caseInsensitive)
            while range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, range: range)
                let remainingRange = NSRange(location: range.location + range.length, length: string.count - (range.location + range.length))
                range = (string as NSString).range(of: keyword, options: .caseInsensitive, range: remainingRange)
            }
        }
        return attributedString
    }

}
