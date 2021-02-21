//
//  AppInfoView.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RowAppInfoView(itemOne: "Application", itemTwo: "Honeymoon")
            RowAppInfoView(itemOne: "Compatibility", itemTwo: "iPhone and iPad")
            RowAppInfoView(itemOne: "Developer", itemTwo: "Paige Shin")
            RowAppInfoView(itemOne: "Designer", itemTwo: "Paig Shin")
            RowAppInfoView(itemOne: "Website", itemTwo: "paigeshin.com")
            RowAppInfoView(itemOne: "Version", itemTwo: "1.0.0")
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        AppInfoView()
            .previewLayout(.sizeThatFits)
    }
}
