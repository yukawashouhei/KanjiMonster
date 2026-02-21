//
//  HintView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct HintView: View {
    let hintText: String?
    let isLoading: Bool
    let onRequestHint: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            if let hint = hintText {
                HStack(alignment: .top, spacing: 6) {
                    Text("💡")
                        .font(.system(size: 14))
                    Text(hint)
                        .pixelFont(10)
                        .foregroundStyle(GBColor.light)
                        .multilineTextAlignment(.leading)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .pixelBorder(color: GBColor.dark, width: 1)
            } else {
                Button(action: onRequestHint) {
                    HStack(spacing: 4) {
                        Text("?")
                            .pixelFont(12)
                        Text("HINT")
                            .pixelFont(10)
                    }
                    .foregroundStyle(GBColor.light)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .pixelBorder(color: GBColor.dark, width: 1)
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HintView(hintText: nil, isLoading: false, onRequestHint: {})
        HintView(hintText: "太陽の方を向く夏の花\n最初の文字: ひ...", isLoading: false, onRequestHint: {})
    }
    .padding()
    .gbScreen()
}
