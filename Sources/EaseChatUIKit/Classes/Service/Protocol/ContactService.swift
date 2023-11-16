//
//  ContactService.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import Foundation

@objc public protocol ContactServiceProtocol: NSObjectProtocol {
    
    /// Bind contacts changed listener
    /// - Parameter listener: ``ContactEventsResponse``
    func bindContactEventListener(listener: ContactEventsResponse)
    
    /// Unbind contacts state changed listener
    /// - Parameter listener: ``ContactEventsResponse``
    func unbindContactEventListener(listener: ContactEventsResponse)
    
    /// Fetch contacts form server.
    /// - Parameters:
    ///   - userIds: You want to get the string array of user ids.
    ///   - completion: Callback, if successful it will return a string array of user id, if it fails it will return an error.
    func contacts(userIds: [String],completion: @escaping (ChatError?,[String]) -> Void)
    
    /// Add contact.
    /// - Parameters:
    ///   - userId: The ID of the user you want to add as a friend.
    ///   - invitation: Invitation information
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func addContact(userId: String,invitation: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Remove contact.
    /// - Parameters:
    ///   - userId: The ID of the user you want to remove from your friends.
    ///   - removeChannel: Whether to also remove the channel with this user.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func removeContact(userId: String, removeChannel: Bool,completion: @escaping (ChatError?,String) -> Void)
    
    /// Agree friend request.
    /// - Parameters:
    ///   - userId: The user ID that initiated the friend request.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func agreeFriendRequest(from userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Decline friend request.
    /// - Parameters:
    ///   - userId: The user ID that initiated the friend request.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func declineFriendRequest(from userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Get friend blacklist list
    /// - Parameter completion: Callback, if successful it will return a string array of user id, if it fails it will return an error.
    func userBlackList(completion: @escaping (ChatError?,[String]) -> Void)
    
    /// Add user to black list.
    /// - Parameters:
    ///   - userId: The user ID you want to block.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func addUserToBlackList(userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Remove user from black list.
    /// - Parameters:
    ///   - userId: The user ID you want to unblock.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func removeUserFromBlackList(userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Get the device ID array of all current user logins except the current device.
    /// - Parameter completion: Callback, if successful it will return a string array of user id, if it fails it will return an error.
    func deviceIdsOnOtherPlatformOfCurrentUser(completion: @escaping (ChatError?,[String]) -> Void)
}

@objc public protocol ContactEventsResponse: NSObjectProtocol {
    
    /// The friend request was accepted by the other party
    /// - Parameter userId: Friend user id
    func friendRequestDidAgree(by userId: String)
    
    /// Friend request was rejected by the other party
    /// - Parameter userId: Friend user id
    func friendRequestDidDecline(by userId: String)
    
    /// The friend relationship was removed by the other party
    /// - Parameter userId: Friend user id
    func friendshipDidRemove(by userId: String)
    
    /// Friend relationship added successfully
    /// - Parameter userId: Friend user id
    func friendshipDidAddSuccessful(by userId: String)
    
    /// Received friend request
    /// - Parameter userId: Friend user id
    func friendRequestDidReceive(by userId:String)
}
