//
//  TimerBarView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct TimerBarView: View {
    let timeRemaining: Double
    let maxTime: Double = 10.0

    private var progress: Double {
        max(0, min(1, timeRemaining / maxTime))
    }

    private var barColor: Color {
        if progress > 0.5 { return GBColor.lightest }
        if progress > 0.25 { return GBColor.light }
        return GBColor.dark
    }

    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text("TIME")
                    .pixelFont(10)
                    .foregroundStyle(GBColor.light)

                Spacer()

                Text(String(format: "%.1f", timeRemaining))
                    .pixelFont(10)
                    .foregroundStyle(progress <= 0.25 ? GBColor.lightest : GBColor.light)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(GBColor.dark)
                        .frame(height: 8)

                    Rectangle()
                        .fill(barColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.linear(duration: 0.05), value: progress)
                }
                .pixelBorder(color: GBColor.light, width: 1)
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerBarView(timeRemaining: 10.0)
        TimerBarView(timeRemaining: 5.0)
        TimerBarView(timeRemaining: 2.0)
        TimerBarView(timeRemaining: 0.5)
    }
    .padding()
    .gbScreen()
}
