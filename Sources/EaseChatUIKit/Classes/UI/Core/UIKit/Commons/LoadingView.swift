//
//  LoadingView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/22.
//

import UIKit

@objc class LoadingView: UIView {
    
    let lightEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
    
    let darkEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .systemGray
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    lazy var blur: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: self.lightEffect)
        return blurView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cornerRadius(.medium)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        self.isHidden = true
        self.addSubViews([self.blur,self.activityIndicatorView])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: .light)
        NSLayoutConstraint.activate([
            self.blur.topAnchor.constraint(equalTo: topAnchor),
            self.blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            self.blur.leftAnchor.constraint(equalTo: leftAnchor),
            self.blur.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        NSLayoutConstraint.activate([
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    /// Start loading animation
    @MainActor func startAnimating() {
        self.isHidden = false
        self.alpha = 1
        self.activityIndicatorView.startAnimating()
    }
    
    /// Stop loading animation
    @MainActor func stopAnimating() {
        self.isHidden = true
        self.alpha = 0
        self.activityIndicatorView.stopAnimating()
    }
    
}


extension LoadingView: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.blur.effect = style == .dark ? self.darkEffect:self.lightEffect
        self.backgroundColor = style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1
    }
}
