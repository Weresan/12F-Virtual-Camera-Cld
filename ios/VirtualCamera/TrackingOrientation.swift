import Foundation

/// A physical landscape hold must settle before calibration; UI rotation is irrelevant.
struct TrackingOrientation {
    private var candidate = 0
    private var since = 0.0
    private var active = 0

    mutating func update(side: Int, time: Double) -> (ready: Bool, recalibrate: Bool) {
        guard side != 0 else {
            candidate = 0; active = 0
            return (false, false)
        }
        if candidate != side { candidate = side; since = time; active = 0 }
        guard time - since >= 0.5 else { return (false, false) }
        let changed = active != side
        active = side
        return (true, changed)
    }
}
