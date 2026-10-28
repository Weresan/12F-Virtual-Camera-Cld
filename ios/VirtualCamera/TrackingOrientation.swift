import Foundation

/// Keep the latched basis through a brief interruption; sustained loss requires a tap.
struct TrackingOrientation {
    private(set) var side: Int?
    private var needsCalibration = false
    private var interruptedAt: Double?
    static let grace = 1.0
    mutating func activate(side: Int) -> Bool {
        guard (1...4).contains(side) else { return false }
        self.side = side; needsCalibration = true; interruptedAt = nil
        return true
    }
    mutating func update(normal: Bool, time: Double = 0) -> (ready: Bool, recalibrate: Bool, expired: Bool) {
        guard side != nil else { return (false, false, false) }
        if !normal {
            if interruptedAt == nil { interruptedAt = time }
            if time - interruptedAt! >= Self.grace {
                self = TrackingOrientation(); return (false, false, true)
            }
            return (false, false, false)
        }
        interruptedAt = nil
        let calibrate = needsCalibration; needsCalibration = false
        return (true, calibrate, false)
    }
}
