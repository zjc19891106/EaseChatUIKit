//
//  EaseChatNavigationBar.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/16.
//

import UIKit


/// Navigation  bar of the EaseChatUIKit.
@objc open class EaseChatNavigationBar: UIView {
    
    public var userState: UserState = .online {
        willSet {
            DispatchQueue.main.async {
                self.status.backgroundColor = newValue == .online ? UIColor.theme.secondaryColor5:UIColor.theme.neutralColor5
            }
        }
    }
    
    public var rightItemsClick: ((IndexPath) -> Void)?
    
    public var leftItemClick: (() -> Void)?
    
    private let backImage = UIImage(named: "back", in: .chatBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3)
    
    private var rightImages = [UIImage]()
    
    private var showLeft = false
    
    public var titleAttribute: NSAttributedString? {
        didSet {
            self.titleLabel.text = nil
            self.titleLabel.attributedText = self.titleAttribute
        }
    }
    
    /// TitleLabel's text.
    public var title: String? {
        didSet {
            self.titleLabel.attributedText = nil
            self.titleLabel.text = self.title
            if self.detail.text == nil || self.detail.text?.isEmpty ?? false {
                self.titleLabel.center = CGPoint(x: self.titleLabel.center.x, y: self.leftItem.center.y)
            }
        }
    }
    
    /// Detail's text.
    public var subtitle: String? {
        didSet {
            self.detail.text = self.subtitle
        }
    }
    
    /// Avatar url
    public var avatarURL: String? {
        didSet {
            if let url = self.avatarURL {
                self.avatar.image(with: url, placeHolder: Appearance.avatarPlaceHolder)
            }
        }
    }
    
