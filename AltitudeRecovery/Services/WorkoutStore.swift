import Foundation
import Observation

@Observable
@MainActor
final class WorkoutStore {
    private(set) var workouts: [Workout] = []
    private(set) var lastErrorMessage: String?

    @ObservationIgnored private let fileManager: FileManager
    @ObservationIgnored private let fileURL: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let directory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appending(path: "AltitudeRecovery", directoryHint: .isDirectory)

        fileURL = directory.appending(path: "workouts.json")
        load()
    }

    func add(_ workout: Workout) {
        workouts.insert(workout, at: 0)
        workouts.sort { $0.date > $1.date }
        save()
    }

    func delete(ids: Set<Workout.ID>) {
        workouts.removeAll { ids.contains($0.id) }
        save()
    }

    func resetSamples() {
        workouts = Workout.samples()
        save()
    }

    func clear() {
        workouts = []
        save()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            workouts = try JSONDecoder().decode([Workout].self, from: data)
        } catch CocoaError.fileReadNoSuchFile {
            resetSamples()
        } catch {
            lastErrorMessage = error.localizedDescription
            workouts = Workout.samples()
        }
    }

    private func save() {
        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(workouts)
            try data.write(to: fileURL, options: .atomic)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }
}

