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
            UIViewController.currentController?.dismiss(animated: true)
            action(item)
        }
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        UIViewController.currentController?.presentViewController(vc)
    }
    
    /// Shows the actions`.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Callback upon a click .
    @objc public func showActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions) { item in
            UIViewController.currentController?.dismiss(animated: true)
            action(item)
        }
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        UIViewController.currentController?.presentViewController(vc)
    }
    
    // Shows the alert view.
    /// - Parameters:
    ///   - title: The alert title to display.
    ///   - content: The alert content to display.
    ///   - showCancel: Whether to display the `Cancel` button.
    ///   - showConfirm: Whether to display the `Confirm` button.
    ///   - showTextField: Whether to display the `TextField` .
    ///   - placeHolder: `TextField` placeholder.
    ///   - confirmClosure: Callback upon a click of the `Confirm` button.When text field was shown callback contain input text.
    @objc public func showAlert(title: String,content: String,showCancel: Bool,showConfirm: Bool,showTextFiled: Bool = false,placeHolder: String = "",confirmClosure: @escaping (String) -> Void) {
        let size = showTextFiled ? Appearance.alertContainerConstraintsSize:CGSize(width: ScreenWidth, height: 300)
        let alert = AlertView().background(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98).title(title: title).content(content: content).contentTextAlignment(textAlignment: .center)
        if showTextFiled {
            alert.textField(font: UIFont.theme.bodyLarge).textField(color: Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1).textFieldPlaceholder(color: Theme.style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor6).textFieldPlaceholder(placeholder: placeHolder)
        }
        if showCancel {
            alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7).leftButton(title: "report_button_click_menu_button_cancel".chat.localize)
        }
        if showConfirm {
            alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure {
                confirmClosure($0 ?? "")
            }.rightButton(title: "Confirm".chat.localize)
        }
        let alertVC = AlertViewController(custom: alert,size: size)
        UIViewController.currentController?.presentingViewController?.presentViewController(alertVC)
    }
}
