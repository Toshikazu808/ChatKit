//
//  Theme.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/15/25.
//

import SwiftUI

@MainActor public enum Theme {
    public static var babyBlue = Color(red: 0.941, green: 0.98, blue: 0988)
    public static var lightGray = Color(red: 0.839, green: 0.839, blue: 0.839)
    public static var silver = Color(red: 0.043, green: 0.298, blue: 0.376)
    public static var lightNavy = Color(red: 0.043, green: 0.298, blue: 0.376)
}

@MainActor public struct CKColorThemeConfig {
    public private(set) var babyBlue: Color?
    public private(set) var lightGray: Color?
    public private(set) var silver: Color?
    public private(set) var lightNavy: Color?
    
    public func setColorTheme() {
        if let babyBlue {
            Theme.babyBlue = babyBlue
        }
        if let lightGray {
            Theme.lightGray = lightGray
        }
        if let silver {
            Theme.silver = silver
        }
        if let lightNavy {
            Theme.lightNavy = lightNavy
        }
    }
}
