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
    
    /// Gift barrage list cell class.
//    public var GiftBarragesViewCell: GiftBarrageCell.Type = GiftBarrageCell.self
//    
//    /// Gifts view cell class.
//    public var GiftsCell: GiftEntityCell.Type = GiftEntityCell.self
//    
//    /// Chat input bar class.
//    public var InputBar: ChatInputBar.Type = ChatInputBar.self
//    
//    /// Chatroom barrages list cell class.
//    public var ChatBarragesCell: ChatBarrageCell.Type = ChatBarrageCell.self
//    
//    /// Report message controller
//    public var ReportViewController: ReportOptionsController.Type = ReportOptionsController.self
    
    /// Member list page&Banned list page
//    public var ParticipantsViewController: ParticipantsController.Type = ParticipantsController.self
//    
//    public var ChatroomParticipantCell: ChatroomParticipantsCell.Type = ChatroomParticipantsCell.self
    
}
