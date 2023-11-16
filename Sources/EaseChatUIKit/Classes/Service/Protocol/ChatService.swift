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
