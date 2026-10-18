import SwiftUI

/// A short shaft + chevron arrow, styled like `BranchedChildrenView`'s tree
/// connector — same accent color (`pathwayAccent`), same rounded stroke —
/// so a disposition's own "condition → pill" arrow (`OutView`) and an arm's
/// "tag → inline pill" arrow (`ArmView`) read as the same visual language as
/// the branch lines around them, instead of a plain gray SF Symbol that
/// belongs to a different, unrelated icon system.
struct DispositionArrow: View {
    @Environment(\.pathwayAccent) private var lineColor

    private let lineWidth: CGFloat = 2
    private let headLength: CGFloat = 4
    private let headHalfHeight: CGFloat = 3

    var body: some View {
        ArrowShape(headLength: headLength, headHalfHeight: headHalfHeight)
            .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .frame(width: 14, height: 8)
    }
}

private struct ArrowShape: Shape {
    let headLength: CGFloat
    let headHalfHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        path.move(to: CGPoint(x: rect.minX, y: midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        path.move(to: CGPoint(x: rect.maxX - headLength, y: midY - headHalfHeight))
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        path.addLine(to: CGPoint(x: rect.maxX - headLength, y: midY + headHalfHeight))
        return path
    }
}
