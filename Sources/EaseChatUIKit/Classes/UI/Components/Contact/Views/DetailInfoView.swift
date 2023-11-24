//
//  DetailInfoView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/23.
//

import UIKit

//@objc open class DetailInfoView: UIView {
//    
//    lazy var header: DetailInfoHeader = {
//        DetailInfoHeader(frame: <#T##CGRect#>, placeHolder: <#T##UIImage?#>)
//    }()
//    
//    lazy var menuList: UITableView = {
//        UITableView(frame: self.bounds, style: .grouped).delegate(self).dataSource(self).tableFooterView(UIView()).registerCell(DetailInfoListCell.self, forCellReuseIdentifier: "DetailInfoListCell").rowHeight(54).sectionHeaderHeight(12)
//    }()
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    convenience init(frame: CGRect, info: EaseProfileProtocol) {
//        self.init(frame: frame)
//        if info.type == .group {
//            ChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: <#T##String#>, completion: <#T##((AgoraChatGroup?, AgoraChatError?) -> Void)?##((AgoraChatGroup?, AgoraChatError?) -> Void)?##(AgoraChatGroup?, AgoraChatError?) -> Void#>)
//        }
//    }
//    
//    public required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
//
//extension DetailInfoView: UITableViewDelegate,UITableViewDataSource {
//    
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        <#code#>
//    }
//    
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//    
//    
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 12)).backgroundColor(Theme.style == .dark ? UIColor.theme.neutralColor0:UIColor.theme.neutralColor95)
//    }
//}
