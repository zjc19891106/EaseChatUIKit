//
//  SectionIndexList.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/22.
//

import UIKit

@objc public protocol ISectionIndexListDriver: NSObjectProtocol {
    func refresh(titles: [String])
    
    func selectItem(indexPath: IndexPath)
}

@objc open class SectionIndexList: UITableView,ISectionIndexListDriver {
        
    @objc public var selectClosure: ((IndexPath) -> Void)?
    
    @objc public var selectedColor = UIColor.theme.primaryColor5
    
    private var selectIndex = 0
    
    private var indexTitles = [String]()

    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.registerCell(UITableViewCell.self, forCellReuseIdentifier: "SectionIndexListCell")
        self.rowHeight = 16
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .none
        self.tableFooterView = UIView().backgroundColor(.clear)
        self.isScrollEnabled = false
        self.showsVerticalScrollIndicator = false
        self.backgroundView = nil
        Theme.registerSwitchThemeViews(view: self)
    }
    
    @objc public func refresh(titles: [String]) {
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: 16, height: CGFloat(titles.count*16))
        self.indexTitles.removeAll()
        self.indexTitles.append(contentsOf: titles)
        self.reloadData()
    }
    
    @objc public func selectItem(indexPath: IndexPath) {
        self.selectIndex = indexPath.section
        self.reloadData()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SectionIndexList: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.indexTitles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SectionIndexListCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SectionIndexListCell")
        }
        cell?.textLabel?.text = self.indexTitles[safe: indexPath.row]
        cell?.textLabel?.textAlignment = .center
        cell?.contentView.backgroundColor = indexPath.row == self.selectIndex ? self.selectedColor:.clear
        cell?.contentView.cornerRadius(8)
        cell?.textLabel?.backgroundColor = .clear
        cell?.textLabel?.font = UIFont.theme.bodyExtraSmall
        cell?.selectionStyle = .none
        if self.selectIndex != indexPath.row {
            cell?.textLabel?.textColor = Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        } else {
            cell?.textLabel?.textColor = UIColor.theme.neutralColor98
        }
        cell?.backgroundColor = .clear
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectIndex = indexPath.row
        self.selectClosure?(indexPath)
        self.reloadData()
    }
    
}

extension SectionIndexList: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.selectedColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.reloadData()
    }
    
    
}
