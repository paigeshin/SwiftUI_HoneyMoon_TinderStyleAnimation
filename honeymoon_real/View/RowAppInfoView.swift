//
//  RowInfoView.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

struct RowAppInfoView: View {
    // MARK: - PROPERTIES
    var itemOne: String
    var itemTwo: String
    
    var body: some View {
        VStack {
            HStack {
                Text(itemOne)
                    .foregroundColor(Color.gray)
                Spacer()
                Text(itemTwo)
            }
        }
        Divider()
    }
}

struct RowAppInfoView_Previews: PreviewProvider {
        
    static var previews: some View {
        RowAppInfoView(itemOne: "Application", itemTwo: "Honeymoon")
            .previewLayout(.sizeThatFits)
    }
}
