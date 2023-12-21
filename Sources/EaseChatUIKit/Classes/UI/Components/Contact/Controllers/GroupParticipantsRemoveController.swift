//
//  GroupParticipantsRemoveController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/27.
//

import UIKit

@objc open class GroupParticipantsRemoveController: UIViewController {
    
    private let service: GroupService = GroupServiceImplement()
    
    private var deleteClosure: (([String]) -> Void)?
    
    public private(set) var chatGroup = ChatGroup()
    
    public private(set) var participants: [EaseProfileProtocol] = []
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(textAlignment: .left,rightTitle: "conversation_left_slide_menu_delete".chat.localize)
    }()
    
    public private(set) lazy var participantsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).backgroundColor(.clear)
    }()
    
    @objc required public convenience init(group: ChatGroup,profiles: [EaseProfileProtocol],removeClosure: @escaping ([String]) -> Void) {
        self.init()
        self.chatGroup = group
        self.participants = profiles
        self.deleteClosure = removeClosure
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.title = "remove_participants".chat.localize
        self.navigation.rightItem.textColor(UIColor.theme.errorColor5, .normal)
        self.navigation.rightItem.title("Remove".chat.localize, .normal)
        self.navigation.rightItem.isEnabled = false
        self.view.addSubViews([self.participantsList,self.navigation])
        // Do any additional setup after loading the view.
        //Back button click of the navigation
        
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
    
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightTitle: self.rightAction()
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

    private func rightAction() {
        let userIds = self.participants.filter { $0.selected == true }.map { $0.id }
        let nickNames = self.participants.filter { $0.selected == true }.map { $0.nickName }
        var removeAlert = "\("group_delete_members_alert".chat.localize) \(userIds.count) \("group members".chat.localize) "
        if nickNames.count > 1 {
            removeAlert += "\(nickNames.first) , \(nickNames[1])"
        } else {
            removeAlert += "\(nickNames.first)"
        }
        DialogManager.shared.showAlert(title: "", content: removeAlert, showCancel: true, showConfirm: true) { [weak self] _ in
            guard let `self` = self else { return }
            self.service.remove(userIds: userIds, from: self.chatGroup.groupId) { [weak self] group, error in
                if error != nil {
                    consoleLogInfo("\(error?.errorDescription ?? "")", type: .error)
                } else {
                    self?.deleteClosure?(userIds)
                    self?.pop()
                }
            }
        }
        
    }

}

extension GroupParticipantsRemoveController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.participants.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GroupParticipantsSelectCell") as? GroupParticipantsSelectCell
        if cell == nil {
            cell = GroupParticipantsSelectCell(style: .default, reuseIdentifier: "GroupParticipantsSelectCell")
        }
        if let profile = self.participants[safe: indexPath.row] {
            cell?.refresh(profile: profile, keyword: "")
        }
        cell?.selectionStyle = .none
        return cell ?? GroupParticipantCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let profile = self.participants[safe: indexPath.row] {
            profile.selected = !profile.selected
            tableView.reloadData()
        }
        let count = self.participants.filter({ $0.selected }).count
        if count > 0 {
            self.navigation.rightItem.isEnabled = true
            self.navigation.rightItem.title("Remove".chat.localize+"(\(count))", .normal)
        } else {
            self.navigation.rightItem.title("Remove".chat.localize, .normal)
            self.navigation.rightItem.isEnabled = false
        }
    }
}

extension GroupParticipantsRemoveController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
