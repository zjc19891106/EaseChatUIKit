//
//  GroupInfoViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objc open class GroupInfoViewController: UIViewController {
    
    private var chatGroup = ChatGroup()
    
    private let ownerOptions = [ActionSheetItem(title: "group_details_extend_button_disband".chat.localize, type: .destructive, tag: "disband_group"),ActionSheetItem(title: "group_details_extend_button_transfer".chat.localize, type: .destructive, tag: "disband_group")]
    
    private let memberOptions = [ActionSheetItem(title: "group_details_extend_button_leave".chat.localize, type: .destructive, tag: "quit_group")]
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true, textAlignment: .left, rightImages: [UIImage(named: "more_detail", in: .chatBundle, with: nil)!] ,hiddenAvatar: true).backgroundColor(.clear)
    }()
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    private lazy var jsons: [[Dictionary<String,Any>]] = {
        [[["title":"group_details_button_members".chat.localize,"detail":"\(self.chatGroup.occupantsCount)","withSwitch": false,"switchValue":false],["title":"group_details_button_alias".chat.localize,"detail":"0人","withSwitch": false,"switchValue":false],["title":"contact_details_switch_donotdisturb".chat.localize,"detail":"","withSwitch": true,"switchValue":self.muteMap[EaseChatUIKitContext.shared?.currentUser?.userId ?? ""]?[self.chatGroup.groupId] ?? 0 == 1],["title":"contact_details_button_clearchathistory".chat.localize,"detail":"","withSwitch": false,"switchValue":false]],[["title":"group_details_button_name".chat.localize,"detail":"\(self.chatGroup.occupantsCount)","withSwitch": false,"switchValue":false],["title":"group_details_button_description".chat.localize,"detail":self.chatGroup.description,"withSwitch": false,"switchValue":false]]]
    }()
    
    public private(set) lazy var datas: [[DetailInfo]] = {
        self.jsons.map {
            $0.map {
                let info = DetailInfo()
                info.setValuesForKeys($0)
                return info
            }
        }
    }()
    
    public private(set) lazy var header: DetailInfoHeader = {
        DetailInfoHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 264), placeHolder: UIImage(named: "group", in: .chatBundle, with: nil)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).tableHeaderView(self.header).sectionHeaderHeight(30).backgroundColor(.clear)
    }()
    
    
    @objc required public convenience init(group: ChatGroup) {
        self.init()
        self.chatGroup = group
        if group.owner == EaseChatUIKitContext.shared?.currentUser?.userId ?? "" {
            self.datas.removeLast()
        }
    }
    
    @MainActor @objc public func updateUserState(state: UserState) {
        self.header.userState = state
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.navigation.title = self.chatGroup.groupName
        self.view.addSubViews([self.navigation,self.menuList])
        // Do any additional setup after loading the view.
        //Back button click of the navigation
        self.navigation.leftItemClick = { [weak self] in
            self?.pop()
        }
        self.header.nickName.text = self.chatGroup.groupName
        self.header.userState = .offline
        self.header.detailText = self.chatGroup.groupId
        //Back button click of the navigation
        self.navigation.leftItemClick = { [weak self] in
            self?.pop()
        }
        //Right buttons click of the navigation
        self.navigation.rightItemsClick = { [weak self] in
            self?.rightActions(indexPath: $0)
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
        case 0:
            DialogManager.shared.showActions(actions: self.chatGroup.permissionType == .owner ? self.ownerOptions:self.memberOptions) { [weak self] item in
                guard let `self` = self else { return }
                
            }
        default:
            break
        }
    }

}


extension GroupInfoViewController: UITableViewDelegate,UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        self.datas.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas[safe: section]?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        section <= 0 ? UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)).backgroundColor(UIColor.theme.neutralColor95):nil
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoListCell") as? DetailInfoListCell
        if cell == nil {
            cell = DetailInfoListCell(style: .default, reuseIdentifier: "DetailInfoListCell")
        }
        cell?.indexPath = indexPath
        if let info = self.datas[safe: indexPath.section]?[safe: indexPath.row] {
            cell?.refresh(info: info)
        }
        cell?.valueChanged = { [weak self] in
            self?.switchChanged(isOn: $0, indexPath: $1)
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    private func switchChanged(isOn: Bool,indexPath: IndexPath) {
        if let name = self.datas[safe: indexPath.section]?[safe: indexPath.row]?.title {
            if name == "contact_details_switch_donotdisturb".chat.localize {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EaseUIKit_do_not_disturb_changed"), object: nil,userInfo: ["id":self.chatGroup.groupId,"value":isOn])
            }
        }
    }
}
