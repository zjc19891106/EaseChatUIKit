//
//  ConversationBinder.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/14.
//

import Foundation


/// Bind service and driver
@objc public class ConversationBinder: NSObject {
    
    /// Map to store session settings do not disturb.
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Int>()) private var muteMap
    
    /// When conversation clicked.
    public var toChat: ((IndexPath,ConversationInfo) -> Void)?
    
    private var provider_OC: EaseProfileProviderOC?
    
    private var provider: EaseProfileProvider?
    
    /// ``ConversationBinder`` init method.
    /// - Parameter providerOC: Only available in Objective-C language.
    @objc public required convenience init(providerOC: EaseProfileProviderOC?) {
        self.init()
        self.provider_OC = providerOC
    }
    
    /// ``ConversationBinder`` init method.
    /// - Parameter providerOC: Only available in Swift language.
    public required convenience init(provider: EaseProfileProvider?) {
        self.init()
        self.provider = provider
    }
    
    private weak var driver: IConversationListDriver?
    
    private var service: ConversationService? {
        didSet {
            self.service?.unbindConversationEventsListener(listener: self)
            self.service?.bindConversationEventsListener(listener: self)
        }
    }
    
    private var multiService: MultiDeviceService? {
        didSet {
            self.multiService?.unbindMultiDeviceListener(listener: self)
            self.multiService?.bindMultiDeviceListener(listener: self)
        }
    }
    
    /// Bind UI driver and service
    /// - Parameters:
    ///   - driver: The object of conform``IConversationListDriver``.
    ///   - service: The object of conform``ConversationService``.
    ///   - multi: The object of conform``MultiDeviceService``.
    func bind(driver: IConversationListDriver,service: ConversationService,multi: MultiDeviceService) {
        self.driver = driver
        self.service = service
        self.multiService = multi
        self.driver?.addActionHandler(actionHandler: self)
        self.loadExistLocalDataOtherwiseFetchServer()
    }
    
    func loadExistLocalDataOtherwiseFetchServer() {
        self.service?.loadExistConversations(completion: { [weak self] result, error in
            if error == nil {
                self?.driver?.refreshProfiles(infos: result)
            } else {
                consoleLogInfo("loadExistOtherwiseFetchServer error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    func destroyed() {
        self.service?.unbindConversationEventsListener(listener: self)
        self.multiService?.unbindMultiDeviceListener(listener: self)
        self.driver = nil
        self.service = nil
        self.multiService = nil
    }
    
    deinit {
        destroyed()
    }
}

//MARK: - ConversationListActionEventsDelegate
extension ConversationBinder: ConversationListActionEventsDelegate {
    public func onConversationListEndScrollNeededDisplayInfos(ids: [String]) {
        var privateChats = [String]()
        var groupChats = [String]()
        for id in ids {
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(id) {
                if conversation.type == .chat {
                    privateChats.append(id)
                } else {
                    groupChats.append(id)
                }
            }
        }
        if self.provider_OC != nil {
            let infoMap_OC = [0:privateChats,1:groupChats]
            self.provider_OC?.fetchProfiles(profilesMap: infoMap_OC, completion: { [weak self] profiles in
                self?.renderDriver(infos: profiles)
            })
        }
        if self.provider != nil {
            let infoMap = [ChatConversationType.chat:privateChats,ChatConversationType.groupChat:groupChats]
            Task(priority: .background) {
                let profiles = await self.provider?.fetchProfiles(profilesMap: infoMap) ?? []
                DispatchQueue.main.async {
                    self.renderDriver(infos: profiles)
                }
            }
        }
    }
    
    private func renderDriver(infos: [EaseProfileProtocol]) {
        self.driver?.refreshProfiles(infos: infos)
        if EaseChatUIKitClient.shared.option.option_chat.saveConversationInfo {
            for info in infos {
                let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(info.id)
                var ext = conversation?.ext
                ext?["EaseChatUIKit_avatarURL"] = info.avatarURL
                ext?["EaseChatUIKit_nickName"] = info.nickName
                conversation?.ext = ext
            }
        }
    }
    
    public func onConversationListRefresh() {
        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
            self.driver?.refreshList(infos: self.mapper(objects: infos))
        }
    }
    
    public func onConversationSwipe(type: UIContextualActionType, info: ConversationInfo) {
        if let hooker = ComponentsActionEventsRegister.Conversation.swipeAction {
            hooker(type, info)
        } else {
            switch type {
            case .pin: self.service?.pin(conversationId: info.id) { [weak self] error in
                guard let `self` = self else { return }
                    if error != nil {
                        consoleLogInfo("onConversationSwipe pin:\(error?.errorDescription ?? "")", type: .error)
                    } else {
                        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                            self.driver?.refreshList(infos: self.mapper(objects: infos))
                        }
                    }
                }
            case .unpin: self.service?.unpin(conversationId: info.id) { [weak self] error in
                guard let `self` = self else { return }
                    if error != nil {
                        consoleLogInfo("onConversationSwipe unpin:\(error?.errorDescription ?? "")", type: .error)
                    } else {
                        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                            self.driver?.refreshList(infos: self.mapper(objects: infos))
                        }
                    }
                }
            case .mute: self.service?.setSilentMode(conversationId: info.id) { [weak self] _, error in
                    if error != nil {
                        consoleLogInfo("onConversationSwipe mute:\(error?.errorDescription ?? "")", type: .error)
                    } else {
                        info.noDisturb = true
                        self?.driver?.swipeMenuOperation(info: info, type: .mute)
                    }
                }
            case .unmute: self.service?.clearSilentMode(conversationId: info.id) { [weak self] _, error in
                    if error != nil {
                        consoleLogInfo("onConversationSwipe unmute:\(error?.errorDescription ?? "")", type: .error)
                    } else {
                        info.noDisturb = false
                        self?.driver?.swipeMenuOperation(info: info, type: .unmute)
                    }
                }
            case .delete: self.service?.deleteConversation(conversationId: info.id) { [weak self] error in
                guard let `self` = self else { return }
                    if error != nil {
                        consoleLogInfo("onConversationSwipe delete:\(error?.errorDescription ?? "")", type: .error)
                    } else {
                        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                            self.driver?.refreshList(infos: self.mapper(objects: infos))
                        }
                    }
                }
            case .read:
                info.unreadCount = 0
                self.driver?.swipeMenuOperation(info: info, type: .read)
                self.service?.markAllMessagesAsRead()
            case .more: self.moreAction(info: info)
            }
        }
    }
    
    public func onConversationDidSelected(indexPath: IndexPath, info: ConversationInfo) {
        if let hooker = ComponentsActionEventsRegister.Conversation.didSelected {
            hooker(indexPath,info)
        } else {
            self.toChat?(indexPath,info)
        }
    }
    
    public func onConversationLongPressed(indexPath: IndexPath, info: ConversationInfo) {
        if let hooker = ComponentsActionEventsRegister.Conversation.longPressed {
            hooker(indexPath,info)
        } else {
            consoleLogInfo("onConversationLongPressed", type: .debug)
        }
    }
    
    private func moreAction(info: ConversationInfo) {
        DialogManager.shared.showMessageActions(actions: Appearance.Conversation.moreActions) { item in
            item.action?(item)
        }
    }
}

