//
//  GroupService.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import Foundation

@objc public protocol GroupService: NSObjectProtocol {
    
    /// Bind group event  changed listener
    /// - Parameter listener: ``GroupServiceListener``
    func bindGroupEventsListener(listener: GroupServiceListener)
    
    /// Unbind group event changed listener
    /// - Parameter listener: ``GroupServiceListener``
    func unbindGroupEventsListener(listener: GroupServiceListener)
    //MARK: - Create&List
    
    /// Create a group.
    /// - Parameters:
    ///   - subject: Group's subject.
    ///   - description: Group's description.
    ///   - inviterIds: Array of user IDs of users invited by the group owner.
    ///   - message: Invitation extension
    ///   - option: ``ChatGroupOption``
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func createGroup(subject: String,description: String,inviterIds: [String],message: String,option: ChatGroupOption,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Get joined groups.
    /// - Parameters:
    ///   - page: Page number.
    ///   - pageSize: Size number of the page.
    ///   - needMemberCount: Whether the number of returned group members is included in the group object in the callback.
    ///   - needRole: Whether the current user role of returned group in the group object in the callback.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty  `Array<ChatGroup>` object will be returned.
    func getJoinedGroups(page: UInt,pageSize: UInt,needMemberCount: Bool,needRole: Bool,completion: @escaping ([ChatGroup]?,ChatError?) -> Void)
    //MARK: - operator user
    
    /// Invite users.
    /// - Parameters:
    ///   - userIds: Array of user IDs of users invited.
    ///   - groupId: ID of the group.
    ///   - message: Invitation extension
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func invite(userIds: [String],to groupId: String, message: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Remove a user.
    /// - Parameters:
    ///   - userIds: Array of user IDs of users removed.
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func remove(userIds: [String],from groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Add an admin to the group.
    /// - Parameters:
    ///   - userId: ID of the user.
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func addAdmin(userId: String,to groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Remove an admin from the group.
    /// - Parameters:
    ///   - userId: ID of the user.
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func removeAdmin(userId: String,from groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Mute a user.
    /// - Parameters:
    ///   - userIds: ID of the user.
    ///   - duration: Mute time range.
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func mute(userIds: [String],duration: TimeInterval,groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Unmute a user.
    /// - Parameters:
    ///   - userIds: ID of the user.
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func unmute(userIds: [String],groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    //MARK: - Group detail
    
    /// Get announcement of the group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func getAnnouncement(groupId: String,completion: @escaping (String?,ChatError?) -> Void)
    
    /// Update announcement of the group.
    /// - Parameters:
    ///   - announcement: Announcement content.
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func update(announcement: String,groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Update extended information in group objects.
    /// - Parameters:
    ///   - extension: Extended information in group objects
    ///   - groupId: ID of the group.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func update(ext: String,groupId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    //MARK: - Invite&Apply
    
    /// Agree the application of the user.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func agreeJoinApplication(groupId: String,userId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Decline the application of the user.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    ///   - reason: Reason for rejection.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func declineJoinApplication(groupId: String,userId: String,reason: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Accept an invitation to join a group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - inviterId: ID of the inviter.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned. If failed, a non-empty group object will be returned.
    func acceptInvitation(groupId: String,inviterId: String,completion: @escaping (ChatGroup?,ChatError?) -> Void)
    
    /// Decline an invitation to join a group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - inviterId: ID of the inviter.
    ///   - reason: Reason for rejection.
    ///   - completion: The request callback contains the group object and error information. If successful, a non-empty group object will be returned.
    func declineInvitation(groupId: String,inviterId: String,reason: String,completion: @escaping (ChatError?) -> Void)
    //MARK: - group member attribute
    
    /// Set custom properties for group members. (You and administrators and above can call this method)
    /// - Parameters:
    ///   - attributes: Attributes map.
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    ///   - completion: The request callback contains the group object and error information. If successful, a empty error object will be returned. If failed, a non-empty group object will be returned.
    func setMemberAttributes(attributes: Dictionary<String,String>,groupId: String,userId: String,completion: @escaping (ChatError?) -> Void)
    
    /// Get individual group member attributes.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    ///   - completion: The request callback contains the group object and error information. If successful, a empty error object will be returned. If failed, a non-empty group object will be returned.
    func fetchMemberAttribute(groupId: String,userId: String,completion: @escaping (ChatError?,Dictionary<String,String>?) -> Void)
    
    /// Get custom attributes of multiple group members
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userIds: The id array of multiple group members to be obtained.
    ///   - keys: You want fetch attribute keys .
    ///   - completion: The request callback contains the group object and error information. If successful, a empty error object will be returned. If failed, a non-empty group object will be returned.
    func fetchMembersAttribute(groupId: String,userIds: [String],keys:[String],completion: @escaping (ChatError?,Dictionary<String,Dictionary<String,String>>?) -> Void)
}

@objc public protocol GroupServiceListener: NSObjectProtocol {
    
    /// Received new group invitation
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - groupName: Name of the group.
    ///   - userId: ID of the inviter.
    ///   - invitation: Invitation extension.
    func onReceivedNewGroupInvitation(groupId: String,groupName: String,userId: String,invitation: String)
    
    /// Accepted invitation of the group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    func onInviterAcceptedInvitationOfGroup(groupId: String,userId: String)
    
    /// When a group invitation is rejected
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    ///   - reason: Reason for rejection.
    func onInviterDeclinedInvitationOfGroup(groupId: String,userId: String,reason: String)
    
    /// The current user is added to the group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - invitation: Invitation extension.
    func onCurrentUserJoinedGroup(groupId: String,invitation: String)
    
    /// Current user is removed.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - reason: Reason for removed.
    func onCurrentUserLeft(groupId: String,reason: GroupLeaveReason)
    
    /// Received new group invitation
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the inviter.
    ///   - reason: reason
    func onReceivedNewGroupApplication(groupId: String,userId: String,reason: String)
    
    /// Application to join the group was rejected
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - reason: Reason for rejection.
    func onGroupJoinApplicationDeclined(groupId: String,reason: String)
    
    /// The application to join the group was approved.
    /// - Parameters:
    ///   - groupId: ID of the group.
    func onGroupJoinApplicationApproved(groupId: String)
    
    /// The group owner of the current group has changed.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - ownerId: ID of the group owner.
    ///   - userId: ID of the user.
    func onGroupOwnerUpdated(groupId: String,ownerId: String,userId: String)
    
    /// When some user joined group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    func onUserJoinedGroup(groupId: String,userId: String)
    
    /// When some user left group.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    func onUserLeaveGroup(groupId: String,userId: String)
    
    /// When attributes changed of some group member.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    ///   - operatorId: ID of the opeartor.
    ///   - attributes: Changed user attribute dictionary。
    func onAttributesChangedOfGroupMember(groupId: String,userId: String,operatorId: String,attributes: Dictionary<String,String>)
    
}
