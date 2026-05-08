import Foundation
import SwiftData

@Model
final class Achievement {
    var id: String         // 唯一标识
    var title: String
    var achievementDescription: String
    var icon: String       // emoji
    var isUnlocked: Bool
    var unlockedAt: Date?
    var rarity: String     // common / rare / epic / legendary

    init(
        id: String,
        title: String,
        description: String = "",
        icon: String = "🏆",
        rarity: String = "common"
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = description
        self.icon = icon
        self.isUnlocked = false
        self.unlockedAt = nil
        self.rarity = rarity
    }

    static let allAchievements: [(id: String, title: String, description: String, icon: String, rarity: String)] = [
        ("first_blood", "初战告捷", "完成第一个任务", "⚔️", "common"),
        ("streak_7", "晨光守望者", "连续7天登录", "🌅", "rare"),
        ("streak_30", "钢铁意志", "连续30天登录", "🛡️", "epic"),
        ("quest_10", "任务达人", "完成10个支线任务", "📋", "common"),
        ("quest_50", "任务大师", "完成50个任务", "🎯", "rare"),
        ("quest_100", "任务传说", "完成100个任务", "👑", "legendary"),
        ("main_1", "主线觉醒", "完成1条主线任务", "💡", "rare"),
        ("main_5", "命运征服者", "完成5条主线任务", "⚡", "legendary"),
        ("book_10", "知识探索者", "累计阅读10本书", "📚", "rare"),
        ("sport_30", "铁之意志", "健身30次", "💪", "epic"),
        ("early_21", "黎明使者", "连续21天早起", "☀️", "epic"),
        ("pomodoro_100", "番茄骑士", "完成100个番茄钟", "🍅", "rare"),
        ("pomodoro_500", "时间领主", "完成500个番茄钟", "⏰", "legendary"),
        ("gold_1000", "万元户", "累积财富 ¥10,000", "💰", "common"),
        ("gold_10000", "财务自由", "累积财富 ¥100,000", "💎", "legendary"),
        ("level_10", "初露锋芒", "达到10级", "📈", "common"),
        ("level_50", "名扬四海", "达到50级", "🌟", "epic"),
        ("level_100", "封神之路", "达到100级", "🔮", "legendary"),
        ("hidden_5", "命运的馈赠", "发现5个隐藏任务", "🎁", "epic"),
        ("no_delay_30", "时间的主人", "30天内没有任务失败", "⏳", "legendary"),
        ("all_attr_20", "全面发展", "全属性达到20", "🎭", "epic"),
    ]
}
