//
//  EaseChatUIKitContext.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objcMembers public class EaseChatUIKitContext: NSObject {
    
    @objc static let shared: EaseChatUIKitContext? = EaseChatUIKitContext()

    public var currentUser: UserInfoProtocol?
}
