import Foundation

@objcMembers public class EaseChatUIKitOptions: NSObject {
    
    /// The option of UI components.
    public var option_UI: UIOptions = UIOptions()
    
    /// The option of chat sdk function.
    public var option_chat: ChatOptions = ChatOptions()
    
    @objcMembers public class ChatOptions: ChatSDKOptions {
        var withUserProperties = true
        
        var saveConversationInfo = true
    }
    
    @objcMembers public class UIOptions: NSObject {
        
    }
}

@objcMembers public class EaseChatUIKitClient: NSObject {
        
    public static let shared = EaseChatUIKitClient()
    
    
    /// User-related protocol implementation class.
    public private(set) lazy var userImplement: UserServiceProtocol? = nil
    
    /// Options function wrapper.
    public private(set) lazy var option: EaseChatUIKitOptions = EaseChatUIKitOptions()
    
    /// Initializes the chat room UIKit.
    /// - Parameters:
    ///   - appKey: The unique identifier that Chat assigns to each app. For details, see https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios#get-chat-project-information.
    /// Returns the initialization success or an error that includes the description of the cause of the failure.
    @objc public func setup(with appKey: String,option: EaseChatUIKitOptions.ChatOptions = EaseChatUIKitOptions.ChatOptions()) -> ChatError? {
        let option = EaseChatUIKitOptions.ChatOptions(appkey: appKey)
        option.enableConsoleLog = true
        option.isAutoLogin = false
        return ChatClient.shared().initializeSDK(with: option)
    }
    
    /// Login user.
    /// - Parameters:
    ///   - user: An instance that conforms to ``UserInfoProtocol``.
    ///   - token: The user chat token.
    ///   - userProperties: Whether the user passes in his or her own user information (including the avatar, nickname, and user ID) as user attributes for use in ChatRoom
    @objc public func login(user: UserInfoProtocol,token: String,completion: @escaping (ChatError?) -> Void) {
//        ChatroomContext.shared?.currentUser = user
//        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: self.option.option_chat.useProperties, completion: completion)
    }
    
    /// Login user id.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - token: The user chat token.
    ///   - completion: Login result.
    @objc public func login(userId: String,token: String,completion: @escaping (ChatError?) -> Void) {
        let user = User()
        user.userId = userId
//        ChatroomContext.shared?.currentUser = user
//        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: false, completion: completion)
//        self.userImplement?.bindUserStateChangedListener(listener: self)
    }
    
    /// Logout user
    @objc public func logout() {
        self.userImplement?.logout(completion: { _, _ in })
        self.userImplement?.unBindUserStateChangedListener(listener: self)
    }
}

extension EaseChatUIKitClient: UserStateChangedListener {
    public func onUserLoginOtherDevice(device: String) {
        
    }
    
    public func onUserTokenWillExpired() {
        
    }
    
    public func onUserTokenDidExpired() {
        
    }
    
    public func onSocketConnectionStateChanged(state: ConnectionState) {
        
    }
    
    public func userAccountDidRemoved() {
        
    }
    
    public func userDidForbidden() {
        
    }
    
    public func userAccountDidForcedToLogout(error: ChatError?) {
        
    }
    
    
}
