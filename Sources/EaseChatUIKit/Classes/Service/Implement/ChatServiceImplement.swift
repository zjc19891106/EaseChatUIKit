//
//  ChatServiceImplement.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objc public class ChatServiceImplement: NSObject {
    private var responseDelegates: NSHashTable<ChatResponseListener> = NSHashTable<ChatResponseListener>.weakObjects()
    
    private var to = ""
    
    @objc required public init(to: String) {
        super.init()
        self.to = to
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
    }
    
    deinit {
        ChatClient.shared().chatManager?.remove(self)
    }
}

extension ChatServiceImplement: ChatService {
    public func bindChatEventsListener(listener: ChatResponseListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindChatEventsListener(listener: ChatResponseListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func sendMessage(to: String, body: ChatMessageBody, completion: @escaping (ChatError?, ChatMessage?) -> Void) {
        let json = EaseChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        let message = ChatMessage(conversationID: to, body: body, ext: ["ChatUIKitUserInfo":json])
        message.chatType = .chat
        ChatClient.shared().chatManager?.send(message, progress: nil, completion: { message, error in
            completion(error,message)
        })
    }
    
    public func sendGroupMessage(to: String, body: ChatMessageBody, completion: @escaping (ChatError?, ChatMessage?) -> Void) {
        let json = EaseChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        let message = ChatMessage(conversationID: to, body: body, ext: ["ChatUIKitUserInfo":json])
        message.chatType = .groupChat
        ChatClient.shared().chatManager?.send(message, progress: nil, completion: { message, error in
            completion(error,message)
        })
    }
    
    public func removeLocalMessage(messageId: String) {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.deleteMessage(withId: messageId, error: nil)
    }
    
    public func removeHistoryMessages() {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.deleteAllMessages(nil)
    }
    
    public func markMessageAsRead(messageId: String) {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.markMessageAsRead(withId: messageId, error: nil)
    }
    
    public func markAllMessagesAsRead() {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.markAllMessages(asRead: nil)
    }
    
    public func loadMessages(start messageId: String, pageSize: UInt, completion: @escaping (ChatError?, [ChatMessage]) -> Void) {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.loadMessagesStart(fromId: messageId, count: Int32(pageSize), searchDirection: .up,completion: { messages, error in
            completion(error,messages ?? [])
        })
    }
    
    public func searchMessage(keyword: String, pageSize: UInt, userId: String, completion: @escaping (ChatError?, [ChatMessage]) -> Void) {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.loadMessages(withKeyword: keyword, timestamp: 0, count: Int32(pageSize), fromUser: userId, searchDirection: .up,completion: { messages, error in
            completion(error,messages ?? [])
        })
    }
}

extension ChatServiceImplement: ChatEventsListener {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for listener in self.responseDelegates.allObjects {
            for message in aMessages {
                listener.onMessageDidReceived(message: message)
            }
        }
    }
    
    public func messagesInfoDidRecall(_ aRecallMessagesInfo: [RecallInfo]) {
        for listener in self.responseDelegates.allObjects {
            for info in aRecallMessagesInfo {
                listener.onMessageDidRecalled(recallInfo: info)
            }
        }
    }
    
    public func messageStatusDidChange(_ aMessage: ChatMessage, error aError: ChatError?) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageStatusDidChanged(message: aMessage, error: aError)
        }
    }
    
    public func messageAttachmentStatusDidChange(_ aMessage: ChatMessage, error aError: ChatError?) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageAttachmentStatusChanged(message: aMessage, error: aError)
        }
    }
    
    public func messageReactionDidChange(_ changes: [MessageReactionChange]) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageReactionChanged(changes: changes)
        }
    }
    
    public func messagesDidDeliver(_ aMessages: [ChatMessage]) {
        
    }
}

