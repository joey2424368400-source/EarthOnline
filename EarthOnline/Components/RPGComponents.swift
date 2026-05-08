import SwiftUI

// MARK: - Rounded Bar

struct Bar: View {
    var label: String
    var value: Int
    var max: Int
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.textDim)
                Spacer()
                Text("\(value)/\(max)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.text)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.4))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / CGFloat(max), height: 12)
                        .animation(.easeInOut(duration: 0.5), value: value)
                }
            }
            .frame(height: 12)
        }
    }
}

// MARK: - Pixel-style Button

struct PixelButton: View {
    var title: String
    var icon: String = ""
    var color: Color = Theme.accent
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !icon.isEmpty { Text(icon) }
                Text(title)
                    .font(.system(.body, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Quest Card

struct QuestCard: View {
    var quest: Quest

    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(typeColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(typeIcon)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Theme.text)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(quest.type.rawValue)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(typeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(typeColor.opacity(0.15))
                        .clipShape(Capsule())
                    if quest.isOverdue {
                        Text("逾期")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Theme.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Theme.red.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text("Lv.\(quest.effectiveDifficulty)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(Theme.textDim)
                }
            }

            Spacer()

            statusBadge
        }
        .padding(12)
        .background(Theme.panel.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(typeColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var typeIcon: String {
        switch quest.type {
        case .main:   return "⚔️"
        case .side:   return "📋"
        case .daily:  return "☀️"
        case .urgent: return "🔥"
        case .hidden: return "🎁"
        }
    }

    private var typeColor: Color {
        switch quest.type {
        case .main:   return Theme.gold
        case .side:   return Theme.blue
        case .daily:  return Theme.green
        case .urgent: return Theme.red
        case .hidden: return Theme.purple
        }
    }

    private var statusBadge: some View {
        Group {
            switch quest.status {
            case .pending:
                Text("待接")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(Theme.textDim)
            case .active:
                HStack(spacing: 2) {
                    Text("🍅\(quest.pomodoroCompleted)/\(quest.pomodoroRequired)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(Theme.accent)
                }
            case .completed:
                Text("✓")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.green)
            case .failed:
                Text("✗")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Theme.red)
            }
        }
    }
}

// MARK: - World Mood View

struct WorldMoodView: View {
    var mood: String

    var body: some View {
        HStack(spacing: 4) {
            Text(moodEmoji)
                .font(.largeTitle)
            Text(moodLabel)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(moodColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(moodColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var moodEmoji: String {
        switch mood {
        case "sunny":  return "☀️"
        case "cloudy": return "⛅"
        case "rainy":  return "🌧️"
        case "stormy": return "⛈️"
        default:       return "☀️"
        }
    }

    private var moodLabel: String {
        switch mood {
        case "sunny":  return "晴空万里"
        case "cloudy": return "阴云密布"
        case "rainy":  return "大雨滂沱"
        case "stormy": return "风暴来袭"
        default:       return "未知"
        }
    }

    private var moodColor: Color {
        switch mood {
        case "sunny":  return Theme.gold
        case "cloudy": return Theme.textDim
        case "rainy":  return Theme.blue
        case "stormy": return Theme.red
        default:       return Theme.textDim
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    var title: String
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text("▸ \(title)")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(Theme.text)
            Spacer()
            if let action {
                Button(action: action) {
                    Text("查看更多 >")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Theme.accent)
                }
            }
        }
        .padding(.horizontal)
    }
}
