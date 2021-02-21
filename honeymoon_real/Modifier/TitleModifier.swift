//
//  TitleModifier.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(Color.pink)
    }
}

