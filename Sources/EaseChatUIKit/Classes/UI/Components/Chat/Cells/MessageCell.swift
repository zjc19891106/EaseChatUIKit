import UIKit
import Combine

@objc public enum MessageCellStyle: UInt {
    case text
    case image
    case video
    case location
    case voice
    case file
    case cmd
    case contact
    case alert
    case combine
}

@objc public enum MessageCellClickArea: UInt {
    case avatar
    case reply
    case bubble
    case status
}

let message_bubble_space = CGFloat(5)

@objcMembers open class MessageCell: UITableViewCell {
    private var longGestureEnabled: Bool = true
    
    public private(set) var entity = MessageEntity()
    
    public private(set) var towards = BubbleTowards.left
    
    public var clickAction: ((MessageCellClickArea,MessageEntity) -> Void)?
    
    public var longPressAction: ((MessageCellClickArea,MessageEntity) -> Void)?
    
    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: .zero).contentMode(.scaleAspectFit).backgroundColor(.clear).tag(900)
    }()
    
    public private(set) lazy var nickName: UILabel = {
        UILabel(frame: .zero).backgroundColor(.clear).font(UIFont.theme.labelSmall)
    }()
    
    public private(set) lazy var replyContent: MessageReplyView = {
        MessageReplyView(frame: .zero).backgroundColor(.clear).tag(199)
    }()
    
    public private(set) lazy var bubbleWithArrow: MessageBubbleWithArrow = {
        MessageBubbleWithArrow(frame: .zero, forward: self.towards).tag(200)
    }()
    
    public private(set) lazy var bubbleMultiCorners: MessageBubbleMultiCorner = {
        MessageBubbleMultiCorner(frame: .zero, forward: self.towards).tag(200)
    }()
    
    public private(set) lazy var status: UIImageView = {
        UIImageView(frame: .zero).backgroundColor(.clear).tag(168)
    }()
    
    public private(set) lazy var messageDate: UILabel = {
        UILabel(frame: .zero).font(UIFont.theme.bodySmall).backgroundColor(.clear)
    }()
    
    @objc public enum ContentDisplayStyle: UInt {
        case withReply = 1
        case withAvatar = 2
        case withNickName = 4
        case withDateAndTime = 8
    }
        
    @objc public enum BubbleDisplayStyle: UInt {
        case withArrow
        case withMultiCorner
    }
    
    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.towards = towards
        if Appearance.chat.contentStyle.contains(.withNickName) {
            self.contentView.addSubview(self.nickName)
        }
        if Appearance.chat.contentStyle.contains(.withReply) {
            self.contentView.addSubview(self.replyContent)
            self.addGestureTo(view: self.replyContent, target: self)
        }
        if Appearance.chat.contentStyle.contains(.withAvatar) {
            self.contentView.addSubview(self.avatar)
            self.addGestureTo(view: self.avatar, target: self)
            self.longPressGestureTo(view: self.bubbleWithArrow, target: self)
        }
        if Appearance.chat.bubbleStyle == .withArrow {
            self.contentView.addSubview(self.bubbleWithArrow)
            self.longPressGestureTo(view: self.bubbleWithArrow, target: self)
        } else {
            self.contentView.addSubview(self.bubbleMultiCorners)
            self.longPressGestureTo(view: self.bubbleMultiCorners, target: self)
        }
        if Appearance.chat.contentStyle.contains(.withDateAndTime) {
            self.contentView.addSubview(self.messageDate)
        }
        self.contentView.addSubview(self.status)
        self.addGestureTo(view: self.status, target: self)
        Theme.registerSwitchThemeViews(view: self)
        self.replyContent.isHidden = true
        self.switchTheme(style: Theme.style)
    }
    
    @objc public func addGestureTo(view: UIView,target: Any?) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: target, action: #selector(clickAction(gesture:))))
    }
    
    @objc public func longPressGestureTo(view: UIView,target: Any?) {
        view.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: target, action: #selector(longPressAction(gesture:)))
        view.addGestureRecognizer(longPress)
    }
    
    @objc func clickAction(gesture: UITapGestureRecognizer) {
        if let tag = gesture.view?.tag {
            switch tag {
            case 168:
                self.clickAction?(.status,self.entity)
            case 199:
                self.clickAction?(.reply,self.entity)
            case 200:
                self.clickAction?(.bubble,self.entity)
            case 900:
                self.clickAction?(.avatar,self.entity)
            default:
                break
            }
        }
    }
    
    @objc func longPressAction(gesture: UILongPressGestureRecognizer) {
        if let tag = gesture.view?.tag {
            if self.longGestureEnabled {
                self.longGestureEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.longGestureEnabled = true
                }
                switch tag {
                case 200:
                    self.longPressAction?(.bubble,self.entity)
                case 900:
                    self.longPressAction?(.avatar,self.entity)
                default:
                    break
                }
            }
        }
    }
    
    private func addRotation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 999
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        self.status.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
        
    @objc public func refresh(entity: MessageEntity) {
        self.towards = entity.message.direction == .send ? .right:.left
        self.entity = entity
        self.updateAxis(entity: entity)
        self.status.image = entity.stateImage
        if entity.state == .sending {
            self.addRotation()
        } else {
            self.status.layer.removeAllAnimations()
        }
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.avatar.image = Appearance.avatarPlaceHolder
        if let user = entity.message.user {
            if !user.avatarURL.isEmpty {
                self.avatar.image(with: user.avatarURL, placeHolder: Appearance.avatarPlaceHolder)
            } else {
                self.avatar.image = Appearance.avatarPlaceHolder
            }
            let nickName = user.nickName.isEmpty ? user.id:user.nickName
            self.nickName.text = nickName
        }
        self.nickName.text = entity.message.from
        let date = entity.message.showDetailDate
        self.messageDate.text = date
        self.replyContent.isHidden = entity.replyContent == nil
        self.replyContent.isHidden = entity.replySize.height <= 0
        if entity.replySize.height > 0 {
            self.replyContent.refresh(entity: entity)
        }
    }
    
    @objc public func updateAxis(entity: MessageEntity) {
        self.bubbleWithArrow.towards = (entity.message.direction == .receive ? .left:.right)
        self.bubbleMultiCorners.towards = (entity.message.direction == .receive ? .left:.right)
        if entity.message.direction == .receive {
            self.avatar.frame = CGRect(x: 12, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 28, width: 28, height: 28)
            self.nickName.frame = CGRect(x:  Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:12, y: 10, width: entity.bubbleSize.width, height: 16)
            self.messageDate.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:12, y: entity.height-16, width: 120, height: 16)
            self.messageDate.textAlignment = .left
            self.nickName.textAlignment = .left
            if Appearance.chat.contentStyle.contains(.withReply) {
                self.replyContent.frame = CGRect(x:  Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:12, y: Appearance.chat.contentStyle.contains(where: { $0 == .withNickName }) ? self.nickName.frame.maxY:12, width: entity.replySize.width, height: entity.replySize.height)
            }
            if Appearance.chat.bubbleStyle == .withArrow {
                self.bubbleWithArrow.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:12, y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height, width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
                self.bubbleWithArrow.draw(self.bubbleWithArrow.frame)
            } else {
                self.bubbleMultiCorners.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:12, y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height, width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
                self.bubbleMultiCorners.setNeedsDisplay()
            }
            self.status.isHidden = true
            self.status.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+entity.bubbleSize.width+4:12+entity.bubbleSize.width+4, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 20, width: 20, height: 20)
        } else {
            self.status.isHidden = false
            self.avatar.frame = CGRect(x: ScreenWidth-40, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 28, width: 28, height: 28)
            self.nickName.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-12:ScreenWidth-entity.bubbleSize.width-12, y: 10, width: entity.bubbleSize.width, height: 16)
            self.messageDate.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? (self.avatar.frame.minX-12-120):(ScreenWidth-132), y: entity.height-16, width: 120, height: 16)
            self.messageDate.textAlignment = .right
            self.nickName.textAlignment = .right
            if Appearance.chat.contentStyle.contains(.withReply) {
                self.replyContent.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.replySize.width-12:ScreenWidth-12-entity.replySize.width, y: Appearance.chat.contentStyle.contains(where: { $0 == .withNickName }) ? self.nickName.frame.maxY:12, width: entity.replySize.width, height: entity.replySize.height)
            }
            if Appearance.chat.bubbleStyle == .withArrow {
                self.bubbleWithArrow.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-12:ScreenWidth-entity.bubbleSize.width-12, y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height, width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
                self.bubbleWithArrow.draw(self.bubbleWithArrow.frame)
            } else {
                self.bubbleMultiCorners.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-12:ScreenWidth-entity.bubbleSize.width-12, y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height, width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
                self.bubbleMultiCorners.setNeedsDisplay()
            }
            self.status.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-12-20-4:ScreenWidth-entity.bubbleSize.width-12-20-4, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 20, width: 20, height: 20)
            self.replyContent.cornerRadius(Appearance.chat.imageMessageCorner)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MessageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.replyContent.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.nickName.textColor = style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5
        self.messageDate.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor7
    }
}


