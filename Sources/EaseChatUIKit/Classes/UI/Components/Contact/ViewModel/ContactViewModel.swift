//
//  ContactViewModel.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/21.
//

import UIKit

/// Bind service and driver
@objc open class ContactViewModel: NSObject {
    
    @objc public var viewContact: ((EaseProfileProtocol) -> Void)?
    
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Double>()) private var newFriends
    
    private var provider_OC: EaseProfileProviderOC?
    
    private var provider: EaseProfileProvider?
    
    /// ``ContactViewModel`` init method.
    /// - Parameter providerOC: Only available in Objective-C language.
    @objc public required convenience init(providerOC: EaseProfileProviderOC?) {
        self.init()
        self.provider_OC = providerOC
    }
    
    /// ``ContactViewModel`` init method.
    /// - Parameter providerOC: Only available in Swift language.
    public required convenience init(provider: EaseProfileProvider?) {
        self.init()
        self.provider = provider
    }
    
    public private(set) weak var driver: IContactListDriver?
    
    public private(set) weak var indicatorDriver: ISectionIndexListDriver?
    
    public private(set) var service: ContactServiceProtocol? = ContactServiceImplement()
    
    public private(set) var multiService: MultiDeviceService?  = MultiDeviceServiceImplement()
    
    /// Bind UI driver and service
    /// - Parameters:
    ///   - driver: The object of conform``IContactListDriver``.
    @objc public func bind(driver: IContactListDriver, indexDriver: ISectionIndexListDriver) {
        self.driver = driver
        self.indicatorDriver = indexDriver
        self.service?.unbindContactEventListener(listener: self)
        self.service?.bindContactEventListener(listener: self)
        self.multiService?.unbindMultiDeviceListener(listener: self)
        self.multiService?.bindMultiDeviceListener(listener: self)
        self.driver?.addActionHandler(actionHandler: self)
        self.loadAllContacts()
    }
    
    /// Register to monitor when certain emergencies occur
    /// - Parameter listener: ``ContactEmergencyListener``
    @objc public func registerEventsListener(listener: ContactEmergencyListener) {
        self.service?.registerEmergencyListener(listener: listener)
    }
    
    /// When you don’t want to listen to the registered events above, you can use this method to clear the registration.
    /// - Parameter listener: ``ContactEmergencyListener``
    @objc public func unregisterEventsListener(listener: ContactEmergencyListener) {
        self.service?.unregisterEmergencyListener(listener: listener)
    }
    
    @objc public func loadAllContacts() {
        self.service?.contacts(completion: { [weak self] error, contacts in
            if error == nil {
                let infos = contacts.map({
                    let profile = EaseProfile()
                    profile.id = $0.userId
                    profile.nickName = $0.remark ?? ""
                    profile.type = .contact
                    return profile
                })
                self?.driver?.refreshList(infos: infos)
                if let titles = self?.driver?.indexTitles() {
                    self?.indicatorDriver?.refresh(titles: titles)
                }
            } else {
                self?.driver?.occurError()
                consoleLogInfo("loadAllContacts error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
}

extension ContactViewModel: ContactEventsResponse {
    public func friendRequestDidAgree(by userId: String) {
        let profile = EaseProfile()
        profile.id = userId
        self.driver?.appendThenRefresh(info: profile)
    }
    
    public func friendRequestDidDecline(by userId: String) {
        
    }
    
    public func friendshipDidRemove(by userId: String) {
        let profile = EaseProfile()
        profile.id = userId
        self.driver?.remove(info: profile)
    }
    
    public func friendshipDidAddSuccessful(by userId: String) {
        
    }
    
    public func friendRequestDidReceive(by userId: String) {
        self.newFriends[userId] = Date().timeIntervalSince1970
        if let item = Appearance.Contact.headerExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
            item.showBadge = true
            item.numberCount = UInt(self.newFriends.count)
            self.driver?.refreshHeader(info: item)
        }
    }
    
    
}

extension ContactViewModel: MultiDeviceListener {
    
    public func onContactsEventDidChanged(event: MultiDeviceEvent, userId: String, extension info: String) {
        switch event {
        case .contactAccept:
            if self.newFriends.count > 0 {
                self.newFriends.removeValue(forKey: userId)
            }
        case .contactRemove:
            let profile = EaseProfile()
            profile.id = userId
            self.driver?.remove(info: profile)
        default:
            break
        }
    }
    
}

extension ContactViewModel: ContactListActionEventsDelegate {
    public func onContactListScroll(indexPath: IndexPath) {
        self.indicatorDriver?.selectItem(indexPath: indexPath)
    }
    
    public func onContactListOccurErrorWhenFetchServer() {
        self.loadAllContacts()
    }
    
    public func onContactListEndScrollNeededDisplayInfos(ids: [String]) {
        if self.provider_OC != nil {
            let infoMap_OC = [2:ids]
            self.provider_OC?.fetchProfiles(profilesMap: infoMap_OC, completion: { [weak self] profiles in
                self?.driver?.refreshProfiles(infos: profiles)
                if let titles = self?.driver?.indexTitles() {
                    self?.indicatorDriver?.refresh(titles: titles)
                }
            })
        }
        if self.provider != nil {
            let infoMap = [EaseProfileProviderType.contact:ids]
            Task(priority: .background) {
                let profiles = await self.provider?.fetchProfiles(profilesMap: infoMap) ?? []
                DispatchQueue.main.async {
                    self.driver?.refreshProfiles(infos: profiles)
                    if let titles = self.driver?.indexTitles() {
                        self.indicatorDriver?.refresh(titles: titles)
                    }
                }
            }
        }
    }
    
    
    public func didSelected(indexPath: IndexPath, profile: EaseProfileProtocol) {
        self.viewContact?(profile)
    }
    
}
