//
//  AnswerInputView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct AnswerInputView: View {
    @Binding var text: String
    let isEnabled: Bool
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            TextField("よみを入力...", text: $text)
                .pixelFont(16)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(GBColor.dark)
                .foregroundStyle(GBColor.lightest)
                .pixelBorder(color: GBColor.light, width: 2)
                .focused($isFocused)
                .disabled(!isEnabled)
                .onSubmit(onSubmit)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            Button(action: onSubmit) {
                Text("▶")
                    .pixelFont(20)
                    .frame(width: 44, height: 44)
                    .background(isEnabled ? GBColor.light : GBColor.dark)
                    .foregroundStyle(GBColor.darkest)
                    .pixelBorder(color: GBColor.lightest, width: 2)
            }
            .disabled(!isEnabled || text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onChange(of: isEnabled) { _, newValue in
            if newValue {
                isFocused = true
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    AnswerInputView(text: $text, isEnabled: true, onSubmit: {})
        .padding()
        .gbScreen()
}
