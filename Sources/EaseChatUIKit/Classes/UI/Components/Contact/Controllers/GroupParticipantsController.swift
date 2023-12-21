//
//  GroupParticipantsController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/27.
//

import UIKit

@objc open class GroupParticipantsController: UIViewController {
    
    private var pageSize = UInt(200)
    
    private var recursiveCount = 5
    
    private let service: GroupService = GroupServiceImplement()
    
    private var cursor = ""
    
    private var loadFinished = false
    
    public private(set) var participants: [EaseProfileProtocol] = []
    
    public private(set) var chatGroup = ChatGroup()
    
    public var mentionClosure: ((EaseProfileProtocol) -> Void)?
    
    public private(set) var mention = false
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: self.mention ? CGRect(x: 0, y: 0, width: ScreenWidth, height: 44):CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight),showLeftItem: true, textAlignment: .left, rightImages:  self.rightImages ,hiddenAvatar: true).backgroundColor(.clear)
    }()
    
    private var rightImages: [UIImage] {
        ((self.chatGroup.owner == EaseChatUIKitContext.shared?.currentUserId ?? "" && !self.chatGroup
            .isDisabled)&&self.mention == false) ? [UIImage(named: "person_add", in: .chatBundle, with: nil)!,UIImage(named: "members_remove", in: .chatBundle, with: nil)!]:[]
    }
    
    public private(set) lazy var participantsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.height, width: self.view.frame.width, height: self.view.frame.height-self.navigation.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).backgroundColor(.clear)
    }()
    
    @objc required public convenience init(groupId: String,mention: Bool = false) {
        self.init()
        self.chatGroup = ChatGroup(id: groupId)
        self.mention = mention
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.theme.neutralColor98
        
        self.navigation.title = "group_details_button_members".chat.localize
        self.view.addSubViews([self.navigation,self.participantsList])
        // Do any additional setup after loading the view.
        //click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        self.fetchParticipants()
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        default:
            break
        }
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: self.toAdd()
        case 1: self.toRemove()
        default:
            break
        }
    }
    
    private func ignoreContacts() -> [String] {
        let contacts = ChatClient.shared().contactManager?.getContacts() ?? []
        var ignoreIds = [String]()
        for participant in self.participants {
            for id in contacts {
                if id == participant.id {
                    ignoreIds.append(id)
                }
            }
        }
        return ignoreIds
    }
    
    private func toAdd() {
        let vc = ContactViewController(headerStyle: .addGroupParticipant,provider: nil,ignoreIds: self.ignoreContacts())
        vc.confirmClosure = { [weak self] users in
            guard let `self` = self else { return }
            vc.navigationController?.popViewController(animated: true)
            self.service
                .invite(userIds: [users.first?.id ?? ""], to: self.chatGroup.groupId, message: "", completion: { [weak self] group, error in
                    if error == nil {
                        self?.participants.append(contentsOf: users)
                        self?.participantsList.reloadData()
                        self?.pop()
                    } else {
                        consoleLogInfo("Add participants  error:\(error?.errorDescription ?? "")", type: .error)
                    }
                })
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func toRemove() {
        let vc = GroupParticipantsRemoveController(group: self.chatGroup, profiles: self.participants.filter({ $0.id != self.chatGroup.owner })) { [weak self] userIds in
            guard let `self` = self else { return }
            self.service.remove(userIds: userIds, from: self.chatGroup.groupId) { [weak self] group, error in
                if error == nil {
                    for id in userIds {
                        if let index = self?.participants.firstIndex(where: { $0.id == id }) {
                            self?.participants.remove(at: index)
                            self?.participantsList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        }
                    }
                } else {
                    consoleLogInfo("remove participants error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        }
        ControllerStack.toDestination(vc: vc)
    }

    private func fetchParticipants() {
        if self.recursiveCount > 0 {
            self.service.fetchParticipants(groupId: self.chatGroup.groupId, cursor: self.cursor, pageSize: self.pageSize) { [weak self] result, error in
                guard let `self` = self else { return }
                if error == nil {
                    if let list = result?.list {
                        if self.cursor.isEmpty {
                            self.participants.removeAll()
                            self.participants = list.map({
                                let profile = EaseProfile()
                                profile.id = $0 as String
                                profile.nickName = $0 as String
                                return profile
                            })
                            if list.count == self.pageSize {
                                let profile = EaseProfile()
                                profile.id = self.chatGroup.owner
                                profile.nickName = self.chatGroup.owner
                                self.participants.insert(profile, at: 0)
                            }
                        } else {
                            self.participants.append(contentsOf: list.map({
                                let profile = EaseProfile()
                                profile.id = $0 as String
                                return profile
                            }))
                        }
                    }
                    self.cursor = result?.cursor ?? ""
                    self.participantsList.reloadData()
                    self.recursiveCount -= 1
                    self.fetchParticipants()
                } else {
                    consoleLogInfo("GroupParticipantsController fetch error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        } else {
            if self.mention {
                let profile = EaseProfile()
                profile.id = "All"
                profile.nickName = "All"
                self.participants.insert(profile, at: 0)
            }
            self.participantsList.reloadData()
        }
    }
}


extension GroupParticipantsController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.participants.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GroupParticipantCell") as? GroupParticipantCell
        if cell == nil {
            cell = GroupParticipantCell(displayStyle: .normal, identifier: "GroupParticipantCell")
        }
        if let profile = self.participants[safe: indexPath.row] {
            cell?.refresh(profile: profile, keyword: "")
        }
        cell?.selectionStyle = .none
        return cell ?? GroupParticipantCell()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var unknownInfoIds = [String]()
        if let visiblePaths = self.participantsList.indexPathsForVisibleRows {
            for indexPath in visiblePaths {
                if let nickName = self.participants[safe: indexPath.row]?.nickName,nickName.isEmpty {
                    unknownInfoIds.append(self.participants[safe: indexPath.row]?.id ?? "")
                }
            }
        }
        if !unknownInfoIds.isEmpty {
            if EaseChatUIKitContext.shared?.groupMemberAttributeCache?.provider == nil,EaseChatUIKitContext.shared?.groupMemberAttributeCache?.providerOC == nil {
                EaseChatUIKitContext.shared?.groupMemberAttributeCache?.fetchCacheValue(groupId: self.chatGroup.groupId, userIds: unknownInfoIds, key: "nickName") { [weak self] error, values in
                    if error == nil,let values = values {
                        self?.processCacheInfos(values: values)
                    }
                }
            } else {
                if EaseChatUIKitContext.shared?.groupMemberAttributeCache?.provider != nil {
                    self.processCacheProfiles(values: EaseChatUIKitContext.shared?.groupMemberAttributeCache?.fetchCacheProfile(groupId: self.chatGroup.groupId, userIds: unknownInfoIds) ?? [])
                } else {
                    EaseChatUIKitContext.shared?.groupMemberAttributeCache?.fetchCacheProfileOC(groupId: self.chatGroup.groupId, userIds: unknownInfoIds) { [weak self] profiles in
                        self?.processCacheProfiles(values: profiles)
                    }
                }
            }
        }
    }
    
    private func processCacheInfos(values: [String]) {
        for participant in self.participants {
            for value in values {
                if value == participant.id {
                    participant.nickName = value
                }
            }
        }
        self.participantsList.reloadData()
    }
    
    private func processCacheProfiles(values: [EaseProfileProtocol]) {
        for participant in self.participants {
            for value in values {
                if value.id == participant.id {
                    participant.nickName = value.nickName
                    participant.avatarURL = value.avatarURL
                }
            }
        }
        self.participantsList.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let profile = self.participants[safe: indexPath.row] {
            if !self.mention {
                let vc = ContactInfoViewController(profile: profile)
                ControllerStack.toDestination(vc: vc)
            } else {
                self.mentionClosure?(profile)
                self.pop()
            }
        }
    }
}

extension GroupParticipantsController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
