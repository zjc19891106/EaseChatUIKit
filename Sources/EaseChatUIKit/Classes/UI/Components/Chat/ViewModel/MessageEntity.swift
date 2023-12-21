//
//  MessageEntity.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/12/8.
//

import UIKit

fileprivate var audioHeight = CGFloat(36)
fileprivate var fileHeight = CGFloat(60)
fileprivate var contactCardHeight = CGFloat(90)
fileprivate var alertHeight = CGFloat(30)
fileprivate let limitBubbleWidth = CGFloat(ScreenWidth*(3/5.0))
fileprivate let limitImageHeight = CGFloat((300/844)*ScreenHeight)

fileprivate let limitImageWidth = CGFloat((225/390)*ScreenWidth)

@objcMembers open class MessageEntity: NSObject {
    
    var message: ChatMessage = ChatMessage()
        
    var state: ChatMessageStatus = .sending
    
    var playing = false
    
    var stateImage: UIImage? {
        switch self.state {
        case .sending: 
            return UIImage(named: "message_status_spinner", in: .chatBundle, with: nil)
        case .succeed: 
            return UIImage(named: "message_status_succeed", in: .chatBundle, with: nil)
        case .failure: 
            return UIImage(named: "message_status_failure", in: .chatBundle, with: nil)
        case .delivered:
            return UIImage(named: "message_status_delivery", in: .chatBundle, with: nil)
        case .read:
            return UIImage(named: "message_status_read", in: .chatBundle, with: nil)
        case .edited:
            return nil
        }
    }
    
    public private(set) lazy var replySize: CGSize = {
        self.updateReplySize()
    }()
    
    public private(set) lazy var bubbleSize: CGSize = {
        self.updateBubbleSize()
    }()
    
    public private(set) lazy var height: CGFloat = {
        if let body = self.message.body as? ChatCustomMessageBody,body.event == EaseChatUIKit_alert_message {
            return self.bubbleSize.height
        } else {
            return 8+(Appearance.chat.contentStyle.contains(.withNickName) ? 28:2)+(Appearance.chat.contentStyle.contains(.withReply) ? self.replySize.height:2)+self.bubbleSize.height+(Appearance.chat.contentStyle.contains(.withDateAndTime) ? 24:8)
        }
    }()
    
    public private(set) lazy var content: NSAttributedString? = {
        self.convertTextAttribute()
    }()
    
