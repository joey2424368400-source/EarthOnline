import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @State private var engine: GameEngine?
    @State private var selectedTab = 0
    @State private var showPomodoro = false
    @State private var activeQuest: Quest?

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if let engine {
                TabView(selection: $selectedTab) {
                    DashboardView(engine: engine)
                        .tabItem {
                            Label("世界", systemImage: "globe.asia.australia")
                        }
                        .tag(0)

                    QuestListView(engine: engine)
                        .tabItem {
                            Label("任务", systemImage: "scroll")
                        }
                        .tag(1)

                    VisionBoardView(engine: engine)
                        .tabItem {
                            Label("愿景", systemImage: "sparkles")
                        }
                        .tag(2)

                    AchievementView(engine: engine)
                        .tabItem {
                            Label("成就", systemImage: "trophy")
                        }
                        .tag(3)
                }
                .tint(Theme.accent)
                .onAppear {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(Theme.bg)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            } else {
                ProgressView()
                    .tint(Theme.accent)
            }
        }
        .onAppear { initializeEngine() }
    }

    private func initializeEngine() {
        let playerDesc = FetchDescriptor<Player>()
        let existing = try? context.fetch(playerDesc)
        let player: Player
        if let first = existing?.first {
            player = first
        } else {
            player = Player(name: "勇者")
            context.insert(player)
            try? context.save()
        }
        engine = GameEngine(context: context, player: player)
        engine?.dailyCheckIn()
    }
}
