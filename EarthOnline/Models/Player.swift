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
    var wealth: Int           // ¥ 人民币
    var worldMood: String     // sunny / cloudy / rainy / stormy
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
        self.wealth = 0
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
        case 0..<2:  return "无业游民"
        case 2..<4:  return "搬砖学徒"
        case 4..<7:  return "职场小白"
        case 7..<10: return "基层骨干"
        case 10..<15: return "业务能手"
        case 15..<20: return "项目组长"
        case 20..<30: return "部门经理"
        case 30..<40: return "高级总监"
        case 40..<55: return "副总裁"
        case 55..<70: return "合伙人"
        case 70..<90: return "行业领袖"
        case 90..<120: return "商业巨擘"
        default:      return "时代传奇"
        }
    }

    var monthlyIncome: Int {
        switch level {
        case 0..<2:  return 0
        case 2..<4:  return 2000
        case 4..<7:  return 5000
        case 7..<10: return 8000
        case 10..<15: return 12000
        case 15..<20: return 18000
        case 20..<30: return 25000
        case 30..<40: return 40000
        case 40..<55: return 60000
        case 55..<70: return 100000
        case 70..<90: return 200000
        case 90..<120: return 500000
        default:      return 1000000
        }
    }
}
