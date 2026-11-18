import SwiftUI

public enum GhostTheme {
    // Deep charcoal & soft lavender colors matching the 4 reference screens
    public static let background = Color(red: 0.08, green: 0.075, blue: 0.11) // #14131C
    public static let cardSurface = Color(red: 0.16, green: 0.15, blue: 0.20) // #292633
    public static let cardElevated = Color(red: 0.20, green: 0.17, blue: 0.26)
    public static let morningPlanSurface = Color(red: 0.21, green: 0.15, blue: 0.35) // #352659
    public static let lavender = Color(red: 0.72, green: 0.60, blue: 0.98) // #B899FA
    public static let lavenderBright = Color(red: 0.82, green: 0.73, blue: 1.0)
    public static let violetDeep = Color(red: 0.45, green: 0.28, blue: 0.78) // #7347C7
    public static let violetButton = Color(red: 0.46, green: 0.35, blue: 0.78) // #7559C7
    public static let textPrimary = Color(red: 0.97, green: 0.96, blue: 1.0)
    public static let textSecondary = Color(red: 0.67, green: 0.64, blue: 0.74)
    public static let borderGlow = Color(red: 0.62, green: 0.45, blue: 0.92)

    public static let weatherGradient = LinearGradient(
        colors: [
            Color(red: 0.40, green: 0.21, blue: 0.78),
            Color(red: 0.53, green: 0.38, blue: 0.86)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let alarmCardGradient = LinearGradient(
        colors: [
            Color(red: 0.13, green: 0.12, blue: 0.17),
            Color(red: 0.09, green: 0.08, blue: 0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public struct GhostMascotView: View {
    public enum Mood {
        case standard
        case happyAwake
    }

    public var mood: Mood = .standard
    public var size: CGFloat = 88
    @State private var floating = false

    public init(mood: Mood = .standard, size: CGFloat = 88) {
        self.mood = mood
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [GhostTheme.lavender.opacity(0.42), .clear],
                        center: .center,
                        startRadius: size * 0.08,
                        endRadius: size * 0.62
                    )
                )
                .frame(width: size * 1.35, height: size * 1.35)

            Canvas { context, canvasSize in
                let w = canvasSize.width
                let h = canvasSize.height

                // Ghost body with cute arms and wavy bottom
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: w * 0.20, y: h * 0.50))
                bodyPath.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.12),
                    control1: CGPoint(x: w * 0.20, y: h * 0.24),
                    control2: CGPoint(x: w * 0.33, y: h * 0.12)
                )
                bodyPath.addCurve(
                    to: CGPoint(x: w * 0.80, y: h * 0.50),
                    control1: CGPoint(x: w * 0.67, y: h * 0.12),
                    control2: CGPoint(x: w * 0.80, y: h * 0.24)
                )
                // Right little arm
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.92, y: h * 0.48),
                    control: CGPoint(x: w * 0.88, y: h * 0.44)
                )
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.80, y: h * 0.62),
                    control: CGPoint(x: w * 0.93, y: h * 0.57)
                )
                // Right side down to wavy hem
                bodyPath.addLine(to: CGPoint(x: w * 0.82, y: h * 0.84))
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.64, y: h * 0.85),
                    control: CGPoint(x: w * 0.74, y: h * 0.93)
                )
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.88),
                    control: CGPoint(x: w * 0.57, y: h * 0.79)
                )
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.36, y: h * 0.85),
                    control: CGPoint(x: w * 0.43, y: h * 0.94)
                )
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.18, y: h * 0.83),
                    control: CGPoint(x: w * 0.26, y: h * 0.78)
                )
                // Left arm
                bodyPath.addLine(to: CGPoint(x: w * 0.20, y: h * 0.62))
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.08, y: h * 0.48),
                    control: CGPoint(x: w * 0.07, y: h * 0.57)
                )
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.20, y: h * 0.50),
                    control: CGPoint(x: w * 0.12, y: h * 0.44)
                )
                bodyPath.closeSubpath()

                let bodyShading = GraphicsContext.Shading.linearGradient(
                    Gradient(colors: [
                        Color.white,
                        Color(red: 0.88, green: 0.82, blue: 1.0),
                        Color(red: 0.70, green: 0.58, blue: 0.96)
                    ]),
                    startPoint: CGPoint(x: w * 0.35, y: h * 0.12),
                    endPoint: CGPoint(x: w * 0.70, y: h * 0.90)
                )
                context.fill(bodyPath, with: bodyShading)
                context.stroke(bodyPath, with: .color(Color.white.opacity(0.65)), lineWidth: 1.4)

                // Eyes & Mouth
                let eyeColor = Color(red: 0.18, green: 0.13, blue: 0.24)
                if mood == .happyAwake {
                    var leftEye = Path()
                    leftEye.move(to: CGPoint(x: w * 0.35, y: h * 0.44))
                    leftEye.addQuadCurve(to: CGPoint(x: w * 0.44, y: h * 0.44), control: CGPoint(x: w * 0.395, y: h * 0.37))
                    context.stroke(leftEye, with: .color(eyeColor), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                    var rightEye = Path()
                    rightEye.move(to: CGPoint(x: w * 0.56, y: h * 0.44))
                    rightEye.addQuadCurve(to: CGPoint(x: w * 0.65, y: h * 0.44), control: CGPoint(x: w * 0.605, y: h * 0.37))
                    context.stroke(rightEye, with: .color(eyeColor), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                } else {
                    let leftRect = CGRect(x: w * 0.37, y: h * 0.40, width: w * 0.065, height: h * 0.08)
                    let rightRect = CGRect(x: w * 0.565, y: h * 0.40, width: w * 0.065, height: h * 0.08)
                    context.fill(Path(ellipseIn: leftRect), with: .color(eyeColor))
                    context.fill(Path(ellipseIn: rightRect), with: .color(eyeColor))
                }

                // Rosy cheeks
                let leftCheek = CGRect(x: w * 0.31, y: h * 0.48, width: w * 0.08, height: h * 0.045)
                let rightCheek = CGRect(x: w * 0.61, y: h * 0.48, width: w * 0.08, height: h * 0.045)
                context.fill(Path(ellipseIn: leftCheek), with: .color(Color.pink.opacity(0.35)))
                context.fill(Path(ellipseIn: rightCheek), with: .color(Color.pink.opacity(0.35)))

                // Cute smile
                var smile = Path()
                smile.move(to: CGPoint(x: w * 0.46, y: h * 0.50))
                smile.addQuadCurve(to: CGPoint(x: w * 0.54, y: h * 0.50), control: CGPoint(x: w * 0.50, y: h * 0.55))
                context.stroke(smile, with: .color(eyeColor), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
            }
            .frame(width: size, height: size)
            .shadow(color: GhostTheme.lavender.opacity(0.55), radius: 14, x: 0, y: 4)
            .offset(y: floating ? -5 : 4)
            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: floating)
        }
        .onAppear { floating = true }
    }
}
