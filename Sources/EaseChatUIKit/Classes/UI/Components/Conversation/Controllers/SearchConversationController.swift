//
//  SearchConversationController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/14.
//

import UIKit

@objc open class SearchConversationController: UIViewController {
    
    private var active = false {
        didSet {
            if self.active == false {
                self.searchResults.removeAll()
            }
        }
    }
    
    private var datas: [ConversationInfo] = []  {
        didSet {
            DispatchQueue.main.async {
                if self.datas.count <= 0  {
                    self.searchList.backgroundView = self.empty
                } else {
                    self.searchList.backgroundView = nil
                }
            }
        }
    }
    
    private var searchResults: [ConversationInfo] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.active {
                    if self.searchResults.count <= 0  {
                        self.searchList.backgroundView = self.empty
                    } else {
                        self.searchList.backgroundView = nil
                    }
                }
            }
        }
    }
    
    private var searchText = ""
    
    lazy var searchHeader: SearchHeaderBar = {
        SearchHeaderBar(frame: CGRect(x: 0, y: StatusBarHeight+10, width: ScreenWidth, height: 44), displayStyle: .withBack)
    }()
    
    lazy var searchList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.searchHeader.frame.maxY+4, width: ScreenWidth, height: ScreenHeight-self.searchHeader.frame.maxY-BottomBarHeight), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).separatorStyle(.none)
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.searchList.frame.width, height: self.searchList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil))
    }()
    
    @objc public required convenience init(searchInfos: [ConversationInfo]) {
        self.init()
        self.datas = searchInfos
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.searchHeader,self.searchList])
        self.searchHeader.textChanged = { [weak self] in
            guard let `self` = self else { return }
            self.searchText = $0
            self.searchResults = self.datas.filter({ $0.nickName.contains(self.searchText) })
            self.searchList.reloadData()
        }
        self.searchHeader.textFieldState = { [weak self] in
            self?.active = $0 == .began
        }
        self.searchHeader.actionClosure = { [weak self] _  in
            self?.active = false
        }
    }
    

}

extension SearchConversationController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.active ? self.searchResults.count:self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ConversationSearchResultCell, reuseIdentifier: "ConversationSearchCell")
        if self.active {
            if let info = self.searchResults[safe: indexPath.row] {
                cell?.refresh(info: info, keyword: self.searchText)
            }
        } else {
            if let info = self.datas[safe: indexPath.row] {
                cell?.refresh(info: info, keyword: self.searchText)
            }
        }
        return cell ?? UITableViewCell()
    }
    
    
}
