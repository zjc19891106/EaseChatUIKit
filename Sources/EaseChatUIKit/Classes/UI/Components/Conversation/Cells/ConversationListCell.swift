
import UIKit

@objc open class ConversationListCell: UITableViewCell {

    lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50))
    }()
    
    lazy var nickName: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).isUserInteractionEnabled(false).backgroundColor(.clear)
    }()
    
    lazy var date: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-66, y: self.nickName.frame.minY+2, width: 50, height: 16)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear)
    }()
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).backgroundColor(.clear)
    }()
    
    lazy var badge: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-48, y: self.nickName.frame.maxY+5, width: 32, height: 18)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor5).textColor(UIColor.theme.neutralColor98).font(UIFont.theme.bodySmall).textAlignment(.center)
    }()
    
    lazy var dot: UIView = {
        UIView(frame: CGRect(x: self.contentView.frame.width-28, y: self.nickName.frame.maxY+10, width: 8, height: 8)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor5)
    }()
    
    @objc required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
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
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.avatar.image(with: info.avatarURL, placeHolder: info.type == .chat ? Appearance.conversation.singlePlaceHolder:Appearance.conversation.groupPlaceHolder)
        let name = info.nickName.isEmpty ? info.id:info.nickName
        let nameAttribute = NSMutableAttributedString {
            AttributedText(name).font(UIFont.theme.titleMedium).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
            
        }
        let image = UIImage(named: "bell_slash", in: .chatBundle, with: nil)
        if Theme.style == .dark {
            image?.withTintColor(UIColor.theme.neutralColor5)
        }
        if info.doNotDisturb {
            nameAttribute.append(NSAttributedString {
                ImageAttachment(image, bounds: CGRect(x: 0, y: -4, width: 18, height: 18))
            })
        }
        self.nickName.setAttributedTitle(nameAttribute, for: .normal)
        self.content.attributedText = info.showContent
        self.date.text = info.lastMessage?.showDate ?? Date().chat.dateString(Appearance.conversation.dateFormatToday)
        self.badge.isHidden = info.doNotDisturb
        self.badge.text = info.unreadCount > 99 ? "99+":"\(info.unreadCount)"
        self.badge.isHidden = info.unreadCount <= 0
        if info.doNotDisturb {
            self.dot.isHidden = info.unreadCount <= 0
        } else {
            self.dot.isHidden = true
        }
    }
    
   
}

extension ConversationListCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickName.setTitleColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1, for: .normal)
//        self.content.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.date.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.badge.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.dot.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
    
    
}

@objcMembers open class ConversationInfo:NSObject, EaseProfileProtocol {
    public func toJsonObject() -> Dictionary<String, Any>? {
        [:]
    }
    
    
    public var selected: Bool = false
    
    public var type: EaseProfileProviderType = .chat
    
    public var id: String = ""
    
    public var avatarURL: String = ""
    
    public var nickName: String = ""
    
    public var lastMessage: ChatMessage? = ChatMessage()
    
    public var unreadCount: Int = 0
    
    public var doNotDisturb = false
    
    public var pinned = false
    
    public var mentioned: Bool {
        get {
            let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self.id)
            if conversation?.ext == nil {
                let mention = !(conversation?.lastReceivedMessage()?.mention ?? "").isEmpty
                conversation?.ext = ["EaseChatUIKit_mention":mention]
                return mention
            }
            return (conversation?.ext["EaseChatUIKit_mention"] as? Bool) ?? false
        }
        set {
            let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self.id)
            var ext = conversation?.ext ?? [:]
            if ext.isEmpty {
                ext["EaseChatUIKit_mention"] = newValue
                conversation?.ext = ext
            } else {
                conversation?.ext["EaseChatUIKit_mention"] = newValue
            }
        }
    }
    
    public lazy var showContent: NSAttributedString = {
        guard let message = self.lastMessage else { return NSAttributedString() }
        if message.body.type == .text {
            guard let content = self.convertMessage(message: message).content else { return NSAttributedString() }
            if self.mentioned {
                let from = self.lastMessage?.from ?? ""
                let text = "Mentioned".chat.localize
                let showText = NSMutableAttributedString {
                    AttributedText("[\(text)] ").foregroundColor(Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).font(Font.theme.bodyMedium)
                    AttributedText((message.user?.nickName ?? from) + ": ").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
                }
                let show = NSMutableAttributedString(attributedString: content)
                show.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSRange(location: 0, length: show.length))
                show.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: show.length))
                showText.append(show)
                return showText
            } else {
                let from = self.lastMessage?.from ?? ""
                let showText = NSMutableAttributedString {
                    AttributedText((message.user?.nickName ?? from) + ": ").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
                }
                showText.append(content)
                showText.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor6, range: NSRange(location: 0, length: showText.length))
                showText.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: showText.length))
                return showText
            }
        } else {
            let from = self.lastMessage?.from ?? ""
            let showText = NSMutableAttributedString {
                AttributedText((message.user?.nickName ?? from) + ": ").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
                AttributedText((message.showType)).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
            }
            showText.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: showText.length))
            return showText
        }
    }()
    
    private func convertMessage(message: ChatMessage) -> MessageEntity {
        let entity = MessageEntity()
        entity.state = self.convertStatus(message: message)
        entity.message = message
        _ = entity.content
        _ = entity.replyTitle
        _ = entity.replyContent
        _ = entity.bubbleSize
        _ = entity.height
        _ = entity.replySize
        return entity
    }
    
    private func convertStatus(message: ChatMessage) -> ChatMessageStatus {
        switch message.status {
        case .succeed:
            return .succeed
        case .pending:
            return .sending
        case .delivering:
            return .delivered
        default:
            if message.isReadAcked {
                return .read
            }
            return .failure
        }
    }
    
    required public override init() {
        
    }
    
}
