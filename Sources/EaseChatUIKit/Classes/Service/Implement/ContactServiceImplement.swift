//
//  ContactServiceImplement.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import UIKit

@objc public class ContactServiceImplement: NSObject {

    private var responseDelegates: NSHashTable<ContactEventsResponse> = NSHashTable<ContactEventsResponse>.weakObjects()
    
    @objc public override init() {
        super.init()
        ChatClient.shared().contactManager?.add(self, delegateQueue: .main)
    }
    
    deinit {
        ChatClient.shared().contactManager?.removeDelegate(self)
    }
}

extension ContactServiceImplement: ContactServiceProtocol {
    
    public func bindContactEventListener(listener: ContactEventsResponse) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindContactEventListener(listener: ContactEventsResponse) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func contacts(userIds: [String], completion: @escaping (ChatError?, [String]) -> Void) {
        ChatClient.shared().contactManager?.getContactsFromServer(completion: { ids, error in
            completion(error,ids ?? [])
        })
    }
    
    public func addContact(userId: String, invitation: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.addContact(userId, message: invitation, completion: { useId, error in
            completion(error,userId)
        })
    }
    
    public func removeContact(userId: String, removeChannel: Bool, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.deleteContact(userId, isDeleteConversation: removeChannel, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func agreeFriendRequest(from userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.approveFriendRequest(fromUser: userId, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func declineFriendRequest(from userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.declineFriendRequest(fromUser: userId, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func userBlackList(completion: @escaping (ChatError?, [String]) -> Void) {
        ChatClient.shared().contactManager?.getBlackListFromServer(completion: { userIds, error in
            completion(error,userIds ?? [])
        })
    }
    
    public func addUserToBlackList(userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.addUser(toBlackList: userId, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func removeUserFromBlackList(userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.removeUser(fromBlackList: userId, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func deviceIdsOnOtherPlatformOfCurrentUser(completion: @escaping (ChatError?, [String]) -> Void) {
        ChatClient.shared().contactManager?.getSelfIdsOnOtherPlatform(completion: { deviceIds, error in
            completion(error,deviceIds ?? [])
        })
    }
    
    
}

extension ContactServiceImplement: ContactEventsListener {
    
    public func friendshipDidAdd(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendshipDidAddSuccessful(by: aUsername)
        }
    }
    
    public func friendshipDidRemove(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendshipDidRemove(by: aUsername)
        }
    }
    
    public func friendRequestDidApprove(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidAgree(by: aUsername)
        }
    }
    
    public func friendRequestDidDecline(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidDecline(by: aUsername)
        }
    }
    
    public func friendRequestDidReceive(fromUser aUsername: String, message aMessage: String?) {
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidReceive(by: aUsername)
        }
    }
    
}
