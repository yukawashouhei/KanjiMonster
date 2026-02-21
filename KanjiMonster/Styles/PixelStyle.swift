//
//  PixelStyle.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

// MARK: - Game Boy Color Palette

enum GBColor {
    static let darkest  = Color(red: 0.059, green: 0.220, blue: 0.059)   // #0f380f
    static let dark     = Color(red: 0.188, green: 0.384, blue: 0.188)   // #306230
    static let light    = Color(red: 0.545, green: 0.675, blue: 0.059)   // #8bac0f
    static let lightest = Color(red: 0.608, green: 0.737, blue: 0.059)   // #9bbc0f

    static let background = darkest
    static let text = lightest
    static let accent = light
    static let border = dark
}

// MARK: - Pixel Font Modifier

struct PixelFont: ViewModifier {
    let size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .foregroundStyle(GBColor.text)
    }
}

extension View {
    func pixelFont(_ size: CGFloat = 16) -> some View {
        modifier(PixelFont(size: size))
    }
}

// MARK: - Pixel Border

struct PixelBorder: ViewModifier {
    var color: Color = GBColor.dark
    var width: CGFloat = 3

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .strokeBorder(color, lineWidth: width)
            )
    }
}

extension View {
    func pixelBorder(color: Color = GBColor.dark, width: CGFloat = 3) -> some View {
        modifier(PixelBorder(color: color, width: width))
    }
}

// MARK: - Pixel Button Style

struct PixelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .pixelFont(14)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(configuration.isPressed ? GBColor.dark : GBColor.light)
            .foregroundStyle(configuration.isPressed ? GBColor.lightest : GBColor.darkest)
            .pixelBorder(color: GBColor.lightest, width: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension ButtonStyle where Self == PixelButtonStyle {
    static var pixel: PixelButtonStyle { PixelButtonStyle() }
}

// MARK: - Screen Container

struct GBScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GBColor.background)
    }
}

extension View {
    func gbScreen() -> some View {
        modifier(GBScreenBackground())
    }
}
