//
//  Appearance.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc public enum AlertStyle: UInt {
    case small
    case large
}

/// An object containing visual configurations for the whole application.
@objcMembers final public class Appearance: NSObject {
            
    /// You can change the width of a single option with ``PageContainerTitleBar`` in the popup container by setting the current property.
    public static var pageContainerTitleBarItemWidth: CGFloat = (ScreenWidth-32)/2.0
    
    /// The size of ``PageContainersDialogController`` constraints.
    public static var pageContainerConstraintsSize = CGSize(width: ScreenWidth, height: ScreenHeight*(3.0/5.0))
    
    /// The size of alert container constraints.``AlertViewController``
    public static var alertContainerConstraintsSize = CGSize(width: ScreenWidth-40, height: ScreenHeight/3.0)
    
    /// The corner radius of the alert view.``AlertView``
    public static var alertStyle: AlertStyle = .large
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly. The default value is 203/360.0.
    public static var primaryHue: CGFloat = 203/360.0
    
    /// You can change the primary hue. The default value is 203/360.0.
    /// After the primary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var secondaryHue: CGFloat = 155/360.0
    
    /// You can change the secondary hue. The default value is 155/360.0.
    /// After the secondary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var errorHue: CGFloat = 350/360.0
    
    /// You can change the neutral hue. The default value is 203/360.0.
    /// After the neutral hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var neutralHue: CGFloat = 203/360.0
    
    /// You can change the neutral special hue. The default value is 220/360.0.
    /// After the neutral special hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the relevant color series in the chat room UIKit will also change accordingly.
    public static var neutralSpecialHue: CGFloat = 220/360.0
    
    /// The corner radius of the avatar image view of ``ChatInputBar``.
    public static var avatarRadius: CornerRadius = .large
        
    /// ActionSheet row height.
    public static var actionSheetRowHeight: CGFloat = 56
    
    /// The placeholder image of the avatar image view of ``MessageCell``.
    public static var avatarPlaceHolder: UIImage? = UIImage(named: "default_avatar", in: .chatBundle, with: nil)
    
    /// The row height of the member cell.
    public static var participantsRowHeight: CGFloat = 62
    
    /// The number of chat room members that you expect to get on each page.
    public static var participantsPageSize: UInt = 10
    
    public static var conversation = Appearance.Conversation()
    
    public static var contact = Appearance.Contact()
    
    public static var chat = Appearance.Chat()
    
    @objcMembers final public class Conversation: NSObject {
        
        public var rowHeight = CGFloat(76)
        
        public var swipeLeftActions: [UIContextualActionType] = [.mute,.pin,.delete]
        
        public var swipeRightActions: [UIContextualActionType] = [.more,.read]
        
        public var avatarRadius: CornerRadius = .large
        
        public var singlePlaceHolder = UIImage(named: "single", in: .chatBundle, with: nil)
        
        public var groupPlaceHolder = UIImage(named: "group", in: .chatBundle, with: nil)
        
        /// Setting this property changes the date format displayed within a single session.
        public var dateFormatToday = "HH:mm"
        
        /// Setting this property changes the date format displayed within a single session.
        public var dateFormatOtherDay = "MMM dd"
        
        /// Prompt message when the session list is refreshed
        public var refreshAlert = "Refreshing..."
        
        /// ActionSheet menu configuration items after clicking more buttons in a single session side sliding menu.
        /// How to use?
        /// `let translate = ActionSheetItem(title: "translate", type: .normal,tag: "Translate")`
        /// `translate.action = { }`
        /// `Appearance.conversation.moreActions.append(translate)`
        public var moreActions: [ActionSheetItemProtocol] = []
        
