//
//  ConversationServiceImplement.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objc public class ConversationServiceImplement: NSObject {
    
    private let pageSize = UInt8(50)
    
    private var cursor = ""
    
    @UserDefault("EaseChatUIKit_conversation_load_more_finished", defaultValue: [(ChatClient.shared().currentUsername ?? ""):false]) private var loadFinished
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Int>()) private var muteMap
    
    private var responseDelegates: NSHashTable<ConversationServiceListener> = NSHashTable<ConversationServiceListener>.weakObjects()
                
    private var conversationId = ""
    
    public var chatConversation: ChatConversation? {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.conversationId)
    }
    
    @objc public required init(conversationId: String) {
        super.init()
        self.conversationId = conversationId
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
    }
    
    deinit {
        ChatClient.shared().chatManager?.remove(self)
    }
}

extension ConversationServiceImplement: ConversationService {
    
    public func loadExistConversations(completion: @escaping ([ConversationInfo],ChatError?) -> Void) {
        let items = ChatClient.shared().chatManager?.getAllConversations(true) ?? []
        let userId = ChatClient.shared().currentUsername ?? ""
        if items.count <= 0,!(self.loadFinished[userId] ?? false) {
            self.fetchPinnedConversations(cursor: "", pageSize: self.pageSize) { [weak self] result, error in
                guard let `self` = self else { return  }
                if error == nil {
                    if let list = result?.list,list.isEmpty {
                        self.fetchAllConversations { [weak self] result1, error1 in
                            guard let `self` = self else { return  }
                            if error1 == nil {
                                if let list1 = result1?.list,!list1.isEmpty {
                                    completion(list1,nil)
                                } else {
                                    completion([],nil)
                                }
                            } else {
                                completion([],error1)
                            }
                        }
                    } else {
                        self.fetchSilentMode(conversationIds: result?.list?.map({ $0.id }) ?? []) { [weak self] resultSilent, silentError in
                            guard let `self` = self else { return  }
                            if silentError == nil {
                                if let list = result?.list {
                                    for item in list {
                                        if let silentMode = resultSilent?[item.id]?.remindType {
                                            self.muteMap[item.id] = silentMode.rawValue
                                        }
                                    }
                                    completion(list,silentError)
                                }
                            } else {
                                completion([],silentError)
                            }
                        }
                    }
                } else {
                    completion([],error)
                }
            }
        } else {
            completion(self.mapper(objects: items),nil)
        }
    }
    
    
    public func fetchSilentMode(conversationIds: [String], completion: @escaping (Dictionary<String, SilentModeResult>?, ChatError?) -> Void) {
        let conversations = conversationIds.map {
            ChatClient.shared().chatManager?.getConversationWithConvId($0) ?? ChatConversation()
        }
        ChatClient.shared().pushManager?.getSilentMode(for: conversations,completion: { result, error in
            completion(result,error)
        })
    }
    
    public func setSilentMode(conversationId: String, completion: @escaping (SilentModeResult?, ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().pushManager?.setSilentModeForConversation(conversationId, conversationType: conversation.type, params: SilentModeParam(paramType: .remindType),completion: { [weak self] result, error in
                if error == nil {
                    self?.muteMap[result?.conversationID ?? ""] = 1
                }
                completion(result,error)
            })
        }
    }
    
    public func clearSilentMode(conversationId: String, completion: @escaping (SilentModeResult?, ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().pushManager?.clearRemindType(forConversation: conversationId, conversationType: conversation.type, completion: { result, error in
                if error == nil {
                    self.muteMap.removeValue(forKey: result?.conversationID ?? "")
                }
                completion(result,error)
            })
        }
    }
    
    public func fetchPinnedConversations(cursor: String, pageSize: UInt8, completion: @escaping (CursorResult<ConversationInfo>?, ChatError?) -> Void) {
        ChatClient.shared().chatManager?.getPinnedConversationsFromServer(withCursor: cursor, pageSize: pageSize, completion: { [weak self] result, error in
            completion(CursorResult(list: self?.mapper(objects: result?.list ?? []), andCursor: cursor),error)
        })
    }
    
