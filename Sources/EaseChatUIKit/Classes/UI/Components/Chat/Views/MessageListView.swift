import UIKit

@objc public protocol MessageListViewActionEventsDelegate: NSObjectProtocol {
    
    
}

@objc public protocol IMessageListViewDriver: NSObjectProtocol {
    
    
}


@objc final public class MessageListView: UITableView {
        
    private var eventHandlers: NSHashTable<MessageListViewActionEventsDelegate> = NSHashTable<MessageListViewActionEventsDelegate>.weakObjects()
    
    /// Add UI actions handler.
    /// - Parameter actionHandler: ``MessageListViewActionEventsDelegate``
    public func addActionHandler(actionHandler: MessageListViewActionEventsDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// Remove UI action handler.
    /// - Parameter actionHandler: ``MessageListViewActionEventsDelegate``
    public func removeEventHandler(actionHandler: MessageListViewActionEventsDelegate) {
        self.eventHandlers.remove(actionHandler)
    }
    
    private var datas: [ConversationInfo] = []
    
    required public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.delegate(self).dataSource(self).tableFooterView(UIView()).separatorStyle(.none).register(ComponentsRegister.shared.ChatMessageCell.self, "EaseChatUIKit.ChatMessageCell")
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageListView: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatMessageCell, reuseIdentifier: "EaseChatUIKit.ChatMessageCell")
        if cell == nil {
            cell = ComponentsRegister.shared.ChatMessageCell.init(style: .default, reuseIdentifier: "EaseChatUIKit.ChatMessageCell")
        }
        if let info = self.datas[safe: indexPath.row] {
//            cell?.refresh(info: info)
        }
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension MessageListView: IMessageListViewDriver {
    
    
}
