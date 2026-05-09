import SwiftUI
import SwiftData

struct DashboardView: View {
    @State var engine: GameEngine
    @State private var showCustomize = false
    @Query(filter: #Predicate<Quest> { $0.statusRaw != "已完成" && $0.statusRaw != "已失败" },
            sort: \Quest.deadline)
    private var activeQuests: [Quest]

    @Query(filter: #Predicate<Quest> { $0.statusRaw == "已完成" })
    private var completedQuests: [Quest]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    playerHeader
                    statsPanel
                    worldStatus
                    activeQuestsSection
                    quickStats
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("🌍 地球Online")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCustomize = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(Theme.accent)
                    }
                }
            }
        }
        .onAppear { engine.dailyCheckIn() }
        .sheet(isPresented: $showCustomize) {
            CharacterCustomizeView(engine: engine)
        }
    }

    // MARK: - Player Header

    private var playerHeader: some View {
        VStack(spacing: 8) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(Theme.panel)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Theme.accent, lineWidth: 2))
                Text(engine.player.avatarEmoji)
                    .font(.system(size: 40))
            }
            .onTapGesture { showCustomize = true }

            Text(engine.player.name)
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(Theme.text)

            Text(engine.player.rank)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(Theme.gold)

            Text("Lv.\(engine.player.level)")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(Theme.accent)

            // XP Bar
            Bar(label: "EXP", value: engine.player.currentXP, max: engine.player.xpToNextLevel, color: Theme.xpAmber)
        }
        .padding()
        .background(Theme.bgLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.accent.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Stats Panel

    private var statsPanel: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "角色状态")

            Bar(label: "❤️ HP", value: engine.player.hp, max: engine.player.maxHP, color: Theme.hpGreen)
            Bar(label: "💙 MP", value: engine.player.mp, max: engine.player.maxMP, color: Theme.mpBlue)

            HStack(spacing: 12) {
                statItem("💪 力量", engine.player.strength, Theme.red)
                statItem("🧠 智力", engine.player.intelligence, Theme.purple)
                statItem("✨ 魅力", engine.player.charisma, Theme.gold)
                statItem("🛡️ 耐力", engine.player.endurance, Theme.blue)
            }

            HStack(spacing: 12) {
                Label("¥\(engine.player.monthlyIncome)/月", systemImage: "💼")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.green)
                Label("\(engine.player.consecutiveDays)天", systemImage: "🔥")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.orange)
            }
        }
        .padding()
        .background(Theme.bgLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(_ label: String, _ value: Int, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(Theme.textDim)
            Text("\(value)")
                .font(.system(.title3, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - World Status

    private var worldStatus: some View {
        HStack {
            WorldMoodView(mood: engine.player.worldMood)
            Spacer()
            VStack(alignment: .trailing) {
                Text("活跃任务: \(activeQuests.count)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.textDim)
                Text("已完成: \(completedQuests.count)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.green)
            }
            .font(.system(.caption, design: .monospaced))
        }
        .padding()
        .background(Theme.bgLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Active Quests

    private var activeQuestsSection: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "当前任务板")
            if activeQuests.isEmpty {
                Text("✨ 没有活跃任务\n去任务板接受新任务吧")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.textDim)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ForEach(activeQuests.prefix(5)) { quest in
                    QuestCard(quest: quest)
                }
            }
        }
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        HStack(spacing: 12) {
            PixelButton(title: "休息恢复", icon: "🏨") {
                engine.rest()
            }
            PixelButton(title: "更新状态", icon: "🔄", color: Theme.blue) {
                engine.dailyCheckIn()
                engine.applyDailyDecay()
            }
        }
    }
}
