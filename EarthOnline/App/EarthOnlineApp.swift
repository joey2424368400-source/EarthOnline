import SwiftUI
import SwiftData

@main
struct EarthOnlineApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Player.self, Quest.self, Achievement.self]) { result in
            switch result {
            case .success(let container):
                seedAchievements(container)
            case .failure(let error):
                fatalError("Failed to create model container: \(error)")
            }
        }
    }

    private func seedAchievements(_ container: ModelContainer) {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Achievement>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        for def in Achievement.allAchievements {
            let achi = Achievement(
                id: def.id,
                title: def.title,
                description: def.description,
                icon: def.icon,
                rarity: def.rarity
            )
            context.insert(achi)
        }
        try? context.save()
    }
}
