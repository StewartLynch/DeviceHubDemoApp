import SwiftUI

struct DashboardView: View {
    let model: AppModel

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    DashboardContentView(
                        workouts: model.workouts.workouts,
                        advice: model.location.advice,
                        locationSource: model.location.source,
                        isWideLayout: geometry.size.width > geometry.size.height
                    )
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Altitude Recovery")
        }
    }
}

private struct DashboardContentView: View {
    let workouts: [Workout]
    let advice: RecoveryAdvice
    let locationSource: LocationService.Source
    let isWideLayout: Bool

    var body: some View {
        if isWideLayout {
            HStack(alignment: .top, spacing: 16) {
                TrainingSummaryView(workouts: workouts)
                    .frame(maxWidth: .infinity)

                RecoveryCard(
                    advice: advice,
                    locationSource: locationSource,
                    isWideLayout: true
                )
                .frame(maxWidth: .infinity)
            }
        } else {
            VStack(spacing: 16) {
                TrainingSummaryView(workouts: workouts)

                RecoveryCard(
                    advice: advice,
                    locationSource: locationSource,
                    isWideLayout: false
                )
            }
        }
    }
}

private struct TrainingSummaryView: View {
    let workouts: [Workout]

    private var totalMinutes: Int {
        workouts.reduce(0) { $0 + $1.durationMinutes }
    }

    private var elevationGain: Int {
        workouts.reduce(0) { $0 + $1.elevationGainMeters }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Last 7 Days", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            HStack(spacing: 12) {
                MetricView(value: "\(workouts.count)", label: "Workouts")
                MetricView(value: "\(totalMinutes)", label: "Minutes")
                MetricView(value: "\(elevationGain)", label: "Metres")
            }

            if let latest = workouts.first {
                Divider()

                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Latest: \(latest.activity.rawValue)")
                            .font(.subheadline.weight(.semibold))
                        Text(latest.date, format: .dateTime.weekday(.wide).month().day())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: latest.activity.symbolName)
                        .font(.title2)
                        .foregroundStyle(.indigo)
                }
            }
        }
        .cardStyle()
    }
}

private struct MetricView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
