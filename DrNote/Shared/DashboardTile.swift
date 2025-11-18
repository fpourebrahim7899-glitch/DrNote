//
//  Untitled.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//

import SwiftUI

/// A big tappable tile with an SF Symbol and a caption,
/// used on the dashboard for the four main actions.
struct DashboardTile: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 36, weight: .semibold))
                    .frame(width: 64, height: 64)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}
