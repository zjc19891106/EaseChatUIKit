//
//  ContactInfoViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/21.
//

import UIKit

@objc open class ContactInfoViewController: UIViewController {
    
    public let service = ContactServiceImplement()
    
    public private(set) var profile: EaseProfileProtocol = EaseProfile()
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    public private(set) lazy var datas: [DetailInfo] = {
        [["title":"contact_details_switch_donotdisturb".chat.localize,"detail":"","withSwitch": true,"switchValue":self.muteMap[EaseChatUIKitContext.shared?.currentUser?.userId ?? ""]?[self.profile.id] ?? 0 == 1],["title":"contact_details_button_clearchathistory".chat.localize,"detail":"","withSwitch": false,"switchValue":false]].map {
            let info = DetailInfo()
            info.setValuesForKeys($0)
            return info
        }
    }()
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true,rightImages: [UIImage(named: "more_detail", in: .chatBundle, with: nil)!],hiddenAvatar: true).backgroundColor(.clear)
    }()
    
    public private(set) lazy var header: DetailInfoHeader = {
        DetailInfoHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 264), placeHolder: UIImage(named: "single", in: .chatBundle, with: nil)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).tableHeaderView(self.header)
    }()
    
    @objc public required convenience init(profile: EaseProfileProtocol) {
        self.init()
        self.profile = profile
    }
    
    @MainActor @objc public func updateUserState(state: UserState) {
        self.header.userState = state
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.navigation,self.menuList])
        if !self.profile.avatarURL.isEmpty {
            self.header.avatarURL = self.profile.avatarURL
        }
        self.header.nickName.text = self.profile.nickName
        self.header.userState = .offline
        self.header.detailText = self.profile.id
        //Back button click of the navigation
        self.navigation.leftItemClick = { [weak self] in
            self?.pop()
        }
        //Right buttons click of the navigation
        self.navigation.rightItemsClick = { [weak self] in
            self?.rightActions(indexPath: $0)
        }
        
    }
    
    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            DialogManager.shared.showActions(actions: Appearance.Contact.moreActions) { [weak self] item in
                guard let `self` = self else { return }
                self.service.removeContact(userId: self.profile.id, removeChannel: true) { [weak self] error, userId in
                    if error == nil {
                        self?.pop()
                    } else {
                        consoleLogInfo("ContactInfoViewController delete contact error:\(error?.errorDescription ?? "")", type: .error)
                    }
                }
            }
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

}

extension ContactInfoViewController: UITableViewDelegate,UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoListCell") as? DetailInfoListCell
        if cell == nil {
            cell = DetailInfoListCell(style: .default, reuseIdentifier: "DetailInfoListCell")
        }
        cell?.indexPath = indexPath
        if let info = self.datas[safe: indexPath.row] {
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
        if let name = self.datas[safe: indexPath.row]?.title {
            if name == "contact_details_switch_donotdisturb".chat.localize {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EaseUIKit_do_not_disturb_changed"), object: nil,userInfo: ["id":self.profile.id,"value":isOn])
            }
        }
    }
}
