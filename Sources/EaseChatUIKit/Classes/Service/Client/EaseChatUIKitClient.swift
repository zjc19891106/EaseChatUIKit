import Foundation

@objcMembers public class EaseChatUIKitOptions: NSObject {
    
    /// The option of UI components.
    public var option_UI: UIOptions = UIOptions()
    
    /// The option of chat sdk function.
    public var option_chat: ChatOptions = ChatOptions()
    
    @objcMembers public class ChatOptions: ChatSDKOptions {
        
        /// Whether to store session avatars and nicknames in EaseChatUIKit.
        var saveConversationInfo = true
        
        /// Prioritize pulling messages from the server.
        var fetchServerHistoryMessages = false
        
        /// Whether to play a sound when new messages are received
        var soundOnReceivedNewMessage = true
        
        /// Whether load messages from local database.
        var loadHistoryMessages = true
    }
    
    @objcMembers public class UIOptions: NSObject {
        
    }
}

@objcMembers public class EaseChatUIKitClient: NSObject {
        
    public static let shared = EaseChatUIKitClient()
    
    /// User-related protocol implementation class.
    public private(set) lazy var userService: UserServiceProtocol? = nil
    
    /// Options function wrapper.
    public private(set) lazy var option: EaseChatUIKitOptions = EaseChatUIKitOptions()
    
    /// Initializes the chat room UIKit.
    /// - Parameters:
    ///   - appKey: The unique identifier that Chat assigns to each app.
    /// Returns the initialization success or an error that includes the description of the cause of the failure.
    @objc public func setup(with appKey: String,option: EaseChatUIKitOptions.ChatOptions = EaseChatUIKitOptions.ChatOptions()) -> ChatError? {
        let option = EaseChatUIKitOptions.ChatOptions(appkey: appKey)
        option.enableConsoleLog = true
        option.isAutoLogin = false
        return ChatClient.shared().initializeSDK(with: option)
    }
    
    /// Login user.
    /// - Parameters:
    ///   - user: An instance that conforms to ``EaseProfileProtocol``.
    ///   - token: The user chat token.
    @objc public func login(user: EaseProfileProtocol,token: String,completion: @escaping (ChatError?) -> Void) {
        EaseChatUIKitContext.shared?.currentUser = user
        self.userService = UserServiceImplement(userInfo: user, token: token, completion: completion)
    }
    
    /// Logout user
    @objc public func logout() {
        self.userService?.logout(completion: { _, _ in })
    }
    
    /// unregister theme.
    @objc public func unregisterThemes() {
        Theme.unregisterSwitchThemeViews()
    }
    
    /// Updates user information that is used for login with the `login(with user: UserInfoProtocol,token: String,use userProperties: Bool = true,completion: @escaping (ChatError?) -> Void)` method.
    /// - Parameters:
    ///   - info: An instance that conforms to ``EaseProfileProtocol``.
    ///   - completion: Callback.
    @objc public func updateUserInfo(info: EaseProfileProtocol,completion: @escaping (ChatError?) -> Void) {
        self.userService?.updateUserInfo(userInfo: info, completion: { success, error in
            completion(error)
        })
    }
    
    /// Registers a chat room event listener.
    /// - Parameter listener: ``UserStateChangedListener``
    @objc public func registerUserEventsListener(listener: UserStateChangedListener) {
        self.userService?.unBindUserStateChangedListener(listener: listener)
        self.userService?.bindUserStateChangedListener(listener: listener)
    }
    
    /// Unregisters a chat room event listener.
    /// - Parameter listener: ``UserStateChangedListener``
    @objc public func unregisterUserEventsListener(listener: UserStateChangedListener) {
        self.userService?.unBindUserStateChangedListener(listener: listener)
    }
    
    ///  Refreshes the user chat token when receiving the ``RoomEventsListener.onUserTokenWillExpired`` callback.
    /// - Parameter token: The user chat token.
    @objc public func refreshToken(token: String) {
        ChatClient.shared().renewToken(token)
    }
}

