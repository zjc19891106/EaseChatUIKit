import UIKit

@objc public enum MessageCellStyle: UInt {
    case text
    case image
    case video
    case location
    case voice
    case file
    case cmd
    case custom
    case combine
}

@objc open class MessageCell: UITableViewCell {
    
    @objc public enum ContentDisplayStyle: UInt {
        case withReply = 1
        case withAvatar = 2
        case withNickName = 4
        case withReaction = 8
        case withDateAndTime = 16
    }
    
    @objc public enum BubbleDisplayStyle: UInt {
        case withArrow
        case withMultiCorner
    }
    
    @objc required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
