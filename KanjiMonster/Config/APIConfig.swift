//
//  APIConfig.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import Foundation

enum APIConfig {
    static var geminiAPIKey: String? {
        if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !key.isEmpty {
            return key
        }
        if let path = Bundle.main.path(forResource: "APIConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["GEMINI_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        return nil
    }

    static var isAIEnabled: Bool {
        geminiAPIKey != nil
    }

    static func createGeminiService() -> GeminiService? {
        guard let key = geminiAPIKey else { return nil }
        return GeminiService(apiKey: key)
    }
}