    public private(set) lazy var leftItem: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 10, y: StatusBarHeight+16, width: 24, height: 24)).image(self.backImage, .normal).tag(0).addTargetFor(self, action: #selector(buttonAction), for: .touchUpInside).backgroundColor(.clear)
    }()
    
    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: self.showLeft ? self.leftItem.frame.maxX:CGFloat(10), y: StatusBarHeight+10, width: 32, height: 32)).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
    }()
    
    public private(set) lazy var status: UIImageView = {
        let r = self.avatar.frame.width / 2.0
        let length = CGFloat(sqrtf(Float(r)))
        let x = (Appearance.avatarRadius == .large ? (r + length + 3):(self.avatar.frame.width-12))
        let y = (Appearance.avatarRadius == .large ? (r + length + 3):(self.avatar.frame.height-12))
        return UIImageView(frame: CGRect(x: self.avatar.frame.minX+x, y: self.avatar.frame.minY+y, width: 12, height: 12)).backgroundColor(UIColor.theme.secondaryColor5).cornerRadius(.large).layerProperties(UIColor.theme.neutralColor98, 2)
    }()
    
    public private(set) lazy var titleLabel: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+8, y: StatusBarHeight+10, width: ScreenWidth-self.avatar.frame.maxX*2-8*3, height: 22)).font(UIFont.theme.titleMedium).textColor(UIColor.theme.neutralColor1).backgroundColor(.clear)
    }()
    
    public private(set) lazy var detail: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+8, y: self.titleLabel.frame.maxY, width: self.titleLabel.frame.width, height: 14)).font(UIFont.theme.bodyExtraSmall).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear)
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: 36, height: 36)
        flow.scrollDirection = .horizontal
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        return flow
    }()
    
    public private(set) lazy var rightItems: UICollectionView = {
        UICollectionView(frame: CGRect(x: ScreenWidth-CGFloat(self.rightImages.count*36)-8, y: StatusBarHeight+8, width: CGFloat(self.rightImages.count*36), height: 36), collectionViewLayout: self.layout).registerCell(EaseChatNavigationBarRightCell.self, forCellReuseIdentifier: "EaseChatNavigationBarRightCell").delegate(self).dataSource(self).backgroundColor(.clear)
    }()

    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// EaseChatNavigationBar init method.
    /// - Parameters:
    ///   - showLeftItem: Whether show left button or not.
    ///   - textAlignment: Title and subtitle text alignment.
    ///   - placeHolder: Avatar default image.
    ///   - avatarURL: Avatar url.
    ///   - rightImages: Right buttons kind of `[UIImage]`.
    ///   - hiddenAvatar: Whether hide avatar or not.
    @objc required public convenience init(showLeftItem: Bool, textAlignment: NSTextAlignment = .center, placeHolder: UIImage? = nil,avatarURL: String? = nil,rightImages: [UIImage] = [],hiddenAvatar: Bool = false) {
        self.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight))
        self.showLeft = showLeftItem
        if rightImages.count > 3 {
            self.rightImages = Array(rightImages.prefix(3))
        } else {
            self.rightImages = rightImages
        }
        if showLeftItem {
            var width = CGFloat(self.rightImages.count*36)
            if self.avatar.frame.maxX+8 > width {
                width = self.avatar.frame.maxX+8
            }
            if hiddenAvatar {
                self.addSubViews([self.leftItem,self.titleLabel,self.detail,self.rightItems])
            } else {
                self.addSubViews([self.leftItem,self.avatar,self.status,self.titleLabel,self.detail,self.rightItems])
            }
            self.titleLabel.frame = CGRect(x: (hiddenAvatar ? self.leftItem.frame.maxX:self.avatar.frame.maxX)+8, y: StatusBarHeight+10, width: ScreenWidth - width*2 - 8, height: 22)
            if textAlignment == .center {
                self.titleLabel.center = CGPoint(x: self.center.x, y: self.titleLabel.center.y)
            }
            self.detail.frame = CGRect(x: self.titleLabel.frame.minX, y: self.titleLabel.frame.maxY, width: self.titleLabel.frame.width, height: 14)
        } else {
            if hiddenAvatar {
                self.addSubViews([self.titleLabel,self.detail,self.rightItems])
            } else {
                self.addSubViews([self.avatar,self.status,self.titleLabel,self.detail,self.rightItems])
            }
            
            self.titleLabel.frame = CGRect(x: (hiddenAvatar ? self.leftItem.frame.maxX:self.avatar.frame.maxX)+8, y: StatusBarHeight+10, width: ScreenWidth - CGFloat(self.rightImages.count*36)*2, height: 22)
            if textAlignment == .center {
                self.titleLabel.center = CGPoint(x: self.center.x, y: self.titleLabel.center.y)
            }
            self.detail.frame = CGRect(x: self.titleLabel.frame.minX, y: self.titleLabel.frame.maxY, width: self.titleLabel.frame.width, height: 14)
        }
        self.titleLabel.textAlignment = textAlignment
        self.detail.textAlignment = textAlignment
        if let url = avatarURL {
            self.avatar.image(with: url, placeHolder: placeHolder == nil ? Appearance.avatarPlaceHolder:placeHolder)
        } else {
            self.avatar.image = placeHolder == nil ? Appearance.avatarPlaceHolder:placeHolder
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonAction() {
        self.leftItemClick?()
    }
    
    @objc public func updateRightItems(images: [UIImage]) {
        self.rightImages.removeAll()
        if rightImages.count > 3 {
            self.rightImages = Array(images.prefix(3))
        } else {
            self.rightImages = images
        }
        self.rightItems.frame = CGRect(x: ScreenWidth-CGFloat(self.rightImages.count*36)-8, y: StatusBarHeight+8, width: CGFloat(self.rightImages.count*36), height: 36)
        self.rightItems.reloadData()
    }
}

extension EaseChatNavigationBar: UICollectionViewDataSource,UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.rightImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EaseChatNavigationBarRightCell", for: indexPath) as? EaseChatNavigationBarRightCell
        cell?.imageView.image = self.rightImages[safe: indexPath.row]?.withTintColor(Theme.style == .light ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor98)
        return cell ?? UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.rightItemsClick?(indexPath)
    }
}

extension EaseChatNavigationBar: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        switch self.userState {
        case .online:
            self.status.backgroundColor = style == .dark ? UIColor.theme.secondaryColor6:UIColor.theme.secondaryColor5
        case .offline:
            self.status.backgroundColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        }
        self.leftItem.setImage(self.backImage?.withTintColor(Theme.style == .light ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor98), for: .normal)
        self.rightItems.reloadData()
    }
    
    
}

@objc open class EaseChatNavigationBarRightCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        UIImageView(frame: CGRect(x: 4, y: 4, width: self.contentView.frame.width-8, height: self.contentView.frame.height-8)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.addSubview(self.imageView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
