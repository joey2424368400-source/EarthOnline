import SwiftUI
import SwiftData

struct QuestListView: View {
    @State var engine: GameEngine
    @Query(sort: \Quest.createdAt, order: .reverse)
    private var allQuests: [Quest]
    @State private var selectedFilter: QuestType? = nil
    @State private var showCreate = false
    @State private var showDeleteAlert = false
    @State private var questToDelete: Quest?

    var filteredQuests: [Quest] {
        guard let filter = selectedFilter else { return allQuests }
        return allQuests.filter { $0.type == filter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredQuests) { quest in
                            NavigationLink(destination: QuestDetailView(engine: engine, quest: quest)) {
                                QuestCard(quest: quest)
                            }
                            .contextMenu {
                                if quest.status == .pending || quest.status == .active {
                                    Button(role: .destructive) {
                                        questToDelete = quest
                                        showDeleteAlert = true
                                    } label: {
                                        Label("放弃任务", systemImage: "xmark.circle")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.bg)
            .navigationTitle("📜 任务板")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.accent)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                QuestCreateView(engine: engine)
            }
            .alert("放弃任务", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("确认放弃", role: .destructive) {
                    if let quest = questToDelete {
                        engine.abandonQuest(quest)
                    }
                }
            } message: {
                Text("放弃任务将扣除一半金币并损失HP。是否继续？")
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "全部", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                ForEach(QuestType.allCases, id: \.self) { type in
                    FilterChip(title: type.rawValue, isSelected: selectedFilter == type) {
                        selectedFilter = type
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Theme.bgLight)
    }
}

struct FilterChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(isSelected ? .white : Theme.textDim)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Theme.accent : Theme.panel)
                .clipShape(Capsule())
        }
    }
}
