import Foundation
import SwiftData

@Model
final class Player {
    var name: String
    var level: Int
    var currentXP: Int
    var xpToNextLevel: Int
    var hp: Int
    var maxHP: Int
    var mp: Int
    var maxMP: Int
    var strength: Int
    var intelligence: Int
    var charisma: Int
    var endurance: Int
    var gold: Int
    var worldMood: String // sunny / cloudy / rainy / stormy
    var consecutiveDays: Int
    var lastActiveDate: Date?
    var avatarEmoji: String
    var titles: [String]
    var createdAt: Date

    init(name: String = "勇者") {
        self.name = name
        self.avatarEmoji = "🧑‍💼"
        self.level = 1
        self.currentXP = 0
        self.xpToNextLevel = 100
        self.hp = 100
        self.maxHP = 100
        self.mp = 50
        self.maxMP = 50
        self.strength = 5
        self.intelligence = 5
        self.charisma = 5
        self.endurance = 5
        self.gold = 0
        self.worldMood = "sunny"
        self.consecutiveDays = 0
        self.lastActiveDate = nil
        self.titles = []
        self.createdAt = Date()
    }

    var hpPercent: Double { Double(hp) / Double(maxHP) }
    var mpPercent: Double { Double(mp) / Double(maxMP) }
    var xpPercent: Double { Double(currentXP) / Double(xpToNextLevel) }
    var totalAttributes: Int { strength + intelligence + charisma + endurance }
    var rank: String {
        switch level {
        case 0..<5:  return "F 级冒险者"
        case 5..<10: return "E 级冒险者"
        case 10..<20: return "D 级冒险者"
        case 20..<30: return "C 级冒险者"
        case 30..<50: return "B 级冒险者"
        case 50..<70: return "A 级冒险者"
        case 70..<100: return "S 级冒险者"
        default:      return "传说级英雄"
        }
    }
}
