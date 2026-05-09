import Foundation
import SwiftData

@MainActor
final class GameEngine: ObservableObject {
    @Published var player: Player
    private var context: ModelContext

    init(context: ModelContext, player: Player) {
        self.context = context
        self.player = player
    }

    // MARK: - Daily Check-in

    func dailyCheckIn() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = player.lastActiveDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 { return }       // already checked in today
            if diff == 1 {
                player.consecutiveDays += 1
            } else {
                player.consecutiveDays = 1
                applyDecayPenalty(daysMissed: diff)
            }
        } else {
            player.consecutiveDays = 1
        }
        player.lastActiveDate = Date()
        updateWorldMood()
        try? context.save()
    }

    // MARK: - Quest Actions

    func acceptQuest(_ quest: Quest) {
        quest.status = .active
        try? context.save()
    }

    func completePomodoro(_ quest: Quest, duration: TimeInterval = 1500) {
        let session = PomodoroSession(startTime: Date(), duration: duration, completed: true)
        quest.pomodoroSessions.append(session)
        quest.pomodoroCompleted += 1

        let damage = calculateDamage(player: player, quest: quest)
        quest.monsterHP = max(0, quest.monsterHP - damage)

        player.currentXP += 10
        player.mp = max(0, player.mp - 10)

        try? context.save()
    }

    func completeQuest(_ quest: Quest) {
        quest.status = .completed
        quest.completedAt = Date()

        player.currentXP += quest.xpReward

        switch quest.attributeReward {
        case .strength:     player.strength += 1
        case .intelligence: player.intelligence += 1
        case .charisma:     player.charisma += 1
        case .endurance:    player.endurance += 1
        }

        let bonus = quest.isOverdue ? Int(Double(quest.xpReward) * 1.5) : 0
        if bonus > 0 { player.currentXP += bonus }

        levelUpCheck()
        player.hp = min(player.maxHP, player.hp + 20)
        player.mp = min(player.maxMP, player.mp + 10)
        updateWorldMood()
        try? context.save()
    }

    func failQuest(_ quest: Quest) {
        quest.status = .failed
        player.hp = max(0, player.hp - quest.hpPenalty)
        updateWorldMood()
        try? context.save()
    }

    func abandonQuest(_ quest: Quest) {
        quest.status = .failed
        player.hp = max(0, player.hp - quest.hpPenalty / 2)
        updateWorldMood()
        try? context.save()
    }

    // MARK: - Daily Decay (Anti-Vision)

    func applyDailyDecay() {
        let overdueQuests = fetchOverdueQuests()
        for quest in overdueQuests {
            quest.debtInterest += 1
            quest.monsterHP = min(quest.monsterMaxHP * 2, quest.monsterHP + quest.monsterMaxHP / 4)
        }
        if !overdueQuests.isEmpty {
            player.worldMood = player.worldMood == "sunny" ? "cloudy"
                : player.worldMood == "cloudy" ? "rainy"
                : "stormy"
        }
        try? context.save()
    }

    // MARK: - Level System

    private func levelUpCheck() {
        while player.currentXP >= player.xpToNextLevel {
            player.currentXP -= player.xpToNextLevel
            player.level += 1
            player.xpToNextLevel = Int(Double(player.xpToNextLevel) * 1.3)
            player.maxHP += 10
            player.maxMP += 5
            player.hp = player.maxHP
            player.mp = player.maxMP
            player.strength += 1
            player.intelligence += 1
            player.charisma += 1
            player.endurance += 1
        }
    }

    // MARK: - World Mood

    func updateWorldMood() {
        let overdueCount = fetchOverdueQuests().count
        let failedToday = fetchRecentFailed().count

        if failedToday > 2 || overdueCount > 5 {
            player.worldMood = "stormy"
        } else if failedToday > 0 || overdueCount > 2 {
            player.worldMood = "rainy"
        } else if overdueCount > 0 {
            player.worldMood = "cloudy"
        } else {
            player.worldMood = "sunny"
        }
    }

    // MARK: - Healing

    func rest(amount: Int = 30) {
        player.hp = min(player.maxHP, player.hp + amount)
        player.mp = min(player.maxMP, player.mp + amount / 2)
        try? context.save()
    }

    // MARK: - Achievement Check

    func checkAchievements(achievements: [Achievement]) {
        let completed = player.titles.count
        for achi in achievements where !achi.isUnlocked {
            var unlock = false
            switch achi.id {
            case "first_blood": unlock = completed >= 1
            case "streak_7":    unlock = player.consecutiveDays >= 7
            case "streak_30":   unlock = player.consecutiveDays >= 30
            case "level_10":    unlock = player.level >= 10
            case "level_50":    unlock = player.level >= 50
            case "level_100":   unlock = player.level >= 100
            case "gold_1000":   unlock = player.monthlyIncome >= 8000
            case "gold_10000":  unlock = player.monthlyIncome >= 40000
            case "all_attr_20": unlock = player.totalAttributes >= 80
            default: break
            }
            if unlock {
                achi.isUnlocked = true
                achi.unlockedAt = Date()
                if !player.titles.contains(achi.title) {
                    player.titles.append(achi.title)
                }
            }
        }
        try? context.save()
    }

    // MARK: - Helpers

    private func calculateDamage(player: Player, quest: Quest) -> Int {
        let baseAtk: Int
        switch quest.attributeReward {
        case .strength:     baseAtk = player.strength * 5
        case .intelligence: baseAtk = player.intelligence * 5
        case .charisma:     baseAtk = player.charisma * 5
        case .endurance:    baseAtk = player.endurance * 5
        }
        let crit = Double.random(in: 0...1) < 0.1
        return crit ? baseAtk * 2 : baseAtk + Int.random(in: -5...5)
    }

    private func applyDecayPenalty(daysMissed: Int) {
        player.hp = max(10, player.hp - daysMissed * 15)
        player.worldMood = "rainy"
    }

    private func fetchOverdueQuests() -> [Quest] {
        let descriptor = FetchDescriptor<Quest>(
            predicate: #Predicate { $0.statusRaw != "已完成" && $0.statusRaw != "已失败" }
        )
        let all = (try? context.fetch(descriptor)) ?? []
        return all.filter { $0.isOverdue }
    }

    private func fetchRecentFailed() -> [Quest] {
        let descriptor = FetchDescriptor<Quest>(
            predicate: #Predicate { $0.statusRaw == "已失败" }
        )
        let all = (try? context.fetch(descriptor)) ?? []
        return all.filter {
            guard let completedAt = $0.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }
    }
}
