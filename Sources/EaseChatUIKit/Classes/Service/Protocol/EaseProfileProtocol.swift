//
//  DisplayProviderProtocol.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/8.
//

import Foundation


/// Profile of the EaseChatUIKit display needed.
@objc public protocol EaseProfileProtocol: NSObjectProtocol {
    var id: String {set get}
    var avatarURL: String {set get}
    var nickName: String {set get}
}

@objcMembers open class EaseProfile:NSObject, EaseProfileProtocol {
    
    public var id: String = ""
    
    public var avatarURL: String = ""
    
    public var nickName: String = ""
    
}

/// Profile provider of the EaseChatUIKit.Only available in Swift language.
public protocol EaseProfileProvider {
    
    /// Synchronously obtain user information.
    /// - Parameters:
    ///   - id: Conversation's id.
    ///   - type: ``ChatConversationType``
    /// - Returns: ``EaseProfile``
    func getProfile(id: String, type: ChatConversationType) -> EaseProfileProtocol
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameter profilesMap: The map parameter key is the conversation type value is the corresponding conversation id string array.
    /// - Returns: Array of the conform``EaseProfileProtocol`` object.
    func fetchProfiles(profilesMap: [ChatConversationType:[String]]) async -> [EaseProfileProtocol]
}

public extension EaseProfileProvider {
    func getProfile(id: String, type: ChatConversationType) -> EaseProfileProtocol {
        EaseProfile()
    }
}


/// /// Profile provider of the EaseChatUIKit.Only available in Objective-C language.
@objc public protocol EaseProfileProviderOC: NSObjectProtocol {
    /// Synchronously obtain user information.
    /// - Parameters:
    ///   - id: Conversation's id.
    ///   - type: ``ChatConversationType``
    /// - Returns: ``EaseProfile``
    @objc optional func getProfile(id: String, type: ChatConversationType) -> EaseProfileProtocol
    
    /// Need to obtain the list display information on the current screen.
    /// - Parameters:
    ///   - profilesMap: The map parameter key is the conversation type value is the corresponding conversation id string array.
    ///   - completion: Callback,obtain Array of the ``EaseProfile`` object.
    func fetchProfiles(profilesMap: [Int:[String]],completion: @escaping ([EaseProfileProtocol]) -> Void)
}

public protocol EaseGroupMemberProfileProvider {
    
    /// Get member to render user nick name and avatar.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userId: The id of the user.
    /// - Returns: The object of conform ``EaseProfileProtocol``.
    func getMember(groupId:String ,userId: String ) -> EaseProfileProtocol
    
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userIds: The id of the user.
    /// - Returns: Callback,obtain Array  of conform ``EaseProfileProtocol`` object.
    func fetchMembers(groupId:String, userIds:[String]) async -> [EaseProfileProtocol]
 
}

public extension EaseGroupMemberProfileProvider {
    func getMember(groupId: String, userId: String) -> EaseProfileProtocol {
        EaseProfile()
    }
}

@objc public protocol EaseGroupMemberProfileProviderOC: NSObjectProtocol {
    /// Get member to render user nick name and avatar.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userId: The id of the user.
    /// - Returns: The object of conform ``EaseProfileProtocol``.
    @objc optional func getMember(groupId:String ,userId: String ) -> EaseProfileProtocol
    
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userIds: The id of the user.
    /// - Returns: Callback,obtain Array  of conform ``EaseProfileProtocol`` object.
    func fetchMembers(groupId:String, userIds:[String], completion: @escaping ([EaseProfileProtocol]) -> Void)
}
