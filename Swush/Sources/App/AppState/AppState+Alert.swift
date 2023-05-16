//
//  AppState+Alert.swift
//  Swush
//
//  Created by Vincent Sit on 5/16/23.
//

import Foundation

extension AppState {
    enum AlertPresentType {
        case none
        case success(message: String)
        case error(message: String)
        
        var content: AlertContent {
            switch self {
                case .none:
                    return .none
                case .success(let message):
                    return AlertContent(title: "Success!", message: message)
                case .error(let message):
                    return AlertContent(title: "An error occurred!", message: message)
            }
        }
        
        var shouldPresent: Bool {
            if case .none = self { return false } else { return true }
        }

    }
    
    struct AlertContent {
        let title: String
        let message: String
        
        static let none = AlertContent(title: "", message: "")
    }
    
}
