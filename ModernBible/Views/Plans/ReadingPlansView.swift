import SwiftUI

struct ReadingPlansView: View {
    @State private var activePlans: [ReadingPlanProgress] = []
    private let availablePlans: [ReadingPlanDefinition] = BundledPlans.all

    var body: some View {
        List {
            if !activePlans.isEmpty {
                Section(L("plans.in_progress")) {
                    ForEach(activePlans) { plan in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(plan.title).font(.headline)
                            ProgressView(value: plan.progressFraction)
                            Text("\(plan.completedDayIndexes.count)/\(plan.totalDays) \(L("plans.days"))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section(L("plans.available")) {
                ForEach(availablePlans) { plan in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title).font(.headline)
                        Text(plan.descriptionText).font(.subheadline).foregroundStyle(.secondary)
                        Button(L("plans.start")) {
                            UserDataService.shared.startPlan(plan)
                            activePlans = UserDataService.shared.activePlans()
                        }
                        .font(.caption.bold())
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(L("tab.plans"))
        .onAppear { activePlans = UserDataService.shared.activePlans() }
    }
}

enum BundledPlans {
    static let all: [ReadingPlanDefinition] = [
        ReadingPlanDefinition(id: "nt-90", title: "New Testament in 90 Days", descriptionText: "A steady daily pace through Matthew–Revelation.", totalDays: 90, readingsByDay: [:]),
        ReadingPlanDefinition(id: "proverbs-31", title: "Proverbs in a Month", descriptionText: "One chapter of Proverbs a day.", totalDays: 31, readingsByDay: [:]),
        ReadingPlanDefinition(id: "chrono-365", title: "Chronological in a Year", descriptionText: "The whole Bible in the order events occurred.", totalDays: 365, readingsByDay: [:])
    ]
}

#Preview { NavigationStack { ReadingPlansView() } }
