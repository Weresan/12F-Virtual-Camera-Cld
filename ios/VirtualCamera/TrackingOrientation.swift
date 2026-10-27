import Foundation

/// Explicit activation fixes a camera basis until recenter, tracking loss or disconnect.
struct TrackingOrientation {
    private(set) var side: Int?
    private var needsCalibration = false

    mutating func activate(side: Int) -> Bool {
        guard (1...4).contains(side) else { return false }
        self.side = side; needsCalibration = true
        return true
    }
    mutating func update(normal: Bool) -> (ready: Bool, recalibrate: Bool) {
        guard normal else { self = TrackingOrientation(); return (false, false) }
        guard side != nil else { return (false, false) }
        let calibrate = needsCalibration; needsCalibration = false
        return (true, calibrate)
    }
}
