//
//  MessageListViewModel.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/29.
//

import UIKit


@objc public enum MentionUpdate: UInt {
    case add
    case delete
}

@objc public protocol MessageListDriverEventsListener: NSObjectProtocol {
    func onMessageAvatarClicked(user: EaseProfileProtocol)
    
    func onMessageBubbleClicked(message: ChatMessage)
    
    func onMessageBubbleLongPressed(message: ChatMessage)
    
    func onMessageAttachmentLoading(loading: Bool)
    
    func onInputBoxEventsOccur(action type: MessageInputBarActionType, attributeText: NSAttributedString?)
}

@objcMembers open class MessageListViewModel: NSObject {
    
    public private(set) var mentionIds = [String]()
    
    public private(set) var to = ""
    
    public private(set) weak var driver: IMessageListViewDriver?
    
    public private(set) var chatService: ChatService?
    
    public private(set) var groupService: GroupService? = GroupServiceImplement()
    
    public private(set) var multiService: MultiDeviceService? = MultiDeviceServiceImplement()
    
    private var handlers: NSHashTable<MessageListDriverEventsListener> = NSHashTable<MessageListDriverEventsListener>.weakObjects()
    
    @objc public required override init() {
        super.init()
    }
    
    @objc public func bindDriver(driver: IMessageListViewDriver,conversationId: String) {
        self.driver = driver
        self.chatService = ChatServiceImplement(to: conversationId)
        self.chatService?.bindChatEventsListener(listener: self)
        self.to = conversationId
        driver.addActionHandler(actionHandler: self)
        self.loadMessages()
    }
    
    @objc public func addEventsListener(listener: MessageListDriverEventsListener) {
        if self.handlers.contains(listener) {
            return
        }
        self.handlers.add(listener)
    }
    
    @objc public func removeEventsListener(listener: MessageListDriverEventsListener) {
        if self.handlers.contains(listener) {
            self.handlers.remove(listener)
        }
    }
    
    @objc public func loadMessages() {
        if let start = self.driver?.firstMessageId {
            self.chatService?.loadMessages(start: start, pageSize: 20, completion: { [weak self] error, messages in
                if error == nil {
                    if (self?.driver?.firstMessageId ?? "").isEmpty {
                        self?.driver?.refreshMessages(messages: messages)
                    } else {
                        self?.driver?.insertMessages(messages: messages)
                    }
                } else {
                    consoleLogInfo("loadMessages error:\(error?.errorDescription ?? "")", type: .error)
                }
            })
        }
    }

    @objc public func sendMessage(text: String,type: MessageCellStyle,extensionInfo: Dictionary<String,Any> = [:]) {
        if let message = self.constructMessage(text: text, type: type,extensionInfo: extensionInfo) {
            self.driver?.showMessage(message: message)
            self.chatService?.send(message: message) { [weak self] error, message in
                if error == nil {
                    if let message = message {
                        self?.driver?.updateMessageStatus(message: message, status: .succeed)
                    }
                } else {
                    consoleLogInfo("send text message failure:\(error?.errorDescription ?? "")", type: .error)
                    if let message = message {
                        self?.driver?.updateMessageStatus(message: message, status: .failure)
                    }
                }
            }
        }
    }
    
