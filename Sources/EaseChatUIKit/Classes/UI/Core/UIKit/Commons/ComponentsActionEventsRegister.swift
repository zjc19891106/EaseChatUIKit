//
//  ComponentsActionEventsRegister.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/7.
//

import UIKit

@objcMembers public class ComponentsActionEventsRegister: NSObject {

    
    @objcMembers public class Conversation: NSObject {
                
        static public var swipeAction: ((UIContextualActionType,ConversationInfo) -> Void)?
        
        static public var longPressed: ((IndexPath,ConversationInfo) -> Void)?
        
        static public var didSelected: ((IndexPath,ConversationInfo) -> Void)?
    }
    
    
}
