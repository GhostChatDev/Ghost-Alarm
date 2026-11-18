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
                // Top Alarm Card with purple glowing border
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
                                    .font(.system(size: 68, weight: .bold, design: .rounded))
                                    .foregroundStyle(GhostTheme.textPrimary)
                                Text(store.primaryAlarm.daypart)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
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

                // AI Coach Card with Floating Ghost overlapping top center
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

                // Weather Card with rich purple gradient & moon/cloud artwork
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
                                .symbolRenderingMode(.Hierarchical)
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

                // Quick actions to test Set Wake-Up & Ringer screens
                HStack(spacing: 12) {
                    Button {
                        store.showingWakeUpSheet = true
                    } label: {
                        Label("Set Wake-Up", systemImage: "alarm.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(GhostTheme.cardSurface)
                            .foregroundStyle(GhostTheme.lavenderBright)
                            .clipShape(Capsule())
                    }
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            store.showingRingerOverlay = true
                        }
                    } label: {
                        Label("Preview Wake Screen", systemImage: "bell.and.waves.left.and.right.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(GhostTheme.cardSurface)
                            .foregroundStyle(GhostTheme.lavenderBright)
                            .clipShape(Capsule())
                    }
                }
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
            // Header
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

                    // Outlined pill quick replies
                    FlowQuickChips(chips: store.quickReplies) { reply in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.sendCoachMessage(reply)
                        }
                    }

                    // Morning Plan Card
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

            // Bottom Composer Bar with Mic, Input & Purple Send Button
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

                    // Wheel-style time picker container
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

                    // Weekdays M T W T F S S card
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

                    // Alarm On / Sound / Snooze grouped card
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

                    // Weather-Aware Reminder Card
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
