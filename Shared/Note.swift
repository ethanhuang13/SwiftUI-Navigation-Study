//
//  Note.swift
//  Nav (iOS)
//
//  Created by Ethan Huang on 2021/10/3.
//

import Foundation

struct Note: Identifiable, Codable, Hashable {
  var id = UUID()
  var content: String

  static func random() -> Note {
    func randomString(length: Int) -> String {
      let emojis = "🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐🍈🍒🍑🥭🍍🥥🥝🍅🍆🥑"
      return String((0 ..< length).map { _ in emojis.randomElement()! })
    }

    return Note(content: Array(repeating: randomString(length: 1), count: 100).joined())
  }
}
