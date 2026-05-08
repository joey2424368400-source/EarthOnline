import Foundation
import SwiftData

enum QuestType: String, Codable, CaseIterable {
    case main   = "主线任务"
    case side   = "支线任务"
    case daily  = "每日任务"
    case urgent = "紧急任务"
    case hidden = "隐藏任务"
}

enum QuestStatus: String, Codable {
    case pending    = "待接受"
    case active     = "进行中"
    case completed  = "已完成"
    case failed     = "已失败"
}

enum AttributeType: String, Codable, CaseIterable {
    case strength     = "力量"
    case intelligence = "智力"
    case charisma     = "魅力"
    case endurance    = "耐力"
}

@Model
final class Quest {
    var title: String
    var questDescription: String
    var typeRaw: String
    var statusRaw: String
    var difficulty: Int          // 1-10
    var monsterName: String      // 拖延怪物的名字
    var monsterHP: Int
    var monsterMaxHP: Int
    var pomodoroRequired: Int    // 需要几个番茄钟
    var pomodoroCompleted: Int
    var xpReward: Int
    var wealthReward: Int          // ¥
    var attributeRewardRaw: String
    var visionText: String       // 愿景描述
    var visionImage: String      // 愿景emoji
    var antiVisionText: String   // 反愿景描述
    var antiVisionImage: String  // 反愿景emoji
    var debtInterest: Int        // 拖延利息（每天增加的难度）
    var hpPenalty: Int           // 失败扣血
    var createdAt: Date
    var deadline: Date?
    var completedAt: Date?
    var pomodoroSessions: [PomodoroSession]

    var type: QuestType {
        get { QuestType(rawValue: typeRaw) ?? .side }
        set { typeRaw = newValue.rawValue }
    }

    var status: QuestStatus {
        get { QuestStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var attributeReward: AttributeType {
        get { AttributeType(rawValue: attributeRewardRaw) ?? .endurance }
        set { attributeRewardRaw = newValue.rawValue }
    }

    var isOverdue: Bool {
        guard let deadline else { return false }
        return Date() > deadline && status != .completed && status != .failed
    }

    var effectiveDifficulty: Int {
        isOverdue ? min(10, difficulty + debtInterest) : difficulty
    }

    init(
        title: String,
        questDescription: String = "",
        type: QuestType = .side,
        difficulty: Int = 3,
        monsterName: String = "拖延小怪",
        pomodoroRequired: Int = 1,
        xpReward: Int = 50,
        wealthReward: Int = 20,
        attributeReward: AttributeType = .endurance,
        visionText: String = "",
        visionImage: String = "🌟",
        antiVisionText: String = "",
        antiVisionImage: String = "💀",
        hpPenalty: Int = 10,
        deadline: Date? = nil
    ) {
        self.title = title
        self.questDescription = questDescription
        self.typeRaw = type.rawValue
        self.statusRaw = QuestStatus.pending.rawValue
        self.difficulty = min(10, max(1, difficulty))
        self.monsterName = monsterName
        self.monsterHP = difficulty * 100
        self.monsterMaxHP = difficulty * 100
        self.pomodoroRequired = pomodoroRequired
        self.pomodoroCompleted = 0
        self.xpReward = xpReward
        self.wealthReward = wealthReward
        self.attributeRewardRaw = attributeReward.rawValue
        self.visionText = visionText
        self.visionImage = visionImage
        self.antiVisionText = antiVisionText
        self.antiVisionImage = antiVisionImage
        self.debtInterest = 0
        self.hpPenalty = hpPenalty
        self.createdAt = Date()
        self.deadline = deadline
        self.completedAt = nil
        self.pomodoroSessions = []
    }
}

struct PomodoroSession: Codable {
    var startTime: Date
    var duration: TimeInterval // seconds
    var completed: Bool
}
