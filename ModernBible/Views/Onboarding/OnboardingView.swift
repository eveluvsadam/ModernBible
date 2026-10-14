import SwiftUI

struct OnboardingView: View {
    let onFinished: () -> Void

    @State private var page = 0
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                WelcomePage().tag(0)
                LanguagePage().tag(1)
                TranslationPage().tag(2)
                NotificationPage(onFinished: onFinished).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: page)

            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: page)
                }
            }
            .padding(.bottom, 12)

            Button(page == pageCount - 1 ? L("onboarding.get_started") : L("onboarding.next")) {
                if page == pageCount - 1 {
                    onFinished()
                } else {
                    withAnimation { page += 1 }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.pages")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
            Text(L("onboarding.welcome.title"))
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(L("onboarding.welcome.subtitle"))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

private struct LanguagePage: View {
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: 24) {
            Text(L("onboarding.language.title"))
                .font(.title.bold())
            ForEach(AppLanguage.allCases) { language in
                Button {
                    localizationManager.language = language
                } label: {
                    HStack {
                        Text(language.displayName)
                        Spacer()
                        if localizationManager.language == language {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
            }
        }
    }
}

private struct TranslationPage: View {
    @State private var selected: Translation = .kjv
    private let translations: [Translation] = [.kjv, .lsg, .htcv]

    var body: some View {
        VStack(spacing: 24) {
            Text(L("onboarding.translation.title"))
                .font(.title.bold())
            ForEach(translations) { translation in
                Button {
                    selected = translation
                } label: {
                    HStack {
                        Text(translation.displayName)
                        Spacer()
                        if selected == translation {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
            }
        }
    }
}

private struct NotificationPage: View {
    let onFinished: () -> Void
    @State private var notificationsEnabled = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text(L("onboarding.notifications.title"))
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text(L("onboarding.notifications.subtitle"))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Toggle(L("onboarding.notifications.toggle"), isOn: $notificationsEnabled)
                .padding(.horizontal, 48)
                .onChange(of: notificationsEnabled) { _, enabled in
                    if enabled {
                        NotificationService.shared.requestAuthorization { _ in }
                    }
                }
        }
    }
}

#Preview {
    OnboardingView(onFinished: {})
        .environmentObject(LocalizationManager.shared)
}
