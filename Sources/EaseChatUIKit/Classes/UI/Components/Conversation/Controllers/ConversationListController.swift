import UIKit


/// When you
@objc open class ConversationListController: UIViewController {
    
    /// The id of the conversation.
    public private(set) var id = ""
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true,rightImages: [UIImage(named: "add", in: .chatBundle, with: nil)!])
    }()
    
    public private(set) lazy var search: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.navigation.frame.maxY, width: self.view.frame.width-32, height: self.view.frame.height-8)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).cornerRadius(.large).title(" Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var conversationList: ConversationList = {
        ConversationList(frame: CGRect(x: 0, y: self.search.frame.maxY, width: self.view.frame.width, height: ScreenHeight-NavigationHeight-44-BottomBarHeight), style: .plain)
    }()
    
    public private(set) var binder: ConversationBinder = ConversationBinder()
    
    /// ``ConversationListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - providerOC: The object of conform ``EaseProfileProviderOC``.
    @objc public required convenience init(providerOC: EaseProfileProviderOC? = nil) {
        self.init()
        self.id = id
        self.binder = ConversationBinder(providerOC: providerOC)
    }
    
    /// ``ConversationListController`` init method.Only available in Swift language.
    /// - Parameters:
    ///   - id: The id of the conversation.
    ///   - provider: The object of conform ``EaseProfileProvider``.
    public required convenience init(provider: EaseProfileProvider? = nil) {
        self.init()
        self.id = id
        self.binder = ConversationBinder(provider: provider)
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
        //Bind UI driver and service
        self.binder.bind(driver: self.conversationList)
        //Conversation list click push to message list controller.
        self.binder.toChat = { [weak self] in
            self?.toChat(indexPath: $0, info: $1)
        }
        //Back button click
        self.navigation.leftItemClick = { [weak self] in
            self?.pop()
        }
        //If you want to listen for notifications about the success or failure of some requests and other events, you can add the following listeners
//        ConversationListController().binder.registerEventsListener(listener: <#T##ConversationEmergencyListener#>)
//        ConversationListController().binder.unregisterEventsListener(listener: <#T##ConversationEmergencyListener#>)
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func toChat(indexPath: IndexPath,info: ConversationInfo) {
        if let current = UIViewController.currentController {
            if current.navigationController != nil {
                current.navigationController?.pushViewController(MessageListController(), animated: true)
                return
            } else {
                if current.presentedViewController?.navigationController != nil {
                    current.presentedViewController?.navigationController?.pushViewController(MessageListController(), animated: true)
                    return
                } else {
                    if current.presentedViewController != nil {
                        current.presentedViewController?.present(MessageListController(), animated: true)
                    } else {
                        current.present(MessageListController(), animated: true)
                    }
                    return
                }
            }
            
        }
    }
    
    @objc private func searchAction() {
        if self.navigationController != nil {
            self.navigationController?.pushViewController(SearchConversationsController(searchInfos: self.conversationList.datas), animated: true)
        } else {
            self.navigationController?.present(SearchConversationsController(searchInfos: self.conversationList.datas), animated: true)
        }
    }
}