//MARK: - ConversationServiceListener
extension ConversationBinder: ConversationServiceListener {
    public func onConversationLastMessageUpdate(message: ChatMessage, info: ConversationInfo) {
        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
            self.driver?.refreshList(infos: self.mapper(objects: infos))
        }
    }
    
    
    public func onChatConversationListDidChanged(list: [ConversationInfo]) {
        consoleLogInfo("onChatConversationListDidChanged", type: .debug)
    }
    
    public func onConversationMessageAlreadyReadOnOtherDevice(info: ConversationInfo) {
        self.driver?.swipeMenuOperation(info: info, type: .read)
    }
    
}

//MARK: - MultiDeviceListener
extension ConversationBinder: MultiDeviceListener {
    public func onConversationEventDidChanged(event: MultiDeviceEvent, conversationId: String, conversationType: ChatConversationType) {
        switch event {
        case .conversationPinned,.conversationUnpinned,.conversationDelete:
            if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                self.driver?.refreshList(infos: self.mapper(objects: infos))
            }
        default: break
        }
    }
    
    private func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
        objects.map {
            let conversation = ConversationInfo()
            conversation.id = $0.conversationId
            conversation.unreadCount = Int($0.unreadMessagesCount)
            conversation.lastMessage = $0.latestMessage
            conversation.type = $0.type
            conversation.pinned = $0.isPinned
            if EaseChatUIKitClient.shared.option.option_chat.saveConversationInfo {
                if let nickName = $0.ext["EaseChatUIKit_nickName"] as? String {
                    conversation.nickName = nickName
                }
                if let avatarURL = $0.ext["EaseChatUIKit_avatarURL"] as? String {
                    conversation.avatarURL = avatarURL
                }
            }
            conversation.noDisturb = false
            if let silentMode = self.muteMap[$0.conversationId] {
                conversation.noDisturb = silentMode != 0
            }
            return conversation
        }
    }
}
