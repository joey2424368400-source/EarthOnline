import SwiftUI
import SwiftData

struct AchievementView: View {
    @State var engine: GameEngine
    @Query private var achievements: [Achievement]
    @State private var selectedRarity: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                rarityFilter
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAchievements) { achi in
                            achievementRow(achi)
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.bg)
            .navigationTitle("🏆 成就殿堂")
        }
        .onAppear { engine.checkAchievements(achievements: achievements) }
    }

    private var rarityFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "全部", isSelected: selectedRarity == nil) {
                    selectedRarity = nil
                }
                FilterChip(title: "普通", isSelected: selectedRarity == "common") {
                    selectedRarity = "common"
                }
                FilterChip(title: "稀有", isSelected: selectedRarity == "rare") {
                    selectedRarity = "rare"
                }
                FilterChip(title: "史诗", isSelected: selectedRarity == "epic") {
                    selectedRarity = "epic"
                }
                FilterChip(title: "传说", isSelected: selectedRarity == "legendary") {
                    selectedRarity = "legendary"
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Theme.bgLight)
    }

    private var filteredAchievements: [Achievement] {
        guard let rarity = selectedRarity else { return achievements }
        return achievements.filter { $0.rarity == rarity }
    }

    private func achievementRow(_ achi: Achievement) -> some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(achi.isUnlocked ? rarityColor(achi.rarity).opacity(0.2) : Theme.panel.opacity(0.3))
                    .frame(width: 48, height: 48)
                Text(achi.isUnlocked ? achi.icon : "🔒")
                    .font(.title2)
                    .grayscale(achi.isUnlocked ? 0 : 1)
                    .opacity(achi.isUnlocked ? 1 : 0.3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(achi.title)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(achi.isUnlocked ? Theme.text : Theme.textDim.opacity(0.5))
                Text(achi.achievementDescription)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(achi.isUnlocked ? Theme.textDim : Theme.textDim.opacity(0.4))
            }

            Spacer()

            // Rarity badge
            Text(rarityLabel(achi.rarity))
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(rarityColor(achi.rarity))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(rarityColor(achi.rarity).opacity(0.15))
                .clipShape(Capsule())
                .opacity(achi.isUnlocked ? 1 : 0.3)
        }
        .padding(12)
        .background(achi.isUnlocked ? Theme.bgLight : Theme.bgLight.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achi.isUnlocked ? rarityColor(achi.rarity).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private func rarityColor(_ rarity: String) -> Color {
        switch rarity {
        case "common":    return Theme.textDim
        case "rare":      return Theme.blue
        case "epic":      return Theme.purple
        case "legendary": return Theme.gold
        default:          return Theme.textDim
        }
    }

    private func rarityLabel(_ rarity: String) -> String {
        switch rarity {
        case "common":    return "普通"
        case "rare":      return "稀有"
        case "epic":      return "史诗"
        case "legendary": return "传说"
        default:          return ""
        }
    }
}
