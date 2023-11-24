//
//  ContactListHeaderCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/20.
//

import UIKit


/// A protocol of the contact list item.
@objc public protocol ContactListHeaderItemProtocol: NSObjectProtocol {
    
    /// Identify of the feature
    var featureIdentify: String {set get}
    
    /// Name of the feature
    var featureName: String {set get}
    
    /// Icon of the feature
    var featureIcon: UIImage? {set get}
    
    /// Whether show badge on cell.
    var showBadge: Bool {set get}
    
    /// Whether show number on cell.
    var showNumber: Bool {set get}
    
    /// Display number.
    var numberCount: UInt {set get}
    
    /// When the cell clicked,callback.
    var actionClosure: ContactListItemActionClosure? {set get}
}


/// The header list cell of the contact list.
@objc open class ContactListHeaderCell: UITableViewCell {
    
    public private(set) lazy var badge: UILabel = {
        UILabel(frame: CGRect(x: 0, y: 0, width: 32, height: 18)).cornerRadius(.large).font(UIFont.theme.bodySmall)
    }()
        
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.imageView?.contentMode = .scaleAspectFit
        self.textLabel?.font = UIFont.theme.labelMedium
        self.textLabel?.textColor = UIColor.theme.neutralColor1
//        self.accessoryView = self.badge
    }
    
    /// Refresh cell on needed.
    /// - Parameter item: The object of conform ``ContactListItemProtocol``.
    @objc public func refresh(item: ContactListHeaderItemProtocol) {
        self.imageView?.image = item.featureIcon
        self.textLabel?.text = item.featureName
        if item.showBadge {
            self.badge.backgroundColor(Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).textColor(UIColor.theme.neutralColor98).textAlignment(.center)
        } else {
            self.badge.textAlignment(.right).textColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).backgroundColor(.clear)
        }
        if item.numberCount > 0 {
            self.badge.text = "\(item.numberCount)"
        }
        self.accessoryView?.isHidden = !item.showNumber
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public typealias ContactListItemActionClosure = ((ContactListHeaderItemProtocol) -> Void)

@objc final public class ContactListHeaderItem: NSObject,ContactListHeaderItemProtocol {
    public var numberCount: UInt = 0
    
    public var featureIdentify: String = ""
    
    public var featureName: String = ""
    
    public var featureIcon: UIImage?
    
    public var showBadge: Bool = false
    
    public var showNumber: Bool = false
    
    public var actionClosure: ContactListItemActionClosure?
    
    /// A convenience initializer for creating an ``ContactListItem`` object .
    /// - Parameters:
    ///   - featureName: The feature name of the contact header item
    ///   - featureIcon: The icon of the contact header item
    ///   - action: The callback on item clicked.
    @objc public convenience init(featureIdentify: String ,featureName: String, featureIcon: UIImage?,action: @escaping ContactListItemActionClosure) {
        self.init()
        self.actionClosure = action
        self.featureIdentify = featureIdentify
        self.featureName = featureName
        self.featureIcon = featureIcon
    }

    
    /// A convenience initializer for creating an ``ContactListItem`` object .
    /// - Parameters:
    ///   - featureName: The feature name of the contact header item
    ///   - featureIcon: The icon of the contact header item
    @objc public convenience init(featureIdentify: String ,featureName: String, featureIcon: UIImage?) {
        self.init()
        self.featureIcon = featureIcon
        self.featureName = featureName
        self.featureIdentify = featureIdentify
    }
    
    public override init() {
        super.init()
    }
}
