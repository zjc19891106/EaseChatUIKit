import UIKit


/// When you
@objc open class ConversationListController: UIViewController {
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true,rightImages: [UIImage(named: "add", in: .chatBundle, with: nil)!])
    }()
    
    public private(set) lazy var search: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.navigation.frame.maxY+5, width: self.view.frame.width-32, height: 44)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).cornerRadius(.large).title(" Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var conversationList: ConversationList = {
        ConversationList(frame: CGRect(x: 0, y: self.search.frame.maxY, width: self.view.frame.width, height: ScreenHeight-NavigationHeight-44-BottomBarHeight), style: .plain)
    }()
    
    public private(set) var viewModel: ConversationViewModel = ConversationViewModel()
    
    /// ``ConversationListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - providerOC: The object of conform ``EaseProfileProviderOC``.
    @objc public required convenience init(providerOC: EaseProfileProviderOC? = nil) {
        self.init()
        self.viewModel = ConversationViewModel(providerOC: providerOC)
    }
    
    /// ``ConversationListController`` init method.Only available in Swift language.
    /// - Parameters:
    ///   - id: The id of the conversation.
    ///   - provider: The object of conform ``EaseProfileProvider``.
    public required convenience init(provider: EaseProfileProvider? = nil) {
        self.init()
        self.viewModel = ConversationViewModel(provider: provider)
    }
    
    /// Update navigation avatar url.
    /// - Parameter url: The url of avatar.
    @MainActor @objc public func updateAvatarURL(url: String) {
        self.navigation.avatarURL = url
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.search,self.conversationList])
        self.navigation.title = "Chats"
        //Bind UI driver and service
        self.viewModel.bind(driver: self.conversationList)
        //Conversation list click push to message list controller.
        self.viewModel.toChat = { [weak self] in
            self?.toChat(indexPath: $0, info: $1)
        }
        //Back button click of the navigation
        self.navigation.leftItemClick = { [weak self] in
            self?.pop()
        }
        //Right buttons click of the navigation
        self.navigation.rightItemsClick = { [weak self] in
            self?.rightActions(indexPath: $0)
        }
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        //If you want to listen for notifications about the success or failure of some requests and other events, you can add the following listeners
//        ConversationListController().viewModel.registerEventsListener(listener: <#T##ConversationEmergencyListener#>)
//        ConversationListController().viewModel.unregisterEventsListener(listener: <#T##ConversationEmergencyListener#>)
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func toChat(indexPath: IndexPath,info: ConversationInfo) {
        let vc = MessageListController()
        ControllerStack.toDestination(vc: vc)
    }
    
    @objc private func searchAction() {
        if self.navigationController != nil {
            self.navigationController?.pushViewController(SearchConversationsController(searchInfos: self.conversationList.datas), animated: true)
        } else {
            self.navigationController?.present(SearchConversationsController(searchInfos: self.conversationList.datas), animated: true)
        }
    }
    
    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            DialogManager.shared.showActions(actions: Appearance.Conversation.addActions) { item in
                switch item.tag {
                case "SelectContacts": self.selectContact()
                case "AddContact": self.addContact()
                case "CreateGroup": self.createGroup()
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    private func selectContact() {
        let vc = ContactViewController(headerStyle: .newChat,provider: nil)
        UIViewController.currentController?.presentingViewController?.present(vc, animated: true)
    }
    
    private func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content: 
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".chat.localize) { [weak self] text in
            self?.viewModel.contactService?.addContact(userId: text, invitation: "", completion: { error, userId in
                if let error = error {
                    consoleLogInfo("add contact error:\(error.errorDescription)", type: .error)
                }
            })
        }
    }
    
    private func createGroup() {
        let vc = ContactViewController(headerStyle: .newGroup,provider: nil)
        UIViewController.currentController?.presentingViewController?.present(vc, animated: true)
    }
}

extension ConversationListController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.search.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
    
}
