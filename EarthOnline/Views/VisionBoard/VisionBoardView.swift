import SwiftUI
import SwiftData

struct VisionBoardView: View {
    @State var engine: GameEngine
    @Query(filter: #Predicate<Quest> { $0.statusRaw == "进行中" || $0.statusRaw == "待接受" })
    private var activeQuests: [Quest]

    @Query(filter: #Predicate<Quest> { $0.statusRaw == "已完成" },
            sort: \Quest.completedAt, order: .reverse)
    private var completedQuests: [Quest]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Gallery header
                    VStack(spacing: 4) {
                        Text("🏰 愿景画廊")
                            .font(.system(.title2, design: .monospaced))
                            .foregroundColor(Theme.gold)
                        Text("\(completedQuests.count) 个愿景已实现")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Theme.textDim)
                    }
                    .padding(.top)

                    // Unlocked visions
                    if !completedQuests.isEmpty {
                        unlockedVisions
                    }

                    // Pending visions
                    if !activeQuests.isEmpty {
                        pendingVisions
                    }

                    // Locked placeholder
                    lockedPlaceholders
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("🌟 愿景板")
        }
    }

    // MARK: - Unlocked Visions

    private var unlockedVisions: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "已解锁的宝箱")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(completedQuests.prefix(20)) { quest in
                    VStack(spacing: 8) {
                        Text(quest.visionImage)
                            .font(.system(size: 36))
                            .padding()
                            .background(Theme.gold.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.gold.opacity(0.4), lineWidth: 1)
                            )
                        Text(quest.title)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Theme.text)
                            .lineLimit(1)
                        Text(quest.visionText)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Theme.textDim)
                            .lineLimit(1)
                    }
                    .padding(8)
                    .background(Theme.bgLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Pending Visions

    private var pendingVisions: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "待解锁的秘境")

            ForEach(activeQuests.prefix(10)) { quest in
                HStack(spacing: 12) {
                    Text(quest.visionImage)
                        .font(.title2)
                        .grayscale(0.5)
                        .opacity(0.6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(quest.title)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Theme.textDim)
                        Text(quest.visionText)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Theme.textDim.opacity(0.6))
                    }

                    Spacer()

                    // Progress
                    if quest.pomodoroRequired > 0 {
                        Text("\(quest.pomodoroCompleted)/\(quest.pomodoroRequired)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Theme.accent)
                    }

                    Text("🔒")
                        .font(.caption)
                        .opacity(0.4)
                }
                .padding(10)
                .background(Theme.bgLight.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Locked Placeholders

    private var lockedPlaceholders: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "传说中的宝藏")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<6, id: \.self) { i in
                    VStack(spacing: 6) {
                        Text("❓")
                            .font(.title)
                            .padding(12)
                            .background(Theme.panel.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("???")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Theme.textDim.opacity(0.4))
                    }
                    .padding(8)
                    .background(Theme.bgLight.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.textDim.opacity(0.15), lineWidth: 1)
                    )
                }
            }
        }
    }
}
