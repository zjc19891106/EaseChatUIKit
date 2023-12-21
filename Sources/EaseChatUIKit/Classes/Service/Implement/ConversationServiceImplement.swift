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
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    private var responseDelegates: NSHashTable<ConversationServiceListener> = NSHashTable<ConversationServiceListener>.weakObjects()
    
    private var eventsNotifiers: NSHashTable<ConversationEmergencyListener> = NSHashTable<ConversationEmergencyListener>.weakObjects()
    
    public override init() {
        super.init()
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
        
    }
    
    deinit {
        ChatClient.shared().chatManager?.remove(self)
    }
}

extension ConversationServiceImplement: ConversationService {
    public func loadIfNotExistCreate(conversationId: String, type: ChatConversationType) -> ChatConversation? {
        ChatClient.shared().chatManager?.getConversation(conversationId, type: type, createIfNotExist: true)
    }
    
    
    
    public func loadExistConversations(completion: @escaping ([ConversationInfo],ChatError?) -> Void) {
        let items = ChatClient.shared().chatManager?.getAllConversations(true) ?? []
        let userId = ChatClient.shared().currentUsername ?? ""
        if items.count <= 0,!(self.loadFinished[userId] ?? false) {
            self.fetchPinnedConversations(cursor: "", pageSize: self.pageSize) { [weak self] result, error in
                guard let `self` = self else { return  }
                if error == nil {
                    if let list = result?.list,list.isEmpty {
                        self.fetchAllConversations { [weak self] result1, error1 in
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
                                        if let silentMode = resultSilent?[item.id]?.remindType,silentMode == .mentionOnly {
                                            self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[item.id] = silentMode.rawValue
                                        }
                                    }
                                    completion(list,silentError)
                                }
                            } else {
                                completion([],silentError)
                            }
                        }
                    }
                    self.handleResult(error: error, type: .loadAllMessageFirstLoadUIKit)
                } else {
                    self.handleResult(error: error, type: .loadAllMessageFirstLoadUIKit)
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
        ChatClient.shared().pushManager?.getSilentMode(for: conversations,completion: { [weak self] result, error in
            self?.handleResult(error: error, type: .fetchSilent)
            completion(result,error)
        })
    }
    
    public func setSilentMode(conversationId: String, completion: @escaping (SilentModeResult?, ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().pushManager?.setSilentModeForConversation(conversationId, conversationType: conversation.type, params: SilentModeParam(paramType: .remindType),completion: { [weak self] result, error in
                if error == nil {
                    self?.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[result?.conversationID ?? ""] = 1
                }
                self?.handleResult(error: error, type: .setSilent)
                completion(result,error)
            })
        }
    }
    
    public func clearSilentMode(conversationId: String, completion: @escaping (SilentModeResult?, ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().pushManager?.clearRemindType(forConversation: conversationId, conversationType: conversation.type, completion: { [weak self] result, error in
                if error == nil {
                    self?.muteMap.removeValue(forKey: result?.conversationID ?? "")
                }
                self?.handleResult(error: error, type: .clearSilent)
                completion(result,error)
            })
        }
    }
    
    public func fetchPinnedConversations(cursor: String, pageSize: UInt8, completion: @escaping (CursorResult<ConversationInfo>?, ChatError?) -> Void) {
        ChatClient.shared().chatManager?.getPinnedConversationsFromServer(withCursor: cursor, pageSize: pageSize, completion: { [weak self] result, error in
            self?.handleResult(error: error, type: .fetchPinned)
            completion(CursorResult(list: self?.mapper(objects: result?.list ?? []), andCursor: cursor),error)
        })
    }
    
    public func fetchAllConversations(completion: ((CursorResult<ConversationInfo>?,ChatError?) -> Void)?) {
        ChatClient.shared().chatManager?.getConversationsFromServer(withCursor: self.cursor, pageSize: self.pageSize, completion: { [weak self] result, error in
            if (result?.cursor ?? "").isEmpty {
                self?.cursor = result?.cursor ?? ""
                self?.loadFinished[ChatClient.shared().currentUsername ?? ""] = true
                completion?(CursorResult(list: self?.mapper(objects: result?.list ?? []), andCursor: self?.cursor ?? ""),error)
                return
            }
            if error == nil,let list = result?.list {
                if (self?.cursor ?? "").isEmpty {
                    self?.fetchSilentMode(conversationIds: list.map({ $0.conversationId }), completion: { resultSilent, silentError in
                        if silentError == nil {
                            for item in list {
                                if let silentMode = resultSilent?[item.conversationId]?.remindType {
                                    self?.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[item.conversationId] = silentMode.rawValue
                                }
                            }
                        }
                        completion?(CursorResult(list: self?.mapper(objects: list), andCursor: self?.cursor ?? ""),silentError)
                        self?.fetchAllConversations(completion: nil)
                    })
                } else {
                    self?.fetchAllConversations(completion: nil)
                }
            } else {
                completion?(nil,error)
                return
            }
        })
    }
    
