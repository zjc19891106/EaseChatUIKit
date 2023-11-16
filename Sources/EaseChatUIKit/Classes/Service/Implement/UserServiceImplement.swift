//
//  UserServiceImplement.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit

@objc public final class UserServiceImplement: NSObject {
        
    private var responseDelegates: NSHashTable<UserStateChangedListener> = NSHashTable<UserStateChangedListener>.weakObjects()
    
    /// Init method
    /// - Parameters:
    ///   - userInfo: ``UserInfoProtocol``
    ///   - token: Chat token
    ///   - completion: Callback,login successful or failure.
    @objc public init(userInfo: UserInfoProtocol,token: String,completion: @escaping (ChatError?) -> Void) {
        super.init()
        self.login(userId: userInfo.userId, token: token) { success, error in
            if !success {
                let errorInfo = error?.errorDescription ?? ""
                consoleLogInfo(errorInfo, type: .error)
                UIViewController.currentController?.showToast(toast: errorInfo, duration: 3)
            }
            completion(error)
        }
    }
    
    deinit {
        consoleLogInfo("\(self.swiftClassName ?? "") deinit", type: .debug)
    }

}

extension UserServiceImplement:UserServiceProtocol {
    
    public func bindUserStateChangedListener(listener: UserStateChangedListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unBindUserStateChangedListener(listener: UserStateChangedListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func userInfo(userId: String, completion: @escaping (UserInfoProtocol?,ChatError?) -> Void) {
        self.userInfos(userIds: [userId]) { infos,error in
            completion(infos.first,error)
        }
    }
    
    public func userInfos(userIds: [String], completion: @escaping ([UserInfoProtocol],ChatError?) -> Void) {
        ChatClient.shared().userInfoManager?.fetchUserInfo(byId: userIds,completion: { [weak self] infoMap, error in
            guard let dic = infoMap as? Dictionary<String,UserInfo> else { return }
            var users = [User]()
            for userId in userIds {
                if let info = dic[userId] {
                    if let user = self?.convertToUser(info: info) {
//                        ChatroomContext.shared?.usersMap?[userId] = user
                        users.append(user)
                    }
                }
            }
            completion(users,error)
        })
    }
    
    public func updateUserInfo(userInfo: UserInfoProtocol, completion: @escaping (Bool, ChatError?) -> Void) {
        ChatClient.shared().userInfoManager?.updateOwn(self.convertToUserInfo(user: userInfo),completion: { user, error in
            completion(error == nil,error)
        })
    }
    
    public func login(userId: String, token: String, completion: @escaping (Bool, ChatError?) -> Void) {
        if token.hasPrefix("00") {
            ChatClient.shared().login(withUsername: userId, agoraToken: token) { user_id, error in
                completion(error == nil,error)
            }
        } else {
            ChatClient.shared().login(withUsername: userId, token: token) { user_id, error in
                completion(error == nil,error)
            }
        }
    }
    
    public func logout(completion: @escaping (Bool, ChatError?) -> Void) {
        ChatClient.shared().logout(false)
        completion(true,nil)
    }
    
    private func convertToUser(info: UserInfo) -> User {
        let user = User()
        user.userId = info.userId ?? ""
        user.nickName = info.nickname ?? ""
        user.avatarURL = info.avatarUrl ?? ""
        user.gender = info.gender
        if let ext = info.ext{
            let extMap = ext.chat.jsonToDictionary()
            if let identity = extMap["identity"] as? String {
                user.identity = identity
            }
        }
        return user
    }
    
    private func convertToUserInfo(user: UserInfoProtocol) -> UserInfo {
        let info = UserInfo()
        info.userId = user.userId
        info.nickname = user.nickName
        info.avatarUrl = user.avatarURL
        info.gender = user.gender
        //In addition to the existing user attribute fields in the UserInfo object of the SDK, other extended fields are placed in the ext map and serialized into json string to interact with other terminals.
        let ext = ["identity":user.identity].chat.jsonString
        info.ext = ext
        return info
    }
    
}

//MARK: - ChatClientDelegate
//MARK: - ChatClientDelegate
extension UserServiceImplement: ChatClientListener {
    public func tokenDidExpire(_ aErrorCode: ChatErrorCode) {
        for response in self.responseDelegates.allObjects {
            response.onUserTokenDidExpired()
        }
    }
    
    public func tokenWillExpire(_ aErrorCode: ChatErrorCode) {
        for response in self.responseDelegates.allObjects {
            response.onUserTokenWillExpired()
        }
    }
    
    public func userAccountDidLogin(fromOtherDevice aDeviceName: String?) {
        for response in self.responseDelegates.allObjects {
            if let device = aDeviceName {
                response.onUserLoginOtherDevice(device: device)
            }
        }
    }
    
    public func connectionStateDidChange(_ aConnectionState: ConnectionState) {
        for response in self.responseDelegates.allObjects {
            response.onSocketConnectionStateChanged(state: aConnectionState)
        }
    }
    
    public func userDidForbidByServer() {
        for response in self.responseDelegates.allObjects {
            response.userDidForbidden()
        }
    }
    
    public func userAccountDidRemoveFromServer() {
        for response in self.responseDelegates.allObjects {
            response.userAccountDidRemoved()
        }
    }
    
    public func userAccountDidForced(toLogout aError: ChatError?) {
        for response in self.responseDelegates.allObjects {
            response.userAccountDidForcedToLogout(error: aError)
        }
    }
}

@objcMembers final public class User:NSObject, UserInfoProtocol {
    
    public func toJsonObject() -> Dictionary<String, Any>? {
        ["userId":self.userId,"nickName":self.nickName,"avatarURL":self.avatarURL,"identity":self.identity,"gender":self.gender]
    }
    
    public var identity: String = ""
    
    public var userId: String = ""
    
    public var nickName: String = ""
    
    public var avatarURL: String = ""
    
    public var gender: Int = 1
    
    public var mute: Bool = false
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
}

