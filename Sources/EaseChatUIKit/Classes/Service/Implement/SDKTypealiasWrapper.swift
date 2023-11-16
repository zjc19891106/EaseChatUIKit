//
//  TypealiasWrapper.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import Foundation
/**
 This code defines typealiases for chat client, delegates, errors, messages, message bodies, chatrooms, user info, connection state, options, recall info, and cursor result for two different chat SDKs: HyphenateChat and AgoraChat.
 
 If HyphenateChat is imported, the typealiases are defined for HyphenateChat classes. If AgoraChat is imported, the typealiases are defined for AgoraChat classes.
 
 */

#if canImport(HyphenateChat)
import HyphenateChat
public typealias ChatClient = EMClient
public typealias ChatClientListener = EMClientDelegate
public typealias ChatEventsListener = EMChatManagerDelegate
public typealias ChatError = EMError
public typealias ChatErrorCode = EMErrorCode
public typealias ChatMessage = EMChatMessage
public typealias ChatMessageBody = EMMessageBody
public typealias ChatTextMessageBody = EMTextMessageBody
public typealias ChatCustomMessageBody = EMCustomMessageBody
public typealias ChatroomEventsListener = EMChatroomManagerDelegate
public typealias ChatRoom = EMChatroom
public typealias UserInfo = EMUserInfo
public typealias ChatroomBeKickedReason = EMChatroomBeKickedReason
public typealias ConnectionState = EMConnectionState
public typealias ChatSDKOptions = EMOptions
public typealias RecallInfo = EMRecallMessageInfo
public typealias CursorResult = EMCursorResult
public typealias GroupEventsListener = EMGroupManagerDelegate
public typealias MultiDeviceEventsListener = EMMultiDevicesDelegate
public typealias MultiDeviceEvent = EMMultiDevicesEvent
public typealias ContactEventsListener = EMContactManagerDelegate
public typealias ContactRequestInterface = IEMContactManager
public typealias MessageReactionChange = EMMessageReactionChange
public typealias MessageReaction = EMMessageReaction
public typealias MessageReactionOperation = EMMessageReactionOperation
public typealias ChatConversation = EMConversation
public typealias ChatConversationType = EMConversationType
public typealias GroupLeaveReason = EMGroupLeaveReason
public typealias ChatGroup = EMGroup
public typealias ChatGroupOption = EMGroupOptions
public typealias SilentModeResult = EMSilentModeResult
public typealias SilentModeParam = EMSilentModeParam

#elseif canImport(AgoraChat)
import AgoraChat
public typealias ChatClient = AgoraChatClient
public typealias ChatClientListener = AgoraChatClientDelegate
public typealias ChatEventsListener = AgoraChatChatManagerDelegate
public typealias ChatError = AgoraChatError
public typealias ChatErrorCode = AgoraChatErrorCode
public typealias ChatMessage = AgoraChatChatMessage
public typealias ChatMessageBody = AgoraChatMessageBody
public typealias ChatTextMessageBody = AgoraChatTextMessageBody
public typealias ChatCustomMessageBody = AgoraChatCustomMessageBody
public typealias ChatroomEventsListener = AgoraChatChatroomManagerDelegate
public typealias ChatRoom = AgoraChatChatroom
public typealias UserInfo = AgoraChatUserInfo
public typealias ChatroomBeKickedReason = AgoraChatChatroomBeKickedReason
public typealias ConnectionState = AgoraChatConnectionState
public typealias ChatSDKOptions = AgoraChatOptions
public typealias RecallInfo = AgoraChatRecallMessageInfo
public typealias CursorResult = AgoraChatCursorResult
public typealias GroupEventsListener = AgoraChatGroupManagerDelegate
public typealias MultiDeviceEventsListener = AgoraChatMultiDevicesDelegate
public typealias MultiDeviceEvent = AgoraChatMultiDevicesEvent
public typealias ContactEventsListener = AgoraChatContactManagerDelegate
public typealias ContactRequestInterface = IAgoraChatContactManager
public typealias MessageReactionChange = AgoraChatMessageReactionChange
public typealias MessageReaction = AgoraChatMessageReaction
public typealias MessageReactionOperation = AgoraChatMessageReactionOperation
public typealias ChatConversation = AgoraChatConversation
public typealias ChatConversationType = AgoraChatConversationType
public typealias GroupLeaveReason = AgoraChatGroupLeaveReason
public typealias ChatGroup = AgoraChatGroup
public typealias ChatGroupOption = AgoraChatGroupOptions
public typealias SilentModeResult = AgoraChatSilentModeResult
public typealias SilentModeParam = AgoraChatSilentModeParam
#endif



