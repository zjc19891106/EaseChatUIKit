//
//  PropertyWrapper.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/13.
//

import Foundation

@propertyWrapper struct UserDefault<T> {
    
    let key: String
    let defaultValue: T

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

