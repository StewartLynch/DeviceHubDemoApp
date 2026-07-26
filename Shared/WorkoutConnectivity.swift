import Foundation
@preconcurrency import WatchConnectivity

nonisolated final class WorkoutConnectivity: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let snapshotDataKey = "appSnapshotData"

    private let session: WCSession?
    private let receivedData: @Sendable (Data) -> Void
    private let pendingDataLock = NSLock()
    private var pendingData: Data?

    init(receivedData: @escaping @Sendable (Data) -> Void = { _ in }) {
        session = WCSession.isSupported() ? .default : nil
        self.receivedData = receivedData
        super.init()
    }

    func activate() {
        session?.delegate = self
        session?.activate()
    }

    func sendLatest(_ data: Data) {
        pendingDataLock.lock()
        pendingData = data
        pendingDataLock.unlock()
        flushPendingData()
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        guard activationState == .activated, error == nil else { return }
        flushPendingData()
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        guard let data = applicationContext[Self.snapshotDataKey] as? Data else {
            return
        }
        receivedData(data)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    private func flushPendingData() {
        guard let session, session.activationState == .activated else { return }

        pendingDataLock.lock()
        guard let data = pendingData else {
            pendingDataLock.unlock()
            return
        }
        pendingDataLock.unlock()

        do {
            try session.updateApplicationContext([Self.snapshotDataKey: data])
            pendingDataLock.lock()
            if pendingData == data {
                pendingData = nil
            }
            pendingDataLock.unlock()
        } catch {
            // Retain the pending snapshot so a later activation can retry it.
        }
    }
}
