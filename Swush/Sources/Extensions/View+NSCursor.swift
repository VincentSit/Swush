//
//  View+NSCursor.swift
//  Swush
//
//  Created by Quentin Eude on 15/02/2022.
//

import SwiftUI

extension View {
    /// https://stackoverflow.com/a/61985678/3393964
    public func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
