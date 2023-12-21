//
//  ChatEmojiConvertor.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation


/**
 A class that converts emojis in a given NSMutableAttributedString to their corresponding UIImage.
 
 - Author: ChatroomUIKit
 - Version: 1.0.0
 */
@objc final public class ChatEmojiConvertor: NSObject {

    @objc public static let shared = ChatEmojiConvertor()

    @objc var emojiMap: Dictionary<String,UIImage> = Appearance.chat.emojiMap

    @objc var emojis: [String] = ["U+1F600", "U+1F604", "U+1F609", "U+1F62E", "U+1F92A", "U+1F60E", "U+1F971", "U+1F974", "U+263A", "U+1F641", "U+1F62D", "U+1F610", "U+1F607", "U+1F62C", "U+1F913", "U+1F633", "U+1F973", "U+1F620", "U+1F644", "U+1F910", "U+1F97A", "U+1F928", "U+1F62B", "U+1F637", "U+1F912", "U+1F631", "U+1F618", "U+1F60D", "U+1F922", "U+1F47F", "U+1F92C", "U+1F621", "U+1F44D", "U+1F44E", "U+1F44F", "U+1F64C", "U+1F91D", "U+1F64F", "U+2764", "U+1F494", "U+1F495", "U+1F4A9", "U+1F48B", "U+2600", "U+1F31C", "U+1F308", "U+2B50", "U+1F31F", "U+1F389", "U+1F490", "U+1F382", "U+1F381"]
    
    
    /**
     Converts the specified ranges of the input attributed string to emoji images using the provided symbol and returns the resulting attributed string.
     
     - Parameters:
         - input: The input attributed string to convert.
         - ranges: The ranges of the input attributed string to convert to emoji images.
         - symbol: The symbol to use for the emoji images.
     
     - Returns: A new attributed string with the specified ranges replaced with emoji images.
     */
    @objc public func convertEmoji(input: NSMutableAttributedString, ranges: [NSRange], symbol: String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(attributedString: input)
        for range in ranges.reversed() {
            if range.location != NSNotFound, range.length != NSNotFound {
                let value = self.emojiMap.isEmpty ? UIImage(named: symbol, in: .chatBundle, with: nil):self.emojiMap[symbol]
                let attachment = NSTextAttachment()
                attachment.image = value
                attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
                text.replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
            }
        }
        return text
    }
}