    private func constructMessage(text: String,type: MessageCellStyle,extensionInfo: Dictionary<String,Any> = [:]) -> ChatMessage? {
        var ext = extensionInfo
        let json = EaseChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        ext["ease_chat_uikit_info"] = json
        switch type {
        case .text:
            return ChatMessage(conversationID: self.to, body: ChatTextMessageBody(text: text), ext: ext)
        case .image:
            return ChatMessage(conversationID: self.to, body: ChatImageMessageBody(localPath: text, displayName: "\(Date().timeIntervalSince1970)"), ext: ext)
        case .voice:
            let body = ChatAudioMessageBody(localPath: text, displayName: "\(Int(Date().timeIntervalSince1970*1000)).amr")
            if let duration = extensionInfo["duration"] as? Int {
                body.duration = Int32(duration)
            }
            return ChatMessage(conversationID: self.to, body: body, ext: ext)
        case .video:
            return ChatMessage(conversationID: self.to, body: ChatVideoMessageBody(localPath: text, displayName: "\(Date().timeIntervalSince1970)"), ext: ext)
        case .file:
            return ChatMessage(conversationID: self.to, body: ChatFileMessageBody(localPath: text, displayName: "\(Date().timeIntervalSince1970)"), ext: ext)
        case .contact:
            var ext = extensionInfo
            var customExt = [String:String]()
            if let userId =  extensionInfo["uid"] as? String {
                customExt["uid"] = userId
                ext.removeValue(forKey: "uid")
            }
            if let avatar =  extensionInfo["avatar"] as? String {
                customExt["avatar"] = avatar
                ext.removeValue(forKey: "avatar")
            }
            if let nickname =  extensionInfo["nickname"] as? String {
                customExt["nickname"] = nickname
                ext.removeValue(forKey: "nickname")
            }
             return ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: text, customExt: customExt), ext: ext)
        case .alert:
            ext["something"] = text
            return ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
        default:
            return nil
        }
    }
        
    @objc public func updateMentionIds(user: EaseProfileProtocol,type: MentionUpdate) {
        if type == .add {
            self.driver?.addMentionUserToField(user: user)
        } else {
//            self.mentionIds.removeAll { $0 == user.id }
        }
    }
    
    @objc public func processMessage(operation: MessageOperation,message: ChatMessage,edit text: String = "") {
        switch operation {
        case .edit: self.editMessage(operation: operation, message: message, content: text)
        case .copy: self.driver?.processMessage(operation: .copy, message: message)
        case .reply: self.driver?.processMessage(operation: .reply, message: message)
        case .recall: self.recallMessage(operation: .recall, message: message)
        case .delete: 
            self.driver?.processMessage(operation: .delete, message: message)
            self.chatService?.removeLocalMessage(messageId: message.messageId)
        }
    }
    
    private func editMessage(operation: MessageOperation,message: ChatMessage,content: String = "") {
        self.chatService?.edit(messageId: message.messageId, text: content, completion: { [weak self] error, editMessage in
            if error == nil,let raw = editMessage {
                self?.driver?.processMessage(operation: .edit, message: raw)
            } else {
                consoleLogInfo("edit message error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    private func recallMessage(operation: MessageOperation,message: ChatMessage) {
        self.chatService?.recall(messageId: message.messageId, completion: { [weak self] error in
            if error == nil {
                self?.recallAction(message: message)
            } else {
                consoleLogInfo("recall message error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    private func recallAction(message: ChatMessage) {
        if let recall = self.constructMessage(text: "recalled a message".chat.localize, type: .alert, extensionInfo: [:]) {
            recall.timestamp = message.timestamp
            recall.from = message.from
            ChatClient.shared().chatManager?.getConversationWithConvId(message.conversationId)?.insert(recall, error: nil)
            self.driver?.processMessage(operation: .recall, message: recall)
        }
    }
}

extension MessageListViewModel: MessageListViewActionEventsDelegate {
    public func onFailureMessageRetrySend(entity: MessageEntity) {self.driver?.updateMessageStatus(message: entity.message, status: .sending)
        self.chatService?.send(message: entity.message, completion: { error, message in
            if error == nil {
                self.driver?.updateMessageStatus(message: entity.message, status: .succeed)
            } else {
                self.driver?.updateMessageStatus(message: entity.message, status: .failure)
                consoleLogInfo("onFailureMessageRetrySend fail messageId:\(entity.message.messageId) error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    
    public func onMessageListPullRefresh() {
        self.loadMessages()
    }
    
    public func onMessageReplyClicked(message: MessageEntity) {
        
    }
    
    public func onMessageContentClicked(message: MessageEntity) {
        let bodyType = message.message.body.type
        if bodyType == .voice || bodyType == .file || bodyType == .video || bodyType == .image {
            if !FileManager.default.fileExists(atPath: (message.message.body as? ChatFileMessageBody)?.localPath ?? "") {
                self.downloadMessageAttachment(message: message)
            } else {
                if bodyType != .voice {
                    for handler in self.handlers.allObjects {
                        handler.onMessageBubbleClicked(message: message.message)
                    }
                } else {
                    self.audioMessagePlay(message: message)
                }
            }
        } else {
            for handler in self.handlers.allObjects {
                handler.onMessageBubbleClicked(message: message.message)
            }
        }
        
    }
    
    private func audioMessagePlay(message: MessageEntity) {
        message.playing = !message.playing
        message.message.isListened = true
        let body = (message.message.body as? ChatAudioMessageBody)
        if let duration = body?.duration {
            if duration > 0 {
                if message.playing {
                    if let path = body?.localPath {
                        if AudioTools.canPlay(url: URL(fileURLWithPath: path)) {
                            AudioTools.shared.stopPlaying()
                            self.driver?.updateAudioMessageStatus(message: message.message, play: message.playing)
                            AudioTools.shared.playRecording(path: path) { [weak self] in
                                if let body = message.message.body as? ChatFileMessageBody {
                                    if body.localPath == $0 {
                                        self?.driver?.updateAudioMessageStatus(message: message.message, play: false)
                                    }
                                }
                            }
                        } else {
                            let tuple = MediaConvertor.convertAMRToWAV(url: URL(fileURLWithPath: path))
                            if tuple.0 != nil,tuple.1 != nil {
                                body?.localPath = tuple.1
                                ChatClient.shared().chatManager?.update(message.message)
                                self.audioMessagePlay(message: message)
                            }
                        }
                    }
                } else {
                    self.driver?.updateAudioMessageStatus(message: message.message, play: message.playing)
                    AudioTools.shared.stopPlaying()
                }
            }
        }
    }
    
    private func downloadMessageAttachment(message: MessageEntity) {
        for handler in self.handlers.allObjects {
            handler.onMessageAttachmentLoading(loading: true)
        }
        ChatClient.shared().chatManager?.downloadMessageAttachment(message.message, progress: nil,completion: { [weak self] attachMessage, error in
            guard let `self` = self else { return }
            for handler in self.handlers.allObjects {
                handler.onMessageAttachmentLoading(loading: false)
            }
            if error == nil,let attachment = attachMessage {
                if attachment.body.type == .video {
                    self.cacheFrame(attachMessage: message.message)
                }
                if attachment.body.type == .voice {
                    self.audioMessagePlay(message: message)
                }
                if message.message.body.type == .image {
                    self.cacheImage(message: message.message)
                }
                for handler in self.handlers.allObjects {
                    handler.onMessageBubbleClicked(message: message.message)
                }
            } else {
                consoleLogInfo("onMessageReplyClicked download error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    private func cacheImage(message: ChatMessage) {
        if let body = (message.body as? ChatImageMessageBody) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: body.localPath))
                try FileManager.default.removeItem(atPath: body.localPath)
                let image = UIImage(data: data)
                if image?.imageOrientation == .up {
                    body.localPath += ".jpeg"
                } else {
                    body.localPath += ".png"
                }
                try data.write(to: URL(fileURLWithPath: body.localPath))
                ChatClient.shared().chatManager?.update(message)
            } catch {
                consoleLogInfo("download image then load error:\(error.localizedDescription)", type: .error)
            }
        }
    }
    
    private func cacheFrame(attachMessage: ChatMessage) {
        if let body = attachMessage.body as? ChatVideoMessageBody {
            if let path = body.localPath {
                if var thumbnailLocalPath = path.components(separatedBy: ".").first,let type = path.components(separatedBy: ".").last {
                    thumbnailLocalPath = thumbnailLocalPath + "-thumbnail" + type
                    body.thumbnailLocalPath = thumbnailLocalPath
                    MediaConvertor.firstFrame(from: path) { image in
                        if let data = image?.pngData()  {
                            ChatClient.shared().chatManager?.update(attachMessage)
                            MediaConvertor.writeFile(to: thumbnailLocalPath, data: data)
                        }
                    }
                    
                }
            }
        }
    }
    
    public func onMessageContentLongPressed(message: MessageEntity) {
        for handler in self.handlers.allObjects {
            handler.onMessageBubbleLongPressed(message: message.message)
        }
    }
    
    public func onMessageAvatarClicked(profile: EaseProfileProtocol) {
        for handler in self.handlers.allObjects {
            handler.onMessageAvatarClicked(user: profile)
        }
    }
    
    public func onMessageAvatarLongPressed(profile: EaseProfileProtocol) {
        
    }
    
    public func onInputBoxEventsOccur(action type: MessageInputBarActionType, attributeText: NSAttributedString?) {
        switch type {
        case .send:
            if let attribute = attributeText {
                self.willSendMessage(attributeText: attribute)
            }
        default: break
        }
        
        for handler in self.handlers.allObjects {
            handler.onInputBoxEventsOccur(action: type, attributeText: attributeText)
        }
    }
    
    private func willSendMessage(attributeText: NSAttributedString) {
        var mentionIds = [String]()
        let text = attributeText.toString()
        var extensionInfo = [String:Any]()
        attributeText.enumerateAttributes(in: NSRange(location: 0, length: attributeText.length), options: []) { (attributes, blockRange, stop) in
            let key = NSAttributedString.Key("mentionInfo")
            if let mentionInfo = attributes[key] as? EaseProfileProtocol {
                mentionIds.append(mentionInfo.id)
            }
        }
        if mentionIds.contains("ALL") {
            extensionInfo["em_at_list"] = "ALL"
        } else {
            extensionInfo["em_at_list"] = mentionIds
        }
        if let replyId = self.driver?.replyMessageId,let message = ChatClient.shared().chatManager?.getMessageWithMessageId(replyId) {
            let msgTypeDict: [ChatMessageBodyType: String] = [ .text: "txt", .image: "img", .video: "video", .voice: "audio", .custom: "custom", .cmd: "cmd", .file: "file", .location: "location", .combine: "combine" ]

            extensionInfo["msgQuote"] = [ "msgID": message.messageId, "msgPreview": message.showContent, "msgSender": message.from, "msgType": msgTypeDict[message.body.type] ?? "" ]
        }
        self.sendMessage(text: text, type: .text,extensionInfo: extensionInfo)
    }
}

extension MessageListViewModel: ChatResponseListener {
    public func onMessageDidReceived(message: ChatMessage) {
        if message.to == self.to {
            let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self.to)
            conversation?.markMessageAsRead(withId: message.messageId, error: nil)
            if conversation?.type ?? .chat == .chat {
                ChatClient.shared().chatManager?.sendMessageReadAck(message.messageId, toUser: self.to)
            }
            message.direction = .receive
            self.driver?.showMessage(message: message)
        }
    }
    
    public func onMessageDidRecalled(recallInfo: RecallInfo) {
        if recallInfo.recallMessage.to == self.to {
            self.recallAction(message: recallInfo.recallMessage)
        }
    }
    
    public func onMessageDidEdited(message: ChatMessage) {
        if message.to == self.to {
            self.driver?.updateMessageStatus(message: message, status: .edited)
        }
    }
    
    public func onMessageStatusDidChanged(message: ChatMessage, status: ChatMessageStatus, error: ChatError?) {
        if message.to == self.to {
            self.driver?.updateMessageStatus(message: message, status: status)
        }
    }
    
    public func onMessageAttachmentStatusChanged(message: ChatMessage, error: ChatError?) {
        if message.to == self.to {
            if error == nil {
                self.driver?.updateMessageAttachmentStatus(message: message)
            } else {
                consoleLogInfo("onMessageAttachmentStatusChanged error:\(error?.errorDescription ?? "")", type: .error)
            }
        }
    }
    
    public func onMessageReactionChanged(changes: [MessageReactionChange]) {
        if changes.first?.conversationId ?? "" == self.to {
            
        }
    }
    
    
}
