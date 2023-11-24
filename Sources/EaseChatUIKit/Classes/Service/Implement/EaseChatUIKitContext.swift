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
}

@objcMembers public class EaseChatUIKitContext: NSObject {
    
    @objc static let shared: EaseChatUIKitContext? = EaseChatUIKitContext()

    public var currentUser: UserInfoProtocol?
    
    public var conversationsCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    public var contactsCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    @objc public func cleanCache(type: EaseChatUIKitCacheType) {
        switch type {
        case .all:
            self.contactsCache = nil
            self.conversationsCache = nil
        case .contact: self.contactsCache = nil
        case .conversation: self.conversationsCache = nil
        default:
            break
        }
    }
}
