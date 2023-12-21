//
//  EaseChatUIKitContext.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objc public enum EaseChatUIKitCacheType: UInt {
    case all
    case chat
    case contact
    case conversation
    case groupMemberAttribute
}

@objcMembers public class EaseChatUIKitContext: NSObject {
    
    @objc public static let shared: EaseChatUIKitContext? = EaseChatUIKitContext()

    public var currentUser: EaseProfileProtocol? {
        willSet {
            self.chatCache?[self.currentUserId] = newValue
        }
    }
    
    public var currentUserId: String {
        ChatClient.shared().currentUsername ?? ""
    }
    
    public var chatCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    public var contactsCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    public var conversationsCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    public var groupMemberAttributeCache: GroupMemberAttributesCache? = GroupMemberAttributesCache()
        
    @objc public func cleanCache(type: EaseChatUIKitCacheType) {
        switch type {
        case .all:
            self.chatCache = nil
            self.contactsCache = nil
            self.conversationsCache = nil
            self.groupMemberAttributeCache = nil
        case .chat:
            self.chatCache = nil
        case .contact: self.contactsCache = nil
        case .conversation: self.conversationsCache = nil
        case .groupMemberAttribute: self.groupMemberAttributeCache = nil
        }
    }
}
