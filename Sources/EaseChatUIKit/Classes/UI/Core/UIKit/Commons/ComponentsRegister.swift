//
//  ComponentsRegister.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit


/// An object containing UI components that are used through the ChatroomUIKit SDK.
@objcMembers public class ComponentsRegister: NSObject {
    
    public static var shared = ComponentsRegister()
    
    public var ConversationCell: ConversationListCell.Type = ConversationListCell.self
    
    public var ConversationSearchResultCell: ConversationSearchCell.Type = ConversationSearchCell.self
    
    public var ContactsCell: ContactCell.Type = ContactCell.self
    
    public var ChatMessageCell: MessageCell.Type = MessageCell.self
    
    public var ChatTextMessageCell: TextMessageCell.Type = TextMessageCell.self
    
    public var ChatImageMessageCell: ImageMessageCell.Type = ImageMessageCell.self
    
    public var ChatAudioMessageCell: AudioMessageCell.Type = AudioMessageCell.self
    
    public var ChatVideoMessageCell: VideoMessageCell.Type = VideoMessageCell.self
    
    public var ChatFileMessageCell: FileMessageCell.Type = FileMessageCell.self
    
    public var ChatContactMessageCell: ContactCardCell.Type = ContactCardCell.self
    
    public var ChatAlertCell: AlertMessageCell.Type = AlertMessageCell.self
    
    /// Gift barrage list cell class.
//    public var GiftBarragesViewCell: GiftBarrageCell.Type = GiftBarrageCell.self
//    
//    /// Gifts view cell class.
//    public var GiftsCell: GiftEntityCell.Type = GiftEntityCell.self
//    
//    /// Chat input bar class.
    public var ChatInputBar: MessageInputBar.Type = MessageInputBar.self
//
//    /// Chatroom barrages list cell class.
//    public var ChatBarragesCell: ChatBarrageCell.Type = ChatBarrageCell.self
//    
    /// Report message controller
    public var ReportViewController: ReportOptionsController.Type = ReportOptionsController.self
    
    /// Member list page&Banned list page
//    public var ParticipantsViewController: ParticipantsController.Type = ParticipantsController.self
//    
//    public var ChatroomParticipantCell: ChatroomParticipantsCell.Type = ChatroomParticipantsCell.self
    
}