    public private(set) lazy var replyTitle: NSAttributedString? = {
        if let quoteMessage = self.message.quoteMessage {
            return NSAttributedString {
                AttributedText(quoteMessage.user?.nickName ?? quoteMessage.from).font(Font.theme.labelSmall).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5)
            }
        } else { return nil }
    }()
    
    public private(set) lazy var replyContent: NSAttributedString? = {
        self.convertToReply()
    }()
            
    func updateBubbleSize() -> CGSize {
        switch self.message.body.type {
        case .text: return self.textSize()
        case .image: return self.thumbnailSize(video: false)
        case .voice: return self.audioSize()
        case .video: return self.thumbnailSize(video: true)
        case .file:  return CGSize(width: ScreenWidth*(3/5.0), height: fileHeight)
        case .location: return CGSize(width: ScreenWidth*(3/5.0), height: fileHeight)
        case .combine: return CGSize(width: ScreenWidth*(3/5.0), height: fileHeight)
        case .custom: return self.customSize()
        default:
            return .zero
        }
    }
    
    private func textSize() -> CGSize {
        let label = UILabel().numberOfLines(0).lineBreakMode(LanguageConvertor.chineseLanguage() ? .byCharWrapping:.byWordWrapping)
        label.attributedText = self.convertTextAttribute()
        let size = label.sizeThatFits(CGSize(width: ScreenWidth*(3/5.0)-24, height: 9999)) 
        return CGSize(width: size.width+24, height: size.height+14+(self.message.edited ? 19:0))
    }
    
    private func thumbnailSize(video: Bool) -> CGSize {
        let defaultSize = CGSize(width: 135, height: 135)
        var size = CGSize.zero
        if let body = self.message.body as? ChatImageMessageBody {
            size = body.size
        }
        if let body = self.message.body as? ChatVideoMessageBody {
            size = body.thumbnailSize
        }
        if size == .zero {
            if let body = self.message.body as? ChatImageMessageBody {
                size = body.size
            }
            if let body = self.message.body as? ChatVideoMessageBody {
                size = body.thumbnailSize
            }
            
            if size == .zero {
                if let path = (self.message.body as? ChatFileMessageBody)?.localPath {
                    size = UIImage(contentsOfFile: path)?.size ?? defaultSize
                } else {
                    size = defaultSize
                }
            }
        }
        let scale = size.width/size.height
        switch scale {
        case 0...0.1:
            return CGSize(width: limitImageHeight/10.0, height: limitImageHeight)
        case 0.1...0.75:
            return CGSize(width: limitImageHeight*(size.width/size.height), height: limitImageHeight)
        case 0.7501...10:
            return CGSize(width: limitImageWidth, height: limitImageWidth*(size.height/size.width))
        case 10...:
            return CGSize(width: limitImageWidth, height: limitImageWidth/10.0)
        default:
            return .zero
        }
    }
    
    private func audioSize() -> CGSize {
        switch Int((self.message.body as? ChatAudioMessageBody)?.duration ?? 1) {
        case 0...9:
            return CGSize(width: 75, height: audioHeight)
        case 10...19:
            return CGSize(width: 100, height: audioHeight)
        case 20...29:
            return CGSize(width: 125, height: audioHeight)
        case 30...39:
            return CGSize(width: 150, height: audioHeight)
        case 40...49:
            return CGSize(width: 175, height: audioHeight)
        case 50...Appearance.chat.audioDuration:
            return CGSize(width: ScreenWidth*(3/5.0), height: audioHeight)
        default:
            return .zero
        }
    }
    
    private func customSize() -> CGSize {
        if let body = self.message.body as? ChatCustomMessageBody {
            if body.event == EaseChatUIKit_user_card_message {
                return CGSize(width: ScreenWidth*(3/5.0), height: contactCardHeight)
            } else {
                if body.event == EaseChatUIKit_alert_message {
                    let label = UILabel().numberOfLines(0).lineBreakMode(LanguageConvertor.chineseLanguage() ? .byCharWrapping:.byWordWrapping)
                    label.attributedText = self.convertTextAttribute()
                    let size = label.sizeThatFits(CGSize(width: ScreenWidth, height: 9999))
                    return CGSize(width: ScreenWidth-32, height: size.height+50)
                } else {
                    return .zero
                }
            }
        } else {
            return .zero
        }
    }
    
    /// Converts the message text into an attributed string, including the user's nickname, message text, and emojis.
    func convertTextAttribute() -> NSAttributedString? {
        if self.message.body.type != .text, self.message.body.type != .custom {
            return nil
        }
        var text = NSMutableAttributedString()
        if self.message.body.type == .custom,let body = self.message.body as? ChatCustomMessageBody {
            switch body.event {
            case EaseChatUIKit_alert_message:
                text.append(NSMutableAttributedString {
                    AttributedText(self.message.user?.nickName ?? self.message.from).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.labelSmall)
                })
                if let something = self.message.ext?["something"] as? String {
                    text.append(NSAttributedString {
                        AttributedText(" "+something).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.bodySmall)
                    })
                }
            default:
                break
            }
            
        } else {
            if self.message.mention.isEmpty {
                text.append(NSAttributedString {
                    AttributedText(self.message.showType).foregroundColor(self.message.direction == .send ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor).font(UIFont.theme.bodyLarge)
                })
            } else {
                let content = self.message.showType
                let mentionRange = content.lowercased().chat.rangeOfString(self.message.mention.lowercased())
                let range = NSMakeRange(mentionRange.location-1, mentionRange.length+1)
                let mentionAttribute = NSMutableAttributedString {
                    AttributedText(content).foregroundColor(self.message.direction == .send ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor).font(UIFont.theme.bodyLarge)
                }
                mentionAttribute.addAttribute(.foregroundColor, value: (Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5), range: range)
                text.append(mentionAttribute)
            }
            let string = text.string as NSString
            for symbol in ChatEmojiConvertor.shared.emojis {
                if string.range(of: symbol).location != NSNotFound {
                    let ranges = text.string.chat.rangesOfString(symbol)
                    text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol)
                    text.addAttribute(.font, value: UIFont.theme.bodyLarge, range: NSMakeRange(0, text.length))
                    text.addAttribute(.foregroundColor, value: self.message.direction == .send ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor, range: NSMakeRange(0, text.length))
                }
            }
        }
        return text
    }
    
    func updateReplySize() -> CGSize {
        if let attributeContent = self.convertToReply(),let attributeTitle = self.replyTitle,attributeContent.length > 0 {
            let label = UILabel().numberOfLines(2).lineBreakMode(LanguageConvertor.chineseLanguage() ? .byCharWrapping:.byWordWrapping)
            label.attributedText = attributeTitle.length > attributeContent.length ? attributeTitle:attributeContent
            if self.message.quoteMessage!.body.type == .image || self.message.quoteMessage!.body.type == .video {
                let size = label.sizeThatFits(CGSize(width: limitBubbleWidth, height: 36))
                return CGSize(width: size.width+78, height: 36+16)
            } else {
                let size = label.sizeThatFits(CGSize(width: limitBubbleWidth, height: 36))
                return CGSize(width: size.width+24, height: size.height+34)
            }
        }
        return .zero
    }
        
    func convertToReply() -> NSAttributedString? {
        if let quoteMessage = self.message.quoteMessage {
            if let msgSender = self.message.quoteMessage?.from,!msgSender.isEmpty  {
//                let showName = quoteMessage.user?.nickName ?? msgSender
                let reply = NSMutableAttributedString()
                if let icon = quoteMessage.replyIcon?.withTintColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5) {
                    reply.append(NSAttributedString {
                        ImageAttachment(icon, bounds: CGRect(x: 0, y: -3.5, width: 18, height: 18))
                    })
                }
                switch quoteMessage.body.type {
                case .text:
                    reply.append(NSAttributedString {
                        AttributedText(quoteMessage.showType).font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                    })
                case .image,.video,.combine,.location:
                    reply.append(NSAttributedString {
                        AttributedText(quoteMessage.showType).font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                    })
                case .file,.voice:
                    reply.append(NSAttributedString {
                        AttributedText(quoteMessage.showType).font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                        AttributedText(quoteMessage.showContent).font(Font.theme.bodyMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                    })
                case .custom:
                    if let body = quoteMessage.body as? ChatCustomMessageBody,body.event == EaseChatUIKit_user_card_message {
                        reply.append(NSAttributedString {
                            AttributedText(quoteMessage.showType).font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                            AttributedText(quoteMessage.showContent).font(Font.theme.bodyMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                        })
                    }
                default:
                    reply.append(NSAttributedString {
                        AttributedText(quoteMessage.showType).font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                    })
                }
                return reply
            } else {
                return NSAttributedString {
                    AttributedText("message doesn't exist".chat.localize).font(Font.theme.bodyMedium).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                }
            }
        }
        return nil
    }
}


