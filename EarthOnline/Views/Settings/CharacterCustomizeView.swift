import SwiftUI

struct CharacterCustomizeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State var engine: GameEngine
    @State private var playerName: String
    @State private var selectedEmoji: String

    init(engine: GameEngine) {
        self.engine = engine
        _playerName = State(initialValue: engine.player.name)
        _selectedEmoji = State(initialValue: engine.player.avatarEmoji)
    }

    private let avatarCategories: [(String, [String])] = [
        ("基础角色", ["🧑‍💼", "🧑‍🎓", "🧑‍🔧", "🧑‍🍳", "🧑‍💻", "🧑‍🎨", "🧑‍🚀", "🧑‍🏫", "🧑‍⚕️", "🧑‍🔬", "🧑‍🎤", "🧑‍🌾"]),
        ("战士系", ["🦸", "🦹", "🧝", "🧙", "🧛", "🧟", "🥷", "🤺", "💂", "🦰", "🧔", "👨‍🚒"]),
        ("动物系", ["🐱", "🐶", "🐼", "🐨", "🐰", "🦊", "🐸", "🐵", "🦁", "🐯", "🐲", "🦄"]),
        ("奇幻系", ["👻", "🤖", "👽", "👾", "🎃", "🤡", "👹", "👺", "💀", "🐉", "🧚", "🦋"]),
        ("高级形象", ["👑", "🎓", "💎", "🌟", "🔥", "⚡", "🌈", "🛡️", "⚔️", "🏆", "🎯", "🔮"]),
        ("像素风", ["🕹️", "🎮", "👾", "📟", "💾", "🖥️", "🎰", "🪙", "💿", "📀", "🧩", "🎲"]),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Preview
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.panel)
                            .frame(width: 100, height: 100)
                            .overlay(Circle().stroke(Theme.accent, lineWidth: 3))
                        Text(selectedEmoji)
                            .font(.system(size: 50))
                    }
                    .padding(.top, 20)

                    Text(playerName.isEmpty ? "勇者" : playerName)
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(Theme.text)

                    Text(engine.player.rank)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Theme.gold)
                }
                .padding(.bottom, 10)

                // Name field
                HStack {
                    Text("⚔️")
                    TextField("输入角色名", text: $playerName)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Theme.text)
                        .padding(10)
                        .background(Theme.bgLight)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider().background(Theme.textDim.opacity(0.2))

                // Emoji grid
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(avatarCategories, id: \.0) { category, emojis in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("▸ \(category)")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(Theme.textDim)
                                    .padding(.horizontal)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                                    ForEach(emojis, id: \.self) { emoji in
                                        Button {
                                            selectedEmoji = emoji
                                        } label: {
                                            Text(emoji)
                                                .font(.title2)
                                                .frame(width: 48, height: 48)
                                                .background(selectedEmoji == emoji ? Theme.accent.opacity(0.3) : Theme.bgLight)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(selectedEmoji == emoji ? Theme.accent : Color.clear, lineWidth: 2)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }

                // Save button
                VStack(spacing: 12) {
                    PixelButton(title: "保存形象", icon: "💾") {
                        save()
                    }
                    Button("取消") { dismiss() }
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Theme.textDim)
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("🎨 自定义形象")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func save() {
        engine.player.name = playerName.isEmpty ? "勇者" : playerName
        engine.player.avatarEmoji = selectedEmoji
        try? context.save()
        dismiss()
    }
}
