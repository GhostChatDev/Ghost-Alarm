import Foundation
import Observation

public struct GhostAlarmItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var hour: Int
    public var minute: Int
    public var label: String
    public var isEnabled: Bool
    public var weekdays: Set<Int> // 1 = Mon ... 7 = Sun
    public var sound: String
    public var snoozeMinutes: Int
    public var weatherAware: Bool

    public init(
        id: UUID = UUID(),
        hour: Int = 7,
        minute: Int = 0,
        label: String = "Morning Wake-Up",
        isEnabled: Bool = true,
        weekdays: Set<Int> = [1, 2, 3, 4, 5],
        sound: String = "Ethereal Echo",
        snoozeMinutes: Int = 5,
        weatherAware: Bool = true
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.label = label
        self.isEnabled = isEnabled
        self.weekdays = weekdays
        self.sound = sound
        self.snoozeMinutes = snoozeMinutes
        self.weatherAware = weatherAware
    }

    public var timeString12: String {
        let h12 = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%d:%02d", h12, minute)
    }

    public var daypart: String {
        hour >= 12 ? "PM" : "AM"
    }

    public var scheduleSummary: String {
        if weekdays == [1, 2, 3, 4, 5] { return "Tomorrow · Mon–Fri" }
        if weekdays.count == 7 { return "Tomorrow · Every day" }
        if weekdays == [6, 7] { return "Tomorrow · Weekends" }
        let names = [(1, "Mon"), (2, "Tue"), (3, "Wed"), (4, "Thu"), (5, "Fri"), (6, "Sat"), (7, "Sun")]
        let picked = names.filter { weekdays.contains($0.0) }.map(\.1)
        return picked.isEmpty ? "Once" : "Tomorrow · " + picked.joined(separator: ", ")
    }
}

public struct MorningPlanItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

public struct HabitItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var icon: String
    public var title: String
    public var streakDays: Int
    public var completedToday: Bool

    public init(id: UUID = UUID(), icon: String, title: String, streakDays: Int, completedToday: Bool = false) {
        self.id = id
        self.icon = icon
        self.title = title
        self.streakDays = streakDays
        self.completedToday = completedToday
    }
}

public struct CoachMessage: Identifiable, Codable, Equatable {
    public var id: UUID
    public var isUser: Bool
    public var text: String

    public init(id: UUID = UUID(), isUser: Bool, text: String) {
        self.id = id
        self.isUser = isUser
        self.text = text
    }
}

@Observable
public final class AppStore {
    public enum Tab: String, CaseIterable {
        case home = "Home"
        case coach = "Coach"
        case settings = "Settings"
    }

    public var selectedTab: Tab = .home
    public var alarms: [GhostAlarmItem]
    public var morningPlan: [MorningPlanItem]
    public var habits: [HabitItem]
    public var messages: [CoachMessage]
    public var quickReplies: [String] = [
        "Move my body",
        "Focus on work",
        "Feel less stressed"
    ]

    public var temperatureCelsius: Int = 18
    public var weatherCondition: String = "Clear sky"
    public var weatherForecastLine: String = "Rain today · 12°C"
    public var weatherReminderTitle: String = "Rain is expected tomorrow morning"
    public var weatherReminderSubtitle: String = "We'll remind you to bring an umbrella."

    public var showingWakeUpSheet: Bool = false
    public var showingRingerOverlay: Bool = false
    public var activeSleepSound: String? = nil
    public var lastSleepHours: Double = 7.5
    public var cuteVoiceEnabled: Bool = true

    public init() {
        self.alarms = [
            GhostAlarmItem(hour: 7, minute: 0, label: "Morning Wake-Up", isEnabled: true, weekdays: [1, 2, 3, 4, 5], sound: "Ethereal Echo", snoozeMinutes: 5, weatherAware: true)
        ]
        self.morningPlan = [
            MorningPlanItem(title: "Drink a glass of water", isCompleted: true),
            MorningPlanItem(title: "Stretch for two minutes", isCompleted: true),
            MorningPlanItem(title: "Pick your first task", isCompleted: false)
        ]
        self.habits = [
            HabitItem(icon: "💧", title: "Hydrate on wake-up", streakDays: 6, completedToday: true),
            HabitItem(icon: "🧘", title: "2-min morning stretch", streakDays: 4, completedToday: true),
            HabitItem(icon: "📵", title: "No phone for 15m", streakDays: 3, completedToday: false)
        ]
        self.messages = [
            CoachMessage(isUser: false, text: "Good morning. What's one thing you want to get done today?")
        ]
    }

    public var primaryAlarm: GhostAlarmItem {
        get { alarms.first ?? GhostAlarmItem() }
        set {
            if alarms.isEmpty {
                alarms = [newValue]
            } else {
                alarms[0] = newValue
            }
        }
    }

    public func togglePrimaryAlarm() {
        guard !alarms.isEmpty else { return }
        alarms[0].isEnabled.toggle()
    }

    public func togglePlanItem(_ id: UUID) {
        guard let idx = morningPlan.firstIndex(where: { $0.id == id }) else { return }
        morningPlan[idx].isCompleted.toggle()
    }

    public func toggleHabit(_ id: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[idx].completedToday.toggle()
        habits[idx].streakDays += habits[idx].completedToday ? 1 : -1
        if habits[idx].streakDays < 0 { habits[idx].streakDays = 0 }
    }

    public func sendCoachMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(CoachMessage(isUser: true, text: trimmed))
        let lower = trimmed.lowercased()
        let reply: String
        if lower.contains("move") || lower.contains("body") {
            reply = "Love that energy! Let's start with a 2-minute stretch right after your glass of water."
        } else if lower.contains("focus") || lower.contains("work") {
            reply = "Picked for deep focus: write down your single #1 priority before opening messages."
        } else if lower.contains("stress") {
            reply = "Take three slow breaths with me. Small steps make a calm, strong morning."
        } else {
            reply = "Locked in! Keep it tiny: two minutes of action beats an hour of planning."
        }
        messages.append(CoachMessage(isUser: false, text: reply))
    }

    public func refreshWeatherMock() {
        let samples: [(Int, String, String)] = [
            (18, "Clear sky", "Rain today · 12°C"),
            (21, "Partly cloudy", "Light breeze · 19°C"),
            (15, "Gentle rain", "Rain today · 15°C")
        ]
        if let next = samples.first(where: { $0.0 != temperatureCelsius }) {
            temperatureCelsius = next.0
            weatherCondition = next.1
            weatherForecastLine = next.2
        }
    }

    public func saveWakeUp(hour12: Int, minute: Int, isPM: Bool, weekdays: Set<Int>, isEnabled: Bool, sound: String, snooze: Int) {
        let normalized12 = ((hour12 - 1) % 12) + 1
        let hour24: Int
        if isPM {
            hour24 = normalized12 == 12 ? 12 : normalized12 + 12
        } else {
            hour24 = normalized12 == 12 ? 0 : normalized12
        }
        var updated = primaryAlarm
        updated.hour = hour24
        updated.minute = minute
        updated.weekdays = weekdays
        updated.isEnabled = isEnabled
        updated.sound = sound
        updated.snoozeMinutes = snooze
        primaryAlarm = updated
    }
}
