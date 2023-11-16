import UIKit

@objc open class ConversationController: UIViewController {
    
    /// The id of the conversation.
    public private(set) var id = ""
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true)
    }()
    
    public private(set) lazy var conversationList: ConversationList = {
        ConversationList(frame: CGRect(x: 0, y: NavigationHeight+44, width: self.view.frame.width, height: ScreenHeight-NavigationHeight-44-BottomBarHeight), style: .plain)
    }()
    
    public private(set) var binder: ConversationBinder = ConversationBinder()
    
    /// ``ConversationController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - id: The id of the conversation.
    ///   - providerOC: The object of conform ``EaseProfileProviderOC``.
    @objc public required convenience init(id: String,providerOC: EaseProfileProviderOC? = nil) {
        self.init()
        self.id = id
        self.binder = ConversationBinder(providerOC: providerOC)
    }
    
    /// ``ConversationController`` init method.Only available in Swift language.
    /// - Parameters:
    ///   - id: The id of the conversation.
    ///   - provider: The object of conform ``EaseProfileProvider``.
    public required convenience init(id: String,provider: EaseProfileProvider? = nil) {
        self.init()
        self.id = id
        self.binder = ConversationBinder(provider: provider)
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
        self.view.addSubViews([self.conversationList])
        //Bind UI driver and service
        self.binder.bind(driver: self.conversationList, service: ConversationServiceImplement(conversationId: self.id), multi: MultiDeviceServiceImplement())
        //Conversation list click push to message list controller.
        self.binder.toChat = { [weak self] in
            self?.toChat(indexPath: $0, info: $1)
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
    
}

