//
//  MainViewController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2023/12/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

final class MainViewController: UITabBarController, ThemeSwitchProtocol {
    
    func switchTheme(style: EaseChatUIKit.ThemeStyle) {
        if let blur = self.tabBar.viewWithTag(0) as? UIVisualEffectView {
            blur.effect = style == .dark ? UIBlurEffect(style: .dark): UIBlurEffect(style: .light)
            blur.alpha = style == .dark ? 1:0.8
        }
        self.tabBar.barTintColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let window = UIApplication.shared.chat.keyWindow {
            let bottomPadding = window.safeAreaInsets.bottom
            var tabBarFrame = tabBar.frame
            tabBarFrame.origin.y = view.bounds.height - tabBarFrame.height
            tabBar.frame = CGRect(x: 0, y: ScreenHeight-BottomBarHeight-49, width: ScreenWidth, height: BottomBarHeight+49)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewControllers()
        // Do any additional setup after loading the view.
        self.tabBar.insetsLayoutMarginsFromSafeArea = false
        self.tabBarController?.additionalSafeAreaInsets = .zero
        Theme.registerSwitchThemeViews(view: self)
    }
    

    private func loadViewControllers() {
       
        let contacts = EaseChatUIKit.ContactViewController(provider: nil)
        contacts.tabBarItem = UITabBarItem(title: "Contacts".chat.localize, image: UIImage(named: "tabbar_contacts"), selectedImage: UIImage(named: "tabbar_contactsHL"))
        contacts.tabBarItem.tag = 0
        
        let chats = EaseChatUIKit.ConversationListController(provider: nil)
        chats.tabBarItem = UITabBarItem(title: "Chats".chat.localize, image: UIImage(named: "tabbar_chats"), selectedImage: UIImage(named: "tabbar_chatsHL"))
        chats.tabBarItem.tag = 1
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
        let setting = storyboard.instantiateViewController(withIdentifier: "SettingViewController")
        setting.tabBarItem = UITabBarItem(title: "Setting".chat.localize, image: UIImage(named: "tabbar_setting"), selectedImage: UIImage(named: "tabbar_settingHL"))
        setting.tabBarItem.tag = 2
        
        let nav1 = UINavigationController(rootViewController: chats)
        let nav2 = UINavigationController(rootViewController: contacts)
        let nav3 = UINavigationController(rootViewController: setting)
        self.viewControllers = [nav1, nav2,nav3]
        self.tabBar.isTranslucent = false
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = UIColor.theme.barrageDarkColor8
        self.tabBar.barTintColor = UIColor.theme.barrageDarkColor8
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: BottomBarHeight+49)
        blurView.alpha = 0.8
        blurView.insetsLayoutMarginsFromSafeArea = false
        blurView.layoutMargins = .zero
        self.tabBar.insertSubview(blurView, at: 0)
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
    }

}
