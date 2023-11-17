
import UIKit

@objc open class ConversationListCell: UITableViewCell {

    lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)).cornerRadius(.large)
    }()
    
    lazy var nickName: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).font(UIFont.theme.titleMedium).textColor(UIColor.theme.neutralColor1, .normal).isUserInteractionEnabled(false).backgroundColor(.clear)
    }()
    
    lazy var date: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-66, y: self.nickName.frame.minY+2, width: 50, height: 16)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear)
    }()
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).font(UIFont.theme.bodyMedium).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear)
    }()
    
    lazy var badge: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-48, y: self.nickName.frame.maxY+5, width: 32, height: 18)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor5).textColor(UIColor.theme.neutralColor98).font(UIFont.theme.bodySmall)
    }()
    
    lazy var dot: UIView = {
        UIView(frame: CGRect(x: self.contentView.frame.width-28, y: self.nickName.frame.maxY+10, width: 8, height: 8)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor5)
    }()
    
    @objc required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubViews([self.avatar,self.nickName,self.date,self.content,self.badge,self.dot])
        self.nickName.contentHorizontalAlignment = .left
        self.nickName.semanticContentAttribute = .forceLeftToRight
        Theme.registerSwitchThemeViews(view: self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.frame = CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)
        self.nickName.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)
        self.date.frame = CGRect(x: self.contentView.frame.width-66, y: self.nickName.frame.minY+2, width: 50, height: 16)
        self.content.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)
        self.badge.frame = CGRect(x: self.contentView.frame.width-48, y: self.nickName.frame.maxY+5, width: 32, height: 18)
        self.dot.frame =  CGRect(x: self.contentView.frame.width-28, y: self.nickName.frame.maxY+10, width: 8, height: 8)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh(info: ConversationInfo) {
        self.avatar.image(with: info.avatarURL, placeHolder: info.type == .chat ? Appearance.Conversation.singlePlaceHolder:Appearance.Conversation.groupPlaceHolder)
        self.nickName.setTitle(info.nickName.isEmpty ? info.id:info.nickName, for: .normal)
        self.date.text = info.lastMessage?.showDate ?? Date().chat.dateString(Appearance.Conversation.dateFormat)
        self.badge.isHidden = info.noDisturb
        self.badge.text = info.unreadCount > 99 ? "99+":"\(info.unreadCount)"
        self.badge.isHidden = info.unreadCount <= 0
        if info.noDisturb {
            self.dot.isHidden = info.unreadCount <= 0
        } else {
            self.dot.isHidden = true
        }
    }
}

extension ConversationListCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickName.setTitleColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1, for: .normal)
        self.content.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.date.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.badge.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.dot.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
    
    
}

@objcMembers open class ConversationInfo:NSObject, EaseProfileProtocol {
    
    public var id: String = ""
    
    public var avatarURL: String = ""
    
    public var nickName: String = ""
    
    public var lastMessage: ChatMessage? = ChatMessage()
    
    public var unreadCount: Int = 0
    
    public var noDisturb = false
    
    public var type = ChatConversationType.chat
    
    public var pinned = false
    
    required public override init() {
        
    }
    
}


extension ChatMessage {
    
    var showDate: String {
        let messageDate = Date(timeIntervalSince1970: TimeInterval(self.timestamp/1000))
        if Appearance.Conversation.dateFormat.isEmpty {
            if messageDate.chat.compareDays() < 0 {
                return messageDate.chat.dateString("MM dd")
            } else {
                return messageDate.chat.dateString("HH:mm")
            }
        } else {
            return messageDate.chat.dateString(Appearance.Conversation.dateFormat)
        }
    }
}
