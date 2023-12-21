//
//  NewRequestViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objc open class NewContactRequestController: UIViewController {
        
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Double>()) private var newFriends
    
    private let contactService = ContactServiceImplement()
    
    private lazy var datas: [NewContactRequest] = {
        self.fillDatas()
    }()
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar( showLeftItem: true, textAlignment: .left, hiddenAvatar: true)
    }()
    
    public private(set) lazy var requestList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height), style: .plain).tableFooterView(UIView()).delegate(self).dataSource(self).rowHeight(Appearance.contact.rowHeight).backgroundColor(.clear)
    }()
    
    private lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.requestList.frame.width, height: self.requestList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil), onRetry: {
            
        }).backgroundColor(.clear)
    }()
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.title = "New Request".chat.localize
        self.datas.sort { $0.time > $1.time }
        self.view.addSubViews([self.navigation,self.requestList])
        // Do any additional setup after loading the view.
        //Back button click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        if self.datas.count <= 0 {
            self.requestList.backgroundView = self.empty
        } else {
            self.requestList.backgroundView = nil
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
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
    
    private func fillDatas() -> [NewContactRequest] {
        self.newFriends.map {
            let request = NewContactRequest()
            request.userId = $0.key
            request.time = $0.value
            return request
        }
    }
    
}

extension NewContactRequestController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewContactRequestCell") as? NewContactRequestCell
        if cell == nil {
            cell = NewContactRequestCell(style: .default, reuseIdentifier: "NewContactRequestCell")
        }
        if let request = self.datas[safe: indexPath.row] {
            cell?.refresh(request: request)
        }
        cell?.agreeClosure = { [weak self] in
            self?.agreeFriendRequest(userId: $0)
        }
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = .clear
        cell?.selectionStyle = .none
        return cell ?? NewContactRequestCell()
    }
    
    private func agreeFriendRequest(userId: String) {
        self.contactService.agreeFriendRequest(from: userId) { error, userId in
            if error != nil {
                consoleLogInfo("agreeFriendRequest error: \(error?.errorDescription ?? "")", type: .error)
            } else {
                self.newFriends.removeValue(forKey: userId)
                let conversation = ChatClient.shared().chatManager?.getConversation(userId, type: .chat, createIfNotExist: true)
                let ext = ["something":("You have added".chat.localize+" "+userId+" "+"to say hello".chat.localize)]
                let message = ChatMessage(conversationID: userId, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
                conversation?.insert(message, error: nil)
                NotificationCenter.default.post(name: NSNotification.Name("New Friend Chat"), object: nil)
                self.datas.removeAll()
                self.datas = self.fillDatas()
                self.datas.sort { $0.time > $1.time }
                self.requestList.reloadData()
            }
        }
    }
}


extension NewContactRequestController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
