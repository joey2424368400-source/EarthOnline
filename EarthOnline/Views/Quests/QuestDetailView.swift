import SwiftUI

struct QuestDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var engine: GameEngine
    @Bindable var quest: Quest
    @State private var showBattle = false
    @State private var battleMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                questHeader
                monsterPanel
                visionPanel
                antiVisionPanel
                rewardsPanel
                actionButtons
                if !battleMessage.isEmpty {
                    battleLog
                }
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle("任务详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showBattle) {
            BattleView(engine: engine, quest: quest)
        }
    }

    // MARK: - Quest Header

    private var questHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text(quest.type.rawValue)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(typeColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(typeColor.opacity(0.15))
                    .clipShape(Capsule())
                Spacer()
                statusLabel
            }

            Text(quest.title)
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !quest.questDescription.isEmpty {
                Text(quest.questDescription)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.textDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let deadline = quest.deadline {
                HStack {
                    Text(quest.isOverdue ? "⚠️ 已逾期" : "⏰ 截止: \(deadline.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(quest.isOverdue ? Theme.red : Theme.textDim)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 16) {
                Label("难度 Lv.\(quest.effectiveDifficulty)", systemImage: "star.fill")
                    .foregroundColor(Theme.orange)
                Label("🍅 x\(quest.pomodoroRequired)", systemImage: "")
                    .foregroundColor(Theme.accent)
                if quest.debtInterest > 0 {
                    Label("债务 +\(quest.debtInterest)", systemImage: "arrow.up")
                        .foregroundColor(Theme.red)
                }
            }
            .font(.system(.caption, design: .monospaced))
        }
        .padding()
        .background(Theme.bgLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Monster Panel

    private var monsterPanel: some View {
        VStack(spacing: 8) {
            Text("👾 当前 Boss: \(quest.monsterName)")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(Theme.red)
            Bar(
                label: "怪物HP",
                value: quest.monsterHP,
                max: quest.monsterMaxHP,
                color: Theme.red
            )
            if quest.pomodoroCompleted > 0 {
                Text("已造成伤害: \(quest.pomodoroCompleted) 个番茄钟")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.textDim)
            }
        }
        .padding()
        .background(Theme.bgLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.red.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Vision Panel

    private var visionPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🌟 愿景奖励")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(Theme.gold)
                Spacer()
            }
            HStack(spacing: 8) {
                Text(quest.visionImage)
                    .font(.largeTitle)
                Text(quest.visionText.isEmpty ? "完成任务，变得更强！" : quest.visionText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.text)
                Spacer()
            }
            .padding()
            .background(Theme.gold.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Theme.bgLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Anti-Vision Panel

    private var antiVisionPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Text("💀 反愿景：失败的代价")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(Theme.red)
                Spacer()
            }
            HStack(spacing: 8) {
                Text(quest.antiVisionImage)
                    .font(.largeTitle)
                Text(quest.antiVisionText.isEmpty ? "逃避只会让怪物更强！" : quest.antiVisionText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.textDim)
                Spacer()
            }
            .padding()
            .background(Theme.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Theme.bgLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.red.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Rewards

    private var rewardsPanel: some View {
        HStack(spacing: 12) {
            rewardChip("⭐ +\(quest.xpReward) EXP", Theme.xpAmber)
            rewardChip("🪙 +\(quest.goldReward)G", Theme.gold)
            rewardChip("📈 +1 \(quest.attributeReward.rawValue)", Theme.green)
        }
        .font(.system(.caption, design: .monospaced))
    }

    private func rewardChip(_ text: String, _ color: Color) -> some View {
        Text(text)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            switch quest.status {
            case .pending:
                PixelButton(title: "接受任务", icon: "⚔️") {
                    engine.acceptQuest(quest)
                }
            case .active:
                PixelButton(title: "进入战斗 (番茄钟)", icon: "🍅", color: Theme.red) {
                    showBattle = true
                }
                PixelButton(title: "完成任务", icon: "✅", color: Theme.green) {
                    engine.completeQuest(quest)
                    dismiss()
                }
                PixelButton(title: "放弃任务", icon: "🏳️", color: Theme.textDim) {
                    engine.abandonQuest(quest)
                    dismiss()
                }
            case .completed:
                Text("✅ 任务已完成！")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(Theme.green)
            case .failed:
                Text("💀 任务已失败")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(Theme.red)
            }
        }
    }

    // MARK: - Battle Log

    private var battleLog: some View {
        Text(battleMessage)
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(Theme.blue)
            .padding()
            .background(Theme.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Helpers

    private var typeColor: Color {
        switch quest.type {
        case .main:   return Theme.gold
        case .side:   return Theme.blue
        case .daily:  return Theme.green
        case .urgent: return Theme.red
        case .hidden: return Theme.purple
        }
    }

    private var statusLabel: some View {
        Group {
            switch quest.status {
            case .pending:   Text("待接受").foregroundColor(Theme.textDim)
            case .active:    Text("进行中").foregroundColor(Theme.blue)
            case .completed: Text("已完成").foregroundColor(Theme.green)
            case .failed:    Text("已失败").foregroundColor(Theme.red)
            }
        }
        .font(.system(.caption, design: .monospaced))
    }
}
