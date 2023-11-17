//
//  ChatService.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import Foundation

@objc public protocol ChatService: NSObjectProtocol {
    
    /// Bind message changed listener
    /// - Parameter listener: ``ChatResponseListener``
    func bindChatEventsListener(listener: ChatResponseListener)
    
    /// Unbind message changed listener
    /// - Parameter listener: ``ChatResponseListener``
    func unbindChatEventsListener(listener: ChatResponseListener)
    
    /// Send message to someone.
    /// - Parameters:
    ///   - to: Other party user id.
    ///   - body: ``ChatMessageBody``
    ///   - completion: Callback, returns message if successful, returns error if failed
    func sendMessage(to: String,body: ChatMessageBody,completion: @escaping (ChatError?,ChatMessage?) -> Void)
    
    /// Send message to the group.
    /// - Parameters:
    ///   - to: group id.
    ///   - body: ``ChatMessageBody``
    ///   - completion: Callback, returns message if successful, returns error if failed
    func sendGroupMessage(to: String,body: ChatMessageBody,completion: @escaping (ChatError?,ChatMessage?) -> Void)
    
    /// Remove a message from database.
    /// - Parameter messageId: The id of the message.
    func removeLocalMessage(messageId: String)
    
    /// Remove all of the history messages from database.
    func removeHistoryMessages()
    
    /// Mark a message as already read state.
    /// - Parameter messageId: The id of the message.
    func markMessageAsRead(messageId: String)
    
    /// Mark all of the history messages as already read.
    func markAllMessagesAsRead()
    
    /// Load messages from database.
    /// - Parameters:
    ///   - messageId: The start id of the message.
    ///   - pageSize: The size number.
    ///   - completion: Request a callback, returning an array of message objects if successful, or an error if failed
    func loadMessages(start messageId: String,pageSize: UInt,completion: @escaping (ChatError?,[ChatMessage]) -> Void)
    
    /// Search message from database.
    /// - Parameters:
    ///   - keyword: Search keyword.
    ///   - pageSize: The size number.
    ///   - userId: The id of the user.
    ///   - completion: Request a callback, returning an array of message objects if successful, or an error if failed
    func searchMessage(keyword: String,pageSize: UInt,userId: String,completion: @escaping (ChatError?,[ChatMessage]) -> Void)
    
}

@objc public protocol ChatResponseListener: NSObjectProtocol {
    
    /// When message received.
    /// - Parameter message: ``ChatMessage``
    func onMessageDidReceived(message: ChatMessage)
    
    /// When message recalled.
    /// - Parameter recallInfo: ``ChatMessage``
    func onMessageDidRecalled(recallInfo: RecallInfo)
    
    /// When message edited.
    /// - Parameter message: ``ChatMessage``
    func onMessageDidEdited(message: ChatMessage)
    
    /// When status of message changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - error: ``ChatError``
    func onMessageStatusDidChanged(message: ChatMessage,error: ChatError?)
    
    /// When status of message attachment changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - error: ``ChatError``
    func onMessageAttachmentStatusChanged(message: ChatMessage,error: ChatError?)
    
    /// When reaction of message changed.
    /// - Parameter changes: ``MessageReactionChange``
    func onMessageReactionChanged(changes: [MessageReactionChange])
}
