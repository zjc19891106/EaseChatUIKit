//
//  DialogManager.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc final public class DialogManager: NSObject {
    
    public static let shared = DialogManager()
    
    
    /// Shows the message reporting page.
    /// - Parameter message: ``ChatMessage``
    @objc public func showReportDialog(message: ChatMessage,errorClosure: @escaping (ChatError?)->Void) {
//        var vc = PageContainersDialogController()
//        let report = ComponentsRegister
//            .shared.ReportViewController.init(message: message) {
//                vc.dismiss(animated: true)
//                errorClosure($0)
//            }
//        vc = PageContainersDialogController(pageTitles: ["barrage_long_press_menu_report".chat.localize], childControllers: [report], constraintsSize: Appearance.pageContainerConstraintsSize)
//        
//        UIViewController.currentController?.presentingViewController?.presentViewController(vc)
    }
    
    /// Shows message operations.
    /// Generally, message operations are shown when you long-press a message.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Callback upon a click of a message operation.
    @objc public func showMessageActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions) { item in
            action(item)
            UIViewController.currentController?.dismiss(animated: true)
        }
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        UIViewController.currentController?.presentViewController(vc)
    }
    
    /// Shows the member operation list when you click `...`.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Callback upon a click of a member operation.
    @objc public func showUserActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions) { item in
            action(item)
            UIViewController.currentController?.dismiss(animated: true)
        }
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        UIViewController.currentController?.presentingViewController?.presentViewController(vc)
    }
    
    // Shows the alert view.
    /// - Parameters:
    ///   - content: The alert content to display.
    ///   - showCancel: Whether to display the `Cancel` button.
    ///   - showConfirm: Whether to display the `Confirm` button.
    ///   - confirmClosure: Callback upon a click of the `Confirm` button.
    @objc public func showAlert(content: String,showCancel: Bool,showConfirm: Bool,confirmClosure: @escaping () -> Void) {
        let alert = AlertView(frame: CGRect(x: 0, y: 0, width: Appearance.alertContainerConstraintsSize.width, height: Appearance.alertContainerConstraintsSize.height)).background(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98).content(content: content).title(title: "participant_list_button_click_menu_remove".chat.localize).contentTextAlignment(textAlignment: .center)
        if showCancel {
            alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7).leftButton(title: "report_button_click_menu_button_cancel".chat.localize)
        }
        if showConfirm {
            alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure { _ in
                confirmClosure()
            }.rightButton(title: "Confirm".chat.localize)
        }
        let alertVC = AlertViewController(custom: alert)
        UIViewController.currentController?.presentingViewController?.presentViewController(alertVC)
    }
}