    public func fetchAllConversations(completion: ((CursorResult<ConversationInfo>?,ChatError?) -> Void)?) {
        ChatClient.shared().chatManager?.getConversationsFromServer(withCursor: self.cursor, pageSize: self.pageSize, completion: { [weak self] result, error in
            if error == nil,let list = result?.list {
                if (self?.cursor ?? "").isEmpty {
                    self?.cursor = result?.cursor ?? ""
                    self?.fetchSilentMode(conversationIds: list.map({ $0.conversationId }), completion: { resultSilent, silentError in
                        if silentError == nil {
                            for item in list {
                                if let silentMode = resultSilent?[item.conversationId]?.remindType {
                                    self?.muteMap[item.conversationId] = silentMode.rawValue
                                }
                            }
                        }
                        completion?(CursorResult(list: self?.mapper(objects: list), andCursor: self?.cursor ?? ""),silentError)
                    })
                } else {
                    self?.fetchAllConversations(completion: nil)
                }
                
                if (self?.cursor ?? "").isEmpty {
                    self?.loadFinished[ChatClient.shared().currentUsername ?? ""] = true
                    return
                }
            } else {
                completion?(nil,error)
            }
        })
    }
    
    public func pin(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinConversation(conversationId, isPinned: true, completionBlock: { error in
            completion(error)
        })
    }
    
    public func unpin(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinConversation(conversationId, isPinned: false, completionBlock: { error in
            completion(error)
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().chatManager?.deleteServerConversation(conversationId, conversationType: conversation.type, isDeleteServerMessages: true,completion: { id, error in
                if error == nil,conversationId == id ?? "" {
                    ChatClient.shared().chatManager?.deleteConversation(conversationId, isDeleteMessages: true, completion: { localId, error in
                        completion(error)
                    })
                } else {
                    completion(error)
                }
            })
        }
        
    }
    
    public func bindConversationEventsListener(listener: ConversationServiceListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindConversationEventsListener(listener: ConversationServiceListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func removeLocalMessage(messageId: String) {
        self.chatConversation?.deleteMessage(withId: messageId, error: nil)
    }
    
    public func removeHistoryMessages() {
        self.chatConversation?.deleteAllMessages(nil)
    }
    
    public func markMessageAsRead(messageId: String) {
        self.chatConversation?.markMessageAsRead(withId: messageId, error: nil)
    }
    
    public func markAllMessagesAsRead() {
        self.chatConversation?.markAllMessages(asRead: nil)
    }
    
    public func loadMessages(start messageId: String, pageSize: UInt, completion: @escaping (ChatError?, [ChatMessage]) -> Void) {
        self.chatConversation?.loadMessagesStart(fromId: messageId, count: Int32(pageSize), searchDirection: .up,completion: { messages, error in
            completion(error,messages ?? [])
        })
    }
    
    public func searchMessage(keyword: String, pageSize: UInt, userId: String, completion: @escaping (ChatError?, [ChatMessage]) -> Void) {
        self.chatConversation?.loadMessages(withKeyword: keyword, timestamp: 0, count: Int32(pageSize), fromUser: userId, searchDirection: .up,completion: { messages, error in
            completion(error,messages ?? [])
        })
    }
    
    private func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
        objects.map {
            let conversation = ConversationInfo()
            conversation.id = $0.conversationId
            conversation.unreadCount = Int($0.unreadMessagesCount)
            conversation.lastMessage = $0.latestMessage
            conversation.type = $0.type
            conversation.pinned = $0.isPinned
            if EaseChatUIKitClient.shared.option.option_chat.saveConversationInfo {
                if let nickName = $0.ext["EaseChatUIKit_nickName"] as? String {
                    conversation.nickName = nickName
                }
                if let avatarURL = $0.ext["EaseChatUIKit_avatarURL"] as? String {
                    conversation.avatarURL = avatarURL
                }
            }
            conversation.noDisturb = false
            if let silentMode = self.muteMap[$0.conversationId] {
                conversation.noDisturb = silentMode != 0
            }
            return conversation
        }
    }
}


extension ConversationServiceImplement: ChatEventsListener {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            for listener in self.responseDelegates.allObjects {
                if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(message.to) {
                    let list = self.mapper(objects: [conversation])
                    if let info = list.first {
                        listener.onConversationLastMessageUpdate(message: message, info: info)
                    }
                }
                
            }
        }
    }
    
    public func conversationListDidUpdate(_ aConversationList: [ChatConversation]) {
        let list = self.mapper(objects: aConversationList)
        for listener in self.responseDelegates.allObjects {
            listener.onChatConversationListDidChanged(list: list)
        }
    }
    
    public func onConversationRead(_ from: String, to: String) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(to) {
            conversation.markAllMessages(asRead: nil)
            if let info = self.mapper(objects: [conversation]).first{
                info.unreadCount = 0
                for listener in self.responseDelegates.allObjects {
                    listener.onConversationMessageAlreadyReadOnOtherDevice(info: info)
                }
            }
        }
        
    }

}