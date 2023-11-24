//
//  ControllerStack.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/23.
//

import UIKit


class ControllerStack {
    
    static func toDestination(vc: UIViewController) {
        if let current = UIViewController.currentController {
            if current.navigationController != nil {
                current.navigationController?.pushViewController(vc, animated: true)
                return
            } else {
                if current.presentedViewController?.navigationController != nil {
                    current.presentedViewController?.navigationController?.pushViewController(vc, animated: true)
                    return
                } else {
                    if current.presentedViewController != nil {
                        current.presentedViewController?.present(vc, animated: true)
                    } else {
                        current.present(vc, animated: true)
                    }
                    return
                }
            }
            
        }
    }
}
