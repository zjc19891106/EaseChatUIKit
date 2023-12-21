//
//  JoinedGroupsViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objcMembers open class JoinedGroupsViewController: UIViewController {
    
    private let groupService = GroupServiceImplement()
    
    private var page = UInt(0)
    
    private var loadFinished = false
    
    public private(set) var datas: [EaseProfileProtocol] = [] {
        didSet {
            if self.datas.count <= 0 {
                self.groupList.backgroundView = self.empty
            } else {
                self.groupList.backgroundView = nil
            }
        }
    }
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true, textAlignment: .left, hiddenAvatar: true).backgroundColor(.clear)
    }()
    
    public private(set) lazy var groupList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY+10, width: self.view.frame.width, height: self.view.frame.height-self.navigation.frame.maxY-10), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).backgroundColor(.clear)
    }()
    
    private lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.groupList.frame.width, height: self.groupList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil), onRetry: { [weak self] in
            self?.requestGroups()
        }).backgroundColor(.clear)
    }()
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.navigation.title = "Groups".chat.localize
        self.view.addSubViews([self.navigation,self.groupList])
        //Back button click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.requestGroups()
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        default: break
        }
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func requestGroups() {
        if !self.loadFinished {
            self.groupService.getJoinedGroups(page: self.page, pageSize: 20, needMemberCount: true, needRole: true) { [weak self] groups, error in
                guard let `self` = self else { return }
                if error == nil {
                    if let groups = groups {
                        self.datas.append(contentsOf: groups.map({
                            let profile = EaseProfile()
                            profile.id = $0.groupId
                            profile.nickName = $0.groupName
                            return profile
                        }))
                        self.groupList.reloadData()
                        if groups.count >= 20 {
                            self.page += 1
                        } else {
                            self.loadFinished = true
                        }
                    }
                } else {
                    consoleLogInfo("requestGroups error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        }
    }

}


extension JoinedGroupsViewController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GroupListCell") as? GroupListCell
        if cell == nil {
            cell = GroupListCell(style: .default, reuseIdentifier: "GroupListCell")
        }
        if let group = self.datas[safe: indexPath.row] {
            cell?.refresh(info: group, keyword: "")
        }
        cell?.selectionStyle = .none
        return cell ?? NewContactRequestCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let group = self.datas[safe: indexPath.row] {
            self.chatTo(group: group.id)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > self.datas.count-3,!self.loadFinished {
            self.requestGroups()
        }
    }
    
    private func chatTo(group: String) {
        let vc = GroupInfoViewController(group: group) { [weak self] groupId, name in
            self?.refreshGroup(groupId: groupId, name: name)
        }
        ControllerStack.toDestination(vc: vc)
    }
    
    private func refreshGroup(groupId: String,name: String) {
        var idx = 0
        for (index,profile) in self.datas.enumerated() {
            if profile.id == groupId {
                idx = index
                profile.nickName = name
                break
            }
        }
        self.groupList.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
    }
}


extension JoinedGroupsViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
