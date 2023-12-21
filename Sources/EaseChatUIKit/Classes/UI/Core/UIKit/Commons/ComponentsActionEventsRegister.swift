//
//  ComponentViewsActionHooker.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/7.
//

import UIKit

@objcMembers public class ComponentViewsActionHooker: NSObject {

    
    @objcMembers public class Conversation: NSObject {
                
        static public var swipeAction: ((UIContextualActionType,ConversationInfo) -> Void)?
        
        static public var longPressed: ((IndexPath,ConversationInfo) -> Void)?
        
        static public var didSelected: ((IndexPath,ConversationInfo) -> Void)?
    }
    
    @objcMembers public class Contact: NSObject {
        
        static public var didSelectedContact: ((IndexPath,EaseProfileProtocol) -> Void)?
        
        static public var groupWithSelected: ((IndexPath,EaseProfileProtocol) -> Void)?
    }
                
    @objcMembers public class Chat: NSObject {
        
        static public var replyClicked: ((MessageEntity) -> Void)?
        
        static public var bubbleClicked: ((MessageEntity) -> Void)?
        
        static public var bubbleLongPressed: ((MessageEntity) -> Void)?
        
        static public var avatarClicked: ((EaseProfileProtocol) -> Void)?
        
        static public var avatarLongPressed: ((EaseProfileProtocol) -> Void)?
    }
}
