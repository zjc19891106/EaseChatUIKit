import UIKit

@objc open class ContactViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    public func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
    public private(set) var style = ContactListHeaderStyle.contact
    
    public lazy var searchContainer: ContactSearchResultController = {
        ContactSearchResultController(headerStyle: self.style) { [weak self] profile in
            self?.contactList.refreshProfiles(infos: [profile])
        }
    }()
    
    public private(set) lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.searchContainer)
        searchController.searchResultsUpdater = self.searchContainer
        searchController.delegate = self.searchContainer
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.showsSearchResultsController = true
        searchController.automaticallyShowsScopeBar = false
        searchController.searchBar.placeholder = " Search".chat.localize
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.frame = CGRect(x: 0, y: (self.style == .contact ? self.navigation.frame.maxY:10) + 5, width: self.view.frame.width, height: 44)
//        self.definesPresentationContext = true
        return searchController
    }()
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true,rightImages: [UIImage(named: "person_add", in: .chatBundle, with: nil)!]).backgroundColor(.white)
    }()
    
    public private(set) lazy var search: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: (self.style == .contact ? self.navigation.frame.maxY:10) + 5, width: self.view.frame.width-32, height: 44)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).cornerRadius(.large).title(" Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var contactList: ContactList = {
        ContactList(frame: CGRect(x: 0, y: self.search.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-self.search.frame.maxY-BottomBarHeight), style: .grouped,headerStyle: self.style).backgroundColor(.clear)
    }()
        
    public private(set) lazy var indexIndicator: SectionIndexList = {
        SectionIndexList(frame: CGRect(x: self.view.frame.width-16, y: self.search.frame.maxY+CGFloat(Appearance.Contact.headerExtensionActions.count)*Appearance.Contact.rowHeight+20, width: 16, height: 0), style: .plain).backgroundColor(.clear)
    }()
    
    public private(set) var viewModel: ContactViewModel = ContactViewModel()
    
    /// ``ContactListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - headerStyle: ``ContactListHeaderStyle``
    ///   - providerOC: The object of conform ``EaseProfileProviderOC``.
    @objc public required convenience init(headerStyle: ContactListHeaderStyle = .contact,providerOC: EaseProfileProviderOC? = nil) {
        self.init()
        self.style = headerStyle
        self.viewModel = ContactViewModel(providerOC: providerOC)
    }
    
    /// ``ContactListController`` init method.Only available in Swift language.
    /// - Parameters:
    ///   - headerStyle: ``ContactListHeaderStyle``.
    ///   - provider: The object of conform ``EaseProfileProvider``.
    public required convenience init(headerStyle: ContactListHeaderStyle = .contact,provider: EaseProfileProvider? = nil) {
        self.init()
        self.style = headerStyle
        self.viewModel = ContactViewModel(provider: provider)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if self.style == .contact {
            self.view.addSubViews([self.navigation,self.searchController.searchBar,self.contactList,self.indexIndicator])
        } else {
            self.view.addSubViews([self.searchController.searchBar,self.contactList,self.indexIndicator])
        }
        self.viewModel.bind(driver: self.contactList,indexDriver: self.indexIndicator)
        self.navigation.title = "Contact".chat.localize
        
        self.indexIndicator.selectClosure = { [weak self] in
            self?.contactList.scrollToRow(at: IndexPath(row: 0, section: $0.row), at: .middle, animated: true)
        }
        
        //Back button click of the navigation
        self.navigation.leftItemClick = { [weak self] in
            self?.pop()
        }
        //Right buttons click of the navigation
        self.navigation.rightItemsClick = { [weak self] in
            self?.rightActions(indexPath: $0)
        }
        //Push to ContactInfoViewController
        self.viewModel.viewContact = { [weak self] in
            self?.viewContact(profile: $0)
        }
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        //If you want to listen for notifications about the success or failure of some requests and other events, you can add the following listeners
//        ContactViewController().viewModel.registerEventsListener(listener: <#T##ConversationEmergencyListener#>)
//        ConversationListController().viewModel.unregisterEventsListener(listener: <#T##ConversationEmergencyListener#>)
        self.receiveContactHeaderAction()
        
    }
    
    private func receiveContactHeaderAction() {
        if let item = Appearance.Contact.headerExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
            item.actionClosure = { [weak self] _ in
                self?.viewNewFriendRequest()
            }
        }
        if let item = Appearance.Contact.headerExtensionActions.first(where: { $0.featureIdentify == "GroupChats" }) {
            item.actionClosure = { [weak self] _ in
                self?.viewJoinedGroups()
            }
        }
    }
    
    @objc private func searchAction() {
//        if self.navigationController != nil {
//            self.navigationController?.pushViewController(SearchConversationsController(searchInfos: self.conversationList.datas), animated: true)
//        } else {
//            self.navigationController?.present(SearchConversationsController(searchInfos: self.conversationList.datas), animated: true)
//        }
    }
    
    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: self.addContact()
        default:
            break
        }
    }
    
    private func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content:
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".chat.localize) { [weak self] text in
            self?.viewModel.service?.addContact(userId: text, invitation: "", completion: { error, userId in
                if let error = error {
                    consoleLogInfo("add contact error:\(error.errorDescription)", type: .error)
                }
            })
        }
    }
    
    @objc private func viewContact(profile: EaseProfileProtocol) {
        if self.style == .newGroup {
            self.dismiss(animated: true) {
                UIViewController.currentController?.navigationController?.pushViewController(MessageListController(), animated: true)
            }
        } else {
            let vc = ContactInfoViewController(profile: profile)
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    private func viewNewFriendRequest() {
        let vc = NewContactRequestViewController()
        ControllerStack.toDestination(vc: vc)
    }
    
    private func viewJoinedGroups() {
        let vc = JoinedGroupsViewController()
        ControllerStack.toDestination(vc: vc)
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension ContactViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.search.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.indexIndicator.backgroundColor = .clear
        self.indexIndicator.backgroundView = nil
        self.searchController.searchBar.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.searchController.searchBar.barStyle = style == .dark ? .black:.default

    }
    
}

