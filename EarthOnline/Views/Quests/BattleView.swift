import SwiftUI

struct BattleView: View {
    @Environment(\.dismiss) private var dismiss
    @State var engine: GameEngine
    @Bindable var quest: Quest
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var progress: Double = 1.0
    @State private var battleLog: [String] = []
    @State private var showDamage = false
    @State private var damageDealt = 0
    @State private var isCrit = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 30) {
                    // Monster display
                    VStack(spacing: 12) {
                        Text(monsterEmoji)
                            .font(.system(size: 64))
                            .scaleEffect(showDamage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: showDamage)

                        Text(quest.monsterName)
                            .font(.system(.title2, design: .monospaced))
                            .foregroundColor(Theme.red)

                        Bar(label: "怪物HP", value: quest.monsterHP, max: quest.monsterMaxHP, color: Theme.red)
                    }
                    .padding()
                    .background(Theme.bgLight)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.red.opacity(0.3), lineWidth: 1))

                    // VS
                    Text("⚔️ VS ⚔️")
                        .font(.system(.title, design: .monospaced))
                        .foregroundColor(Theme.gold)

                    // Timer
                    VStack(spacing: 16) {
                        Text(timeString)
                            .font(.system(size: 56, design: .monospaced))
                            .foregroundColor(isRunning ? Theme.accent : Theme.text)

                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(isRunning ? Theme.accent : Theme.textDim, lineWidth: 8)
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1), value: progress)
                            Text("🍅")
                                .font(.system(size: 40))
                        }

                        HStack(spacing: 8) {
                            Text("\(quest.pomodoroCompleted)/\(quest.pomodoroRequired)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Theme.textDim)
                        }
                    }

                    // Controls
                    HStack(spacing: 20) {
                        PixelButton(title: isRunning ? "暂停" : "开始战斗", icon: isRunning ? "⏸" : "▶️", color: Theme.accent) {
                            isRunning.toggle()
                        }

                        PixelButton(title: "撤退", icon: "🏳️", color: Theme.textDim) {
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("⚔️ 战斗中")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = Double(timeRemaining) / Double(25 * 60)
            } else {
                completeRound()
            }
        }
    }

    private var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func completeRound() {
        isRunning = false
        timeRemaining = 25 * 60
        progress = 1.0

        engine.completePomodoro(quest)

        let baseDamage: Int
        switch quest.attributeReward {
        case .strength:     baseDamage = engine.player.strength * 5
        case .intelligence: baseDamage = engine.player.intelligence * 5
        case .charisma:     baseDamage = engine.player.charisma * 5
        case .endurance:    baseDamage = engine.player.endurance * 5
        }
        isCrit = Double.random(in: 0...1) < 0.15
        damageDealt = isCrit ? baseDamage * 2 : baseDamage + Int.random(in: -3...3)
        showDamage = true

        let msg = isCrit
            ? "💥 暴击！造成 \(damageDealt) 点伤害！"
            : "⚔️ 攻击！造成 \(damageDealt) 点伤害"
        battleLog.append("[\(Date().formatted(date: .omitted, time: .shortened))] \(msg)")

        if quest.monsterHP <= 0 {
            battleLog.append("🎉 怪物被击败！任务完成！")
            engine.completeQuest(quest)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showDamage = false
        }
    }

    private var monsterEmoji: String {
        let diff = quest.effectiveDifficulty
        switch diff {
        case 1...2:  return "👾"
        case 3...4:  return "👹"
        case 5...6:  return "🐉"
        case 7...8:  return "🧟"
        case 9...10: return "🐲"
        default:     return "👾"
        }
    }
}