    public func pin(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinConversation(conversationId, isPinned: true, completionBlock: { [weak self] error in
            self?.handleResult(error: error, type: .pin)
            completion(error)
        })
    }
    
    public func unpin(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinConversation(conversationId, isPinned: false, completionBlock: { [weak self] error in
            self?.handleResult(error: error, type: .unpin)
            completion(error)
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().chatManager?.deleteConversation(conversationId, isDeleteMessages: true, completion: { [weak self] localId, error in
                self?.handleResult(error: error, type: .delete)
                completion(error)
            })
        }
        
    }
    
    public func markAllMessagesAsRead(conversationId: String) {
        let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId)
        conversation?.markAllMessages(asRead: nil)
        ChatClient.shared().chatManager?.ackConversationRead(conversationId )
    }
    
    public func bindConversationEventsListener(listener: ConversationServiceListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotify(notification:)), name: Notification.Name("EaseChatUIKit_Conversation_last_message_need_update"), object: nil)
    }
    
    @objc private func receiveNotify(notification: Notification) {
        if let conversationId = notification.object as? String , let message = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId)?.latestMessage {
            self.notifyHandler(message: message)
        }
    }
    
    public func unbindConversationEventsListener(listener: ConversationServiceListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    
    public func registerEmergencyListener(listener: ConversationEmergencyListener) {
        if self.eventsNotifiers.contains(listener) {
            return
        }
        self.eventsNotifiers.add(listener)
    }
    
    public func unregisterEmergencyListener(listener: ConversationEmergencyListener) {
        if self.eventsNotifiers.contains(listener) {
            self.eventsNotifiers.remove(listener)
        }
    }
    
    func handleResult(error: ChatError?,type: ConversationEmergencyType) {
        for listener in self.eventsNotifiers.allObjects {
            listener.onResult(error: error, type: type)
        }
    }
    
    private func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
        objects.map {
            let conversation = ConversationInfo()
            conversation.id = $0.conversationId
            conversation.unreadCount = Int($0.unreadMessagesCount)
            conversation.lastMessage = $0.latestMessage
            conversation.type = EaseProfileProviderType(rawValue: UInt($0.type.rawValue)) ?? .chat
            conversation.pinned = $0.isPinned
            if EaseChatUIKitClient.shared.option.option_chat.saveConversationInfo {
                if let nickName = EaseChatUIKitContext.shared?.conversationsCache?[$0.conversationId]?.nickName as? String {
                    conversation.nickName = nickName
                }
                if let avatarURL = EaseChatUIKitContext.shared?.conversationsCache?[$0.conversationId]?.avatarURL as? String {
                    conversation.avatarURL = avatarURL
                }
            }
            conversation.doNotDisturb = false
            if let silentMode = self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[$0.conversationId] {
                conversation.doNotDisturb = silentMode != 0
            }
            
            _ = conversation.showContent
            return conversation
        }
    }
}


extension ConversationServiceImplement: ChatEventsListener {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            self.notifyHandler(message: message)
        }
    }
    
    private func notifyHandler(message: ChatMessage) {
        guard let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(message.to) else {
            return
        }
        if conversation.ext == nil {
            conversation.ext = [:]
        }
        if !message.mention.isEmpty {
            conversation.ext?["EaseChatUIKit_mention"] = true
        }
        let list = self.mapper(objects: [conversation])
        for listener in self.responseDelegates.allObjects {
            if let info = list.first {
                listener.onConversationLastMessageUpdate(message: message, info: info)
            }
        }
        for handler in self.eventsNotifiers.allObjects {
            if let info = list.first {
                handler.onConversationLastMessageUpdate(message: message, info: info)
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
                
                for handler in self.eventsNotifiers.allObjects {
                    handler.onResult(error: nil, type: .read)
                }
            }
        }
        
    }

}