extension ChatMessage {
    
    /// ``EaseProfileProtocol``
    var user: EaseProfileProtocol? {
        EaseChatUIKitContext.shared?.chatCache?[self.from]
    }
    
    var edited: Bool {
        if self.body.type != .text {
            return false
        } else {
            if let body = self.body as? ChatTextMessageBody {
                if body.operatorCount > 0,body.operationTime > 0 {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
    }
    
    var showDate: String {
        let messageDate = Date(timeIntervalSince1970: TimeInterval(self.timestamp/1000))
        if messageDate.chat.compareDays() < 0 {
            return messageDate.chat.dateString(Appearance.conversation.dateFormatOtherDay)
        } else {
            return messageDate.chat.dateString(Appearance.conversation.dateFormatToday)
        }
    }
    
    var showDetailDate: String {
        let messageDate = Date(timeIntervalSince1970: TimeInterval(self.timestamp/1000))
        if messageDate.chat.compareDays() < 0 {
            return messageDate.chat.dateString(Appearance.chat.dateFormatOtherDay)
        } else {
            return messageDate.chat.dateString(Appearance.chat.dateFormatToday)
        }
    }
    
    var showType: String {
        var text = "[unknown]"
        switch self.body.type {
        case .text: text = (self.body as? ChatTextMessageBody)?.text ?? ""
        case .image: text = "[Image]"
        case .voice: text = "[Audio]"
        case .video: text = "[Video]"
        case .file: text = "[File]"
        case .location: text = "[Location]"
        case .combine: text = "[Chat history]"
        case .cmd: text = "[Notify]"
        case .custom:
            if let body = self.body as? ChatCustomMessageBody {
                if body.event == EaseChatUIKit_user_card_message {
                    text = "[Contact]"
                }
                if body.event == EaseChatUIKit_alert_message {
                    text = "[Alert]"
                }
            }
        default: break
        }
        return text.chat.localize
    }
    
    var replyIcon: UIImage? {
        switch self.body.type {
        case .image:
            return UIImage(named: "reply_image", in: .chatBundle, with: nil)
        case .voice:
            return UIImage(named: "reply_audio", in: .chatBundle, with: nil)
        case .video:
            return UIImage(named: "reply_video", in: .chatBundle, with: nil)
        case .file,.combine:
            return UIImage(named: "reply_file", in: .chatBundle, with: nil)
        case .location:
            return UIImage(named: "reply_location", in: .chatBundle, with: nil)
        case .custom:
            if let body = self.body as? ChatCustomMessageBody {
                if body.event == EaseChatUIKit_user_card_message {
                    return UIImage(named: "reply_card", in: .chatBundle, with: nil)
                }
            }
            return nil
        default:
            return nil
        }
    }
    
    var showContent: String {
        var text = ""
        switch self.body.type {
        case .text: text = (self.body as? ChatTextMessageBody)?.text ?? ""
        case .voice: text = "\((self.body as? ChatAudioMessageBody)?.duration ?? 0)″"
        case .file: text = "\((self.body as? ChatFileMessageBody)?.displayName ?? "")"
        case .location: text = self.showType
        case .custom:
            if let body = self.body as? ChatCustomMessageBody {
                if body.event == EaseChatUIKit_user_card_message {
                    let userId = body.customExt["uid"] ?? ""
                    text = body.customExt["nickname"] ?? userId
                }
                if body.event == EaseChatUIKit_alert_message {
                    text = (self.ext?["something"] as? String) ?? ""
                }
            }
        default: break
        }
        return text
    }
    
    var mention: String {
        if self.body.type == .text && self.direction == .receive,let conversation = ChatClient.shared().chatManager?.getConversation(self.conversationId, type: .groupChat, createIfNotExist: false) {
            if conversation.type == .groupChat {
                if let ext = self.ext, let atList = ext["em_at_list"] {
                    if let atListString = atList as? String {
                        if atListString == "ALL" {
                            return "ALL"
                        }
                    } else if let atListArray = atList as? [String] {
                        if ChatClient.shared().currentUsername?.count ?? 0 > 0 && atListArray.contains((ChatClient.shared().currentUsername ?? "").lowercased()) {
                            return (EaseChatUIKitContext.shared?.currentUser?.id ?? self.from).lowercased()
                        }
                    }
                }
            }
        }
        return ""
    }
    
    var quoteMessage: ChatMessage? {
        guard let quoteInfo = self.ext?["msgQuote"] as? Dictionary<String,Any> else { return nil }
        guard let quoteMessageId = quoteInfo["msgID"] as? String else {
            return ChatMessage()
        }
        return ChatClient.shared().chatManager?.getMessageWithMessageId(quoteMessageId)
    }
}