        public var addActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "new_chat_button_click_menu_selectcontacts".chat.localize, type: .normal, tag: "SelectContacts", image: UIImage(named: "chatWith", in: .chatBundle, with: nil)),ActionSheetItem(title: "new_chat_button_click_menu_addcontacts".chat.localize, type: .normal, tag: "AddContact", image: UIImage(named: "person_add", in: .chatBundle, with: nil)?.withTintColor(UIColor.theme.primaryColor5)),ActionSheetItem(title: "new_chat_button_click_menu_creategroup".chat.localize, type: .normal, tag: "CreateGroup", image: UIImage(named: "create_group", in: .chatBundle, with: nil)?.withTintColor(UIColor.theme.primaryColor5))]
    }
    
    @objcMembers final public class Chat: NSObject {
        
        /// The height limit of the input box in ``ChatInputBar``.
        public var maxInputHeight: CGFloat = 88
        
        /// The placeholder text in ``ChatInputBar``.
        public var inputPlaceHolder = "Aa"
        
        /// The corner radius of ``ChatInputBar``.
        public var inputBarCorner: CornerRadius = .medium
        
        public var bubbleStyle: MessageCell.BubbleDisplayStyle = .withArrow
        
        public var contentStyle: [MessageCell.ContentDisplayStyle] = [.withReply,.withAvatar,.withNickName,.withDateAndTime]
                
        /// ActionSheet data source of the message being long pressed.``ActionSheetItemProtocol``
        public var defaultMessageActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "barrage_long_press_menu_copy".chat.localize, type: .normal,tag: "Copy",image: UIImage(named: "message_action_copy", in: .chatBundle, with: nil)),ActionSheetItem(title: "barrage_long_press_menu_edit".chat.localize, type: .normal,tag: "Edit",image: UIImage(named: "message_action_edit", in: .chatBundle, with: nil)),ActionSheetItem(title: "barrage_long_press_menu_reply".chat.localize, type: .normal,tag: "Reply",image: UIImage(named: "message_action_reply", in: .chatBundle, with: nil)),ActionSheetItem(title: "barrage_long_press_menu_delete".chat.localize, type: .normal,tag: "Delete",image: UIImage(named: "message_action_delete", in: .chatBundle, with: nil)),ActionSheetItem(title: "barrage_long_press_menu_recall".chat.localize, type: .normal,tag: "Recall",image: UIImage(named: "message_action_recall", in: .chatBundle, with: nil)),ActionSheetItem(title: "barrage_long_press_menu_report".chat.localize, type: .normal,tag: "Report",image: UIImage(named: "message_action_report", in: .chatBundle, with: nil))]
        
        /// The mirror type of the language code of LanguageType.``LanguageType``
        public var targetLanguage: LanguageType = .English
        
        /// The label for message reporting types.
        public var reportTags: [String] = ["violation_reason_1".chat.localize,"violation_reason_2".chat.localize,"violation_reason_3".chat.localize,"violation_reason_4".chat.localize,"violation_reason_5".chat.localize,"violation_reason_6".chat.localize,"violation_reason_7".chat.localize,"violation_reason_8".chat.localize,"violation_reason_9".chat.localize]
        
        /// Replace the emoji resource.``ChatEmojiConvertor``
        /// - Parameters:
        ///   Emoji map in key-value format, where the key can only be any of the following and value is a UIImage instance.
        ///   `["U+1F600", "U+1F604", "U+1F609", "U+1F62E", "U+1F92A", "U+1F60E", "U+1F971", "U+1F974", "U+263A", "U+1F641", "U+1F62D", "U+1F610", "U+1F607", "U+1F62C", "U+1F913", "U+1F633", "U+1F973", "U+1F620", "U+1F644", "U+1F910", "U+1F97A", "U+1F928", "U+1F62B", "U+1F637", "U+1F912", "U+1F631", "U+1F618", "U+1F60D", "U+1F922", "U+1F47F", "U+1F92C", "U+1F621", "U+1F44D", "U+1F44E", "U+1F44F", "U+1F64C", "U+1F91D", "U+1F64F", "U+2764", "U+1F494", "U+1F495", "U+1F4A9", "U+1F48B", "U+2600", "U+1F31C", "U+1F308", "U+2B50", "U+1F31F", "U+1F389", "U+1F490", "U+1F382", "U+1F381"]`
        public var emojiMap: Dictionary<String,UIImage> = Dictionary<String,UIImage>()
        
        public var attachmentActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "input_extension_menu_photo".chat.localize, type: .normal,tag: "Photo",image: UIImage(named: "photo", in: .chatBundle, with: nil)),ActionSheetItem(title: "input_extension_menu_camera".chat.localize, type: .normal,tag: "Camera",image: UIImage(named: "camera_fill", in: .chatBundle, with: nil)),ActionSheetItem(title: "input_extension_menu_file".chat.localize, type: .normal,tag: "File",image: UIImage(named: "file", in: .chatBundle, with: nil)),ActionSheetItem(title: "input_extension_menu_contact".chat.localize, type: .normal,tag: "Contact",image: UIImage(named: "person_single_fill", in: .chatBundle, with: nil))]
        
        /// Setting this property changes the date format displayed within a single session.
        public var dateFormatToday = "HH:mm"
        
        /// Setting this property changes the date format displayed within a single session.
        public var dateFormatOtherDay = "yyyy-MM-dd HH:mm"
        
        public var audioDuration = 60
        
        public var receiveAudioAnimationImages = [UIImage(named: Theme.style == .dark ? "audio_play_left_dark01":"audio_play_left_light01", in: .chatBundle, with: nil)!,UIImage(named: Theme.style == .dark ? "audio_play_left_dark02":"audio_play_left_light02", in: .chatBundle, with: nil)!,UIImage(named: Theme.style == .dark ? "audio_play_left_dark03":"audio_play_left_light03", in: .chatBundle, with: nil)!]
        
        public var sendAudioAnimationImages = [UIImage(named: Theme.style == .dark ? "audio_play_right_dark01":"audio_play_right_light01", in: .chatBundle, with: nil)!,UIImage(named: Theme.style == .dark ? "audio_play_right_dark02":"audio_play_right_light02", in: .chatBundle, with: nil)!,UIImage(named: Theme.style == .dark ? "audio_play_right_dark03":"audio_play_right_light03", in: .chatBundle, with: nil)!]
        
        public var receiveBubbleColor = Theme.style == .dark ? UIColor.theme.primaryColor2:UIColor.theme.primaryColor95
        
        public var sendBubbleColor = Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        
        public var receiveTextColor = Theme.style == .light ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        
        public var sendTextColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        
        public var imageMessageCorner = CGFloat(4)
        
        public var imagePlaceHolder = UIImage(named: "image_message_placeHolder", in: .chatBundle, with: nil)
        
        public var videoPlaceHolder = UIImage(named: "video_message_placeHolder", in: .chatBundle, with: nil)
        
        /// The maximum time limit for message withdrawal needs to be adjusted from the console before adjusting this configuration of the client.
        var recallExpiredTime = UInt(120)
        
    }
    
    /// Contact Module
    @objcMembers final public class Contact: NSObject {
        
        public var rowHeight = CGFloat(54)
        
        public var headerRowHeight = CGFloat(54)
        
        /// The header items of the contact list.
        public var headerExtensionActions: [ContactListHeaderItemProtocol] = [ContactListHeaderItem(featureIdentify: "NewFriendRequest", featureName: "New Request", featureIcon: nil),ContactListHeaderItem(featureIdentify: "GroupChats", featureName: "Joined Groups", featureIcon: nil)]
        
        /// The contact info header extension items.
        public var detailInfoActionItems: [ContactListHeaderItemProtocol] = [ContactListHeaderItem(featureIdentify: "Chat", featureName: "Chat", featureIcon: UIImage(named: "chatTo", in: .chatBundle, with: nil))]
        
        /// ActionSheet menu configuration items after clicking more buttons in a single session side sliding menu.
        /// How to use?
        /// `let translate = ActionSheetItem(title: "translate", type: .normal,tag: "Translate")`
        /// `translate.action = { }`
        /// `Appearance.conversation.moreActions.append(translate)`
        public var moreActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "contact_details_extend_button_delete".chat.localize, type: .destructive, tag: "contact_delete")]
    }
}
