import Foundation
import CoreGraphics

enum GuideMode: String, CaseIterable, Identifiable {
    case none = "Off", thirds = "Rule of thirds", golden = "Golden ratio", center = "Center cross", safe = "Safe areas"
    var id: String { rawValue }
}
struct GuideLine { let start: CGPoint; let end: CGPoint }

enum CompositionGeometry {
    static func fittedRect(image: CGSize, container: CGSize) -> CGRect {
        guard image.width > 0, image.height > 0, container.width > 0, container.height > 0 else { return .zero }
        let scale = min(container.width/image.width, container.height/image.height)
        let size = CGSize(width:image.width*scale, height:image.height*scale)
        return CGRect(x:(container.width-size.width)/2,y:(container.height-size.height)/2,width:size.width,height:size.height)
    }
    static func lines(_ mode: GuideMode, in rect: CGRect) -> [GuideLine] {
        func point(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x:rect.minX+rect.width*x,y:rect.minY+rect.height*y) }
        func line(_ x1: Double,_ y1: Double,_ x2: Double,_ y2: Double) -> GuideLine {
            GuideLine(start:point(x1,y1),end:point(x2,y2))
        }
        switch mode {
        case .none: return []
        case .thirds, .golden:
            let fractions = mode == .thirds ? [1.0/3,2.0/3] : [0.38196601125,0.61803398875]
            return fractions.flatMap { f in [line(f,0,f,1),line(0,f,1,f)] }
        case .center: return [line(0.46,0.5,0.54,0.5),line(0.5,0.44,0.5,0.56)]
        case .safe:
            return [0.05,0.1].flatMap { f in
                [line(f,f,1-f,f),line(1-f,f,1-f,1-f),line(1-f,1-f,f,1-f),line(f,1-f,f,f)]
            }
        }
    }
}
