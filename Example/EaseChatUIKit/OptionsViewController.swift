//
//  OptionsViewController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2023/12/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class OptionsViewController: UIViewController {
    
    @IBOutlet weak var themeSegment: UISegmentedControl!
    
    @IBOutlet weak var bubbleStyle: UILabel!
    
    @IBOutlet weak var bubbleStyleSegment: UISegmentedControl!
    
    @IBOutlet weak var avatarStyle: UILabel!
    
    @IBOutlet weak var avatarStyleSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.themeSegment.selectedSegmentIndex = 0
        self.bubbleStyleSegment.selectedSegmentIndex = 0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchTheme(_ sender: UISegmentedControl) {
        let style = ThemeStyle(rawValue: UInt(sender.selectedSegmentIndex)) ?? .light
        Theme.switchTheme(style: style)
        UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = (style == .dark ? .dark:.light) }
    }
    
    @IBAction func switchBubble(_ sender: UISegmentedControl) {
        Appearance.chat.bubbleStyle = MessageCell.BubbleDisplayStyle(rawValue: UInt(sender.selectedSegmentIndex)) ?? .withArrow
    }
    
    @IBAction func switchAvatar(_ sender: UISegmentedControl) {
        Appearance.avatarRadius = sender.selectedSegmentIndex == 1 ? .small:.large
        Theme.switchTheme(style: Theme.style)
    }
}
