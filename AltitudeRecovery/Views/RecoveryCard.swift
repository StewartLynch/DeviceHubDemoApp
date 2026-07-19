import SwiftUI

struct RecoveryCard: View {
    let advice: RecoveryAdvice
    let isWideLayout: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label("Recovery Advice", systemImage: advice.systemImage)
                    .font(.headline)
                    .foregroundStyle(.indigo)

                Spacer(minLength: 8)

                Text("\(advice.altitudeMeters) m")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Text(advice.locationName)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(advice.headline)
                .font(.title3.bold())

            Text(advice.recommendation)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Label(
                isWideLayout ? "Landscape layout" : "Portrait layout",
                systemImage: isWideLayout ? "rectangle.landscape" : "rectangle.portrait"
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .cardStyle()
        .accessibilityElement(children: .contain)
    }
}
