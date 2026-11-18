import SwiftUI

public struct RootView: View {
    @Bindable public var store: AppStore

    public init(store: AppStore) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            GhostTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch store.selectedTab {
                    case .home:
                        HomeDashboardView(store: store)
                    case .coach:
                        MorningCoachView(store: store)
                    case .settings:
                        MoreFeaturesSettingsView(store: store)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                GhostTabBar(selectedTab: $store.selectedTab)
            }

            if store.showingRingerOverlay {
                RingerWakeView(store: store)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(20)
            }
        }
        .sheet(isPresented: $store.showingWakeUpSheet) {
            SetWakeUpSheet(store: store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - 1. Home Screen (matches Photo 4: Alarm Card, Overlapping Ghost, AI Coach Card, Weather Card)
struct HomeDashboardView: View {
    @Bindable var store: AppStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Button {
                    store.showingWakeUpSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Alarm")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(GhostTheme.textSecondary)
                            Spacer()
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(store.primaryAlarm.timeString12)
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundStyle(GhostTheme.textPrimary)
                                Text(store.primaryAlarm.daypart)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(GhostTheme.textPrimary)
                            }
                        }

                        Divider().overlay(Color.white.opacity(0.10))

                        HStack {
                            Text(store.primaryAlarm.scheduleSummary)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(GhostTheme.lavender)
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                    store.togglePrimaryAlarm()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if store.primaryAlarm.isEnabled {
                                        Text("ON")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                            .padding(.leading, 8)
                                    }
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 24, height: 24)
                                }
                                .padding(4)
                                .frame(width: 68, height: 32, alignment: store.primaryAlarm.isEnabled ? .trailing : .leading)
                                .background(
                                    Capsule()
                                        .fill(store.primaryAlarm.isEnabled ? GhostTheme.lavender : Color.white.opacity(0.18))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(22)
                    .background(GhostTheme.alarmCardGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(GhostTheme.borderGlow.opacity(0.85), lineWidth: 1.6)
                    )
                    .shadow(color: GhostTheme.lavender.opacity(0.28), radius: 20, x: 0, y: 6)
                }
                .buttonStyle(.plain)

                ZStack(alignment: .top) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            store.selectedTab = .coach
                        }
                    } label: {
                        HStack(alignment: .bottom, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("AI Coach")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(GhostTheme.lavender)
                                Text("Ready for tomorrow?")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(GhostTheme.textPrimary)
                                Text("Tell me what you want to accomplish.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(GhostTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundStyle(GhostTheme.lavender)
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 36)
                        .padding(.bottom, 22)
                        .background(GhostTheme.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 42)

                    GhostMascotView(mood: .standard, size: 92)
                        .offset(y: -8)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        store.refreshWeatherMock()
                    }
                } label: {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(store.temperatureCelsius)°C")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(store.weatherCondition)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.92))
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                Text("Tap to refresh local weather")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(Color.white.opacity(0.75))
                            .padding(.top, 2)
                        }
                        Spacer()
                        ZStack {
                            Image(systemName: "moon.stars.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 64))
                                .foregroundStyle(Color.white.opacity(0.88))
                                .offset(x: 10, y: -10)
                            Image(systemName: "cloud.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(Color.white.opacity(0.95))
                                .offset(x: -10, y: 16)
                        }
                        .shadow(color: Color.white.opacity(0.35), radius: 12)
                    }
                    .padding(24)
                    .background(GhostTheme.weatherGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .shadow(color: GhostTheme.violetDeep.opacity(0.45), radius: 18, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - 2. Your Morning Coach Screen (matches Photo 1)
struct MorningCoachView: View {
    @Bindable var store: AppStore
    @State private var draftMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Morning Coach")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(GhostTheme.textPrimary)
                    Text("Small steps. A stronger start.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(GhostTheme.textSecondary)
                }
                Spacer()
                GhostMascotView(mood: .standard, size: 64)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().overlay(Color.white.opacity(0.08))

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(store.messages) { message in
                        HStack {
                            if message.isUser { Spacer() }
                            Text(message.text)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(GhostTheme.textPrimary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(message.isUser ? GhostTheme.violetButton : Color(red: 0.42, green: 0.41, blue: 0.52).opacity(0.75))
                                )
                            if !message.isUser { Spacer() }
                        }
                    }

                    FlowQuickChips(chips: store.quickReplies) { reply in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.sendCoachMessage(reply)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Morning plan")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(GhostTheme.textPrimary)

                        ForEach(store.morningPlan) { item in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    store.togglePlanItem(item.id)
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .stroke(GhostTheme.lavender, lineWidth: 2)
                                            .frame(width: 26, height: 26)
                                        if item.isCompleted {
                                            Circle()
                                                .fill(GhostTheme.lavender)
                                                .frame(width: 26, height: 26)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(GhostTheme.background)
                                        }
                                    }
                                    Text(item.title)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundStyle(GhostTheme.textPrimary)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(22)
                    .background(GhostTheme.morningPlanSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.top, 4)
                }
                .padding(20)
            }

            HStack(spacing: 12) {
                Button {
                    store.sendCoachMessage("Move my body")
                } label: {
                    Image(systemName: "mic")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(GhostTheme.textSecondary)
                        .frame(width: 36, height: 36)
                }

                TextField("Type a message...", text: $draftMessage)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(GhostTheme.cardSurface)
                    .clipShape(Capsule())
                    .foregroundStyle(GhostTheme.textPrimary)

                Button {
                    store.sendCoachMessage(draftMessage)
                    draftMessage = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 42)
                        .background(GhostTheme.violetButton)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(GhostTheme.background)
        }
    }
}

struct FlowQuickChips: View {
    let chips: [String]
    let onTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ForEach(chips.prefix(2), id: \.self) { chip in
                    chipButton(chip)
                }
            }
            if chips.count > 2 {
                HStack(spacing: 10) {
                    ForEach(chips.dropFirst(2), id: \.self) { chip in
                        chipButton(chip)
                    }
                }
            }
        }
    }

    private func chipButton(_ title: String) -> some View {
        Button {
            onTap(title)
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(GhostTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(GhostTheme.lavender.opacity(0.65), lineWidth: 1.3)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 3. Set Your Wake-Up Sheet (matches Photo 3)
struct SetWakeUpSheet: View {
    @Bindable var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var hour12: Int = 7
    @State private var minute: Int = 0
    @State private var isPM: Bool = false
    @State private var weekdays: Set<Int> = [1, 2, 3, 4, 5]
    @State private var alarmOn: Bool = true
    @State private var sound: String = "Ethereal Echo"
    @State private var snooze: Int = 5

    private let dayLetters: [(Int, String)] = [
        (1, "M"), (2, "T"), (3, "W"), (4, "T"), (5, "F"), (6, "S"), (7, "S")
    ]

    var body: some View {
        ZStack {
            GhostTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 8) {
                        GhostMascotView(mood: .standard, size: 28)
                        Text("Ghost Coach")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(GhostTheme.lavender)
                        Spacer()
                    }

                    Text("Set your wake-up.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(GhostTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)

                    HStack(spacing: 0) {
                        Picker("Hour", selection: $hour12) {
                            ForEach(1...12, id: \.self) { h in
                                Text("\(h)").tag(h)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Minute", selection: $minute) {
                            ForEach(0..<60, id: \.self) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("AM/PM", selection: $isPM) {
                            Text("AM").tag(false)
                            Text("PM").tag(true)
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 156)
                    .background(GhostTheme.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(GhostTheme.lavender.opacity(0.35), lineWidth: 1)
                    )

                    Text("Repeat")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(GhostTheme.textSecondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekdays")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(GhostTheme.textPrimary)

                        HStack(spacing: 10) {
                            ForEach(dayLetters, id: \.0) { day, letter in
                                let selected = weekdays.contains(day)
                                Button {
                                    if selected {
                                        weekdays.remove(day)
                                    } else {
                                        weekdays.insert(day)
                                    }
                                } label: {
                                    Text(letter)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(selected ? .white : GhostTheme.textSecondary)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(selected ? GhostTheme.violetButton : Color.white.opacity(0.08))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(GhostTheme.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(spacing: 0) {
                        Toggle(isOn: $alarmOn) {
                            Text("Alarm On")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(GhostTheme.textPrimary)
                        }
                        .tint(GhostTheme.violetButton)
                        .padding(16)

                        Divider().overlay(Color.white.opacity(0.08))

                        HStack {
                            Text("Sound")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(GhostTheme.textPrimary)
                            Spacer()
                            Text("\(sound) ›")
                                .font(.system(size: 15))
                                .foregroundStyle(GhostTheme.textSecondary)
                        }
                        .padding(16)

                        Divider().overlay(Color.white.opacity(0.08))

                        HStack {
                            Text("Snooze")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(GhostTheme.textPrimary)
                            Spacer()
                            Text("\(snooze) Minutes ›")
                                .font(.system(size: 15))
                                .foregroundStyle(GhostTheme.textSecondary)
                        }
                        .padding(16)
                    }
                    .background(GhostTheme.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    HStack(spacing: 14) {
                        Image(systemName: "umbrella.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(GhostTheme.lavender)
                            .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Weather-Aware Reminder")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(GhostTheme.lavender)
                            Text(store.weatherReminderTitle)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(GhostTheme.textPrimary)
                            Text(store.weatherReminderSubtitle)
                                .font(.system(size: 13))
                                .foregroundStyle(GhostTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(GhostTheme.morningPlanSurface.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(GhostTheme.lavender.opacity(0.35), lineWidth: 1)
                    )

                    Button {
                        store.saveWakeUp(
                            hour12: hour12,
                            minute: minute,
                            isPM: isPM,
                            weekdays: weekdays,
                            isEnabled: alarmOn,
                            sound: sound,
                            snooze: snooze
                        )
                        dismiss()
                    } label: {
                        Text("Save alarm")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(GhostTheme.violetButton)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
                .padding(22)
            }
        }
        .onAppear {
            let current = store.primaryAlarm
            let h = current.hour % 12
            hour12 = h == 0 ? 12 : h
            minute = current.minute
            isPM = current.hour >= 12
            weekdays = current.weekdays
            alarmOn = current.isEnabled
            sound = current.sound
            snooze = current.snoozeMinutes
        }
    }
}

// MARK: - 4. Ringer / Wake-Up Screen (matches Photo 2: Happy glowing ghost, Good morning, 7:00, I'm Awake, Snooze · 5 min, Rain today · 12°C)
struct RingerWakeView: View {
    @Bindable var store: AppStore

    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(red: 0.22, green: 0.16, blue: 0.36),
                    GhostTheme.background
                ],
                center: .top,
                startRadius: 20,
                endRadius: 460
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 24)

                GhostMascotView(mood: .happyAwake, size: 112)

                VStack(spacing: 6) {
                    Text("Good morning")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.99, green: 0.91, blue: 0.78))
                    Text("Let’s take the first small step.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color(red: 0.92, green: 0.84, blue: 0.76))
                }
                .padding(.top, 4)

                VStack(spacing: 6) {
                    Text(store.primaryAlarm.timeString12)
                        .font(.system(size: 88, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(formattedDateString)
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(GhostTheme.textPrimary.opacity(0.9))
                }
                .padding(.vertical, 16)

                VStack(spacing: 14) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            store.showingRingerOverlay = false
                        }
                    } label: {
                        Text("I’m Awake")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 0.09, green: 0.07, blue: 0.14))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(GhostTheme.lavender)
                            .clipShape(Capsule())
                            .shadow(color: GhostTheme.lavender.opacity(0.55), radius: 18, x: 0, y: 4)
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            store.showingRingerOverlay = false
                        }
                    } label: {
                        Text("Snooze · \(store.primaryAlarm.snoozeMinutes) min")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(GhostTheme.lavenderBright)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                Capsule()
                                    .stroke(GhostTheme.lavender.opacity(0.65), lineWidth: 1.4)
                            )
                    }
                }
                .padding(.horizontal, 12)

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "cloud.rain.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.cyan.opacity(0.85))
                    Text(store.weatherForecastLine)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(GhostTheme.textPrimary.opacity(0.9))
                }
                .padding(.bottom, 22)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - 5. Settings & More Features Hub (houses Alarms, Habits, Sleep & Sounds, Weather, Cute Voice)
struct MoreFeaturesSettingsView: View {
    @Bindable var store: AppStore

    private let sleepSounds = ["Rain on Leaves", "Soft Brown Noise", "Midnight Crickets", "Ocean Drift"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("More Features")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(GhostTheme.textPrimary)
                        Text("Alarms, habits, sleep sounds & cute voice settings.")
                            .font(.system(size: 15))
                            .foregroundStyle(GhostTheme.textSecondary)
                    }
                    Spacer()
                    GhostMascotView(mood: .standard, size: 56)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Wake-Up & Alarms", systemImage: "alarm.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(GhostTheme.lavenderBright)
                        Spacer()
                        Button("Edit Wake-Up") {
                            store.showingWakeUpSheet = true
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(GhostTheme.lavender)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(store.primaryAlarm.timeString12) \(store.primaryAlarm.daypart)")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(GhostTheme.textPrimary)
                            Text("\(store.primaryAlarm.scheduleSummary) · \(store.primaryAlarm.sound)")
                                .font(.system(size: 14))
                                .foregroundStyle(GhostTheme.textSecondary)
                        }
                        Spacer()
                        Button("Ring Now") {
                            withAnimation {
                                store.showingRingerOverlay = true
                            }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(GhostTheme.violetButton)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding(18)
                .background(GhostTheme.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    Label("Morning Habits", systemImage: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(GhostTheme.lavenderBright)

                    ForEach(store.habits) { habit in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                store.toggleHabit(habit.id)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(habit.icon)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.title)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(GhostTheme.textPrimary)
                                    Text("\(habit.streakDays) day streak")
                                        .font(.system(size: 13))
                                        .foregroundStyle(GhostTheme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: habit.completedToday ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(habit.completedToday ? GhostTheme.lavender : GhostTheme.textSecondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
                .background(GhostTheme.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Sleep & Sounds", systemImage: "moon.stars.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(GhostTheme.lavenderBright)
                        Spacer()
                        Text(String(format: "Last sleep %.1fh", store.lastSleepHours))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(GhostTheme.textSecondary)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(sleepSounds, id: \.self) { soundName in
                            let playing = store.activeSleepSound == soundName
                            Button {
                                store.activeSleepSound = playing ? nil : soundName
                            } label: {
                                HStack {
                                    Image(systemName: playing ? "waveform" : "play.fill")
                                        .font(.system(size: 13))
                                    Text(soundName)
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 10)
                                .background(playing ? GhostTheme.violetButton : Color.white.opacity(0.06))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(18)
                .background(GhostTheme.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(spacing: 14) {
                    Toggle(isOn: $store.cuteVoiceEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cute Ghost Voice")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(GhostTheme.textPrimary)
                            Text("Soft, high-pitched friendly wake-up voice")
                                .font(.system(size: 13))
                                .foregroundStyle(GhostTheme.textSecondary)
                        }
                    }
                    .tint(GhostTheme.violetButton)
                }
                .padding(18)
                .background(GhostTheme.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .padding(20)
        }
    }
}

// MARK: - Bottom 3-Item Tab Bar matching Reference Photos (Home, Coach, Settings)
struct GhostTabBar: View {
    @Binding var selectedTab: AppStore.Tab

    var body: some View {
        HStack {
            tabButton(tab: .home, icon: "sparkles.rectangle.stack.fill", label: "Home")
            Spacer()
            tabButton(tab: .coach, icon: "bubble.left.and.bubble.right.fill", label: "Coach")
            Spacer()
            tabButton(tab: .settings, icon: "gearshape.fill", label: "Settings")
        }
        .padding(.horizontal, 42)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(
            Color(red: 0.12, green: 0.11, blue: 0.16)
                .overlay(alignment: .top) {
                    Divider().overlay(Color.white.opacity(0.08))
                }
        )
    }

    private func tabButton(tab: AppStore.Tab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? GhostTheme.lavender : GhostTheme.textSecondary)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? GhostTheme.lavender : GhostTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}
