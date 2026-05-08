import SwiftUI
import SwiftData

struct QuestCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State var engine: GameEngine

    @State private var title = ""
    @State private var questDescription = ""
    @State private var type: QuestType = .side
    @State private var difficulty: Double = 3
    @State private var monsterName = ""
    @State private var pomodoroRequired = 1
    @State private var xpReward = 50
    @State private var goldReward = 20
    @State private var attributeReward: AttributeType = .endurance
    @State private var visionText = ""
    @State private var visionImage = "🌟"
    @State private var antiVisionText = ""
    @State private var antiVisionImage = "💀"
    @State private var hpPenalty = 10
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(86400 * 3)

    let visionIcons = ["🌟", "🏆", "💰", "🏰", "🎓", "💎", "🎯", "🌈", "🚀", "🎉"]
    let antiIcons = ["💀", "😰", "📉", "🪦", "👻", "💸", "⏳", "🔗", "🌧️", "🔥"]

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                monsterSection
                rewardSection
                visionSection
                antiVisionSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("📝 创建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundColor(Theme.textDim)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") { createQuest() }
                        .foregroundColor(Theme.accent)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private var basicInfoSection: some View {
        Section {
            TextField("任务名称", text: $title)
                .foregroundColor(Theme.text)
            TextField("任务描述 (可选)", text: $questDescription)
                .foregroundColor(Theme.text)

            Picker("类型", selection: $type) {
                ForEach(QuestType.allCases, id: \.self) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .tint(Theme.accent)

            VStack {
                Text("难度: \(Int(difficulty))")
                    .foregroundColor(Theme.textDim)
                Slider(value: $difficulty, in: 1...10, step: 1)
                    .tint(Theme.red)
            }

            Toggle("设置截止日期", isOn: $hasDeadline)
                .tint(Theme.accent)
            if hasDeadline {
                DatePicker("截止日期", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    .colorScheme(.dark)
            }
        } header: {
            Text("▸ 基本信息").foregroundColor(Theme.accent)
        }
        .listRowBackground(Theme.bgLight)
    }

    private var monsterSection: some View {
        Section {
            TextField("怪物名称", text: $monsterName)
                .foregroundColor(Theme.text)
            Stepper("番茄钟: \(pomodoroRequired)", value: $pomodoroRequired, in: 1...20)
                .foregroundColor(Theme.text)
            Stepper("失败扣血: \(hpPenalty) HP", value: $hpPenalty, in: 0...100, step: 5)
                .foregroundColor(Theme.text)
        } header: {
            Text("👾 Boss 设置").foregroundColor(Theme.red)
        }
        .listRowBackground(Theme.bgLight)
    }

    private var rewardSection: some View {
        Section {
            Stepper("经验值: \(xpReward) EXP", value: $xpReward, in: 10...1000, step: 10)
                .foregroundColor(Theme.text)
            Stepper("金币: \(goldReward) G", value: $goldReward, in: 5...500, step: 5)
                .foregroundColor(Theme.text)
            Picker("属性奖励", selection: $attributeReward) {
                ForEach(AttributeType.allCases, id: \.self) { a in
                    Text(a.rawValue).tag(a)
                }
            }
            .tint(Theme.accent)
        } header: {
            Text("🎁 奖励设置").foregroundColor(Theme.gold)
        }
        .listRowBackground(Theme.bgLight)
    }

    private var visionSection: some View {
        Section {
            TextField("愿景描述 (完成后得到什么)", text: $visionText)
                .foregroundColor(Theme.text)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                ForEach(visionIcons, id: \.self) { icon in
                    Button {
                        visionImage = icon
                    } label: {
                        Text(icon)
                            .font(.title2)
                            .padding(6)
                            .background(visionImage == icon ? Theme.gold.opacity(0.3) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        } header: {
            Text("🌟 愿景").foregroundColor(Theme.gold)
        }
        .listRowBackground(Theme.bgLight)
    }

    private var antiVisionSection: some View {
        Section {
            TextField("反愿景描述 (不做的代价)", text: $antiVisionText)
                .foregroundColor(Theme.text)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                ForEach(antiIcons, id: \.self) { icon in
                    Button {
                        antiVisionImage = icon
                    } label: {
                        Text(icon)
                            .font(.title2)
                            .padding(6)
                            .background(antiVisionImage == icon ? Theme.red.opacity(0.3) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        } header: {
            Text("💀 反愿景").foregroundColor(Theme.red)
        }
        .listRowBackground(Theme.bgLight)
    }

    private func createQuest() {
        let quest = Quest(
            title: title,
            questDescription: questDescription,
            type: type,
            difficulty: Int(difficulty),
            monsterName: monsterName.isEmpty ? defaultMonster : monsterName,
            pomodoroRequired: pomodoroRequired,
            xpReward: xpReward,
            goldReward: goldReward,
            attributeReward: attributeReward,
            visionText: visionText,
            visionImage: visionImage,
            antiVisionText: antiVisionText,
            antiVisionImage: antiVisionImage,
            hpPenalty: hpPenalty,
            deadline: hasDeadline ? deadline : nil
        )
        context.insert(quest)
        try? context.save()
        engine.acceptQuest(quest)
        dismiss()
    }

    private var defaultMonster: String {
        switch type {
        case .main:   return "深渊魔龙"
        case .side:   return "拖延小怪"
        case .daily:  return "懒惰史莱姆"
        case .urgent: return "死线恶魔"
        case .hidden: return "神秘幻影"
        }
    }
}
