//
//  ContactListHeader.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/20.
//

import UIKit

@objc open class ContactListHeader: UITableView {
    
    public private(set) var datas: [ContactListHeaderItemProtocol] = []

    internal override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.tableFooterView(UIView()).dataSource(self).delegate(self).separatorStyle(.none).rowHeight(Appearance.Contact.headerRowHeight).registerCell(ContactListHeaderCell.self, forCellReuseIdentifier: "ContactListHeaderCell").showsVerticalScrollIndicator(false)
    }
    
    @objc public required convenience init(frame: CGRect, style: UITableView.Style,items: [ContactListHeaderItemProtocol]) {
        self.init(frame: frame, style: style)
        self.isScrollEnabled = false
        self.datas = items
        self.reloadData()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ContactListHeader: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListHeaderCell") as? ContactListHeaderCell else { return ContactListHeaderCell(style: .default, reuseIdentifier: "ContactListHeaderCell") }
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        if let item = self.datas[safe: indexPath.row] {
            cell.refresh(item: item)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = self.datas[safe: indexPath.row] {
            self.datas[safe: indexPath.row]?.actionClosure?(item)
        }
    }
}
